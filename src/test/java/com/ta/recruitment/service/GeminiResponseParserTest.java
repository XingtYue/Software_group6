package com.ta.recruitment.service;

import com.ta.recruitment.model.Application;
import org.junit.jupiter.api.*;
import java.lang.reflect.*;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Tests for GeminiService's JSON sanitization and response-parsing helpers.
 *
 * These tests exercise the private sanitizeJsonString() and populateApplication()
 * methods directly via reflection — no network calls are made.
 *
 * The real Gemini 2.5 Flash API sometimes returns:
 *   - Responses wrapped in ```json ... ``` fences
 *   - Thinking parts (which must be skipped — tested in extractTextFromResponse)
 *   - Literal newlines / tabs inside JSON string values
 *
 * Ensuring these are handled correctly is critical: a parse failure here
 * would silently discard AI results and leave application AI fields empty.
 */
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
class GeminiResponseParserTest {

    private GeminiService service;
    private Method sanitizeMethod;
    private Method populateMethod;
    private Method extractTextMethod;

    @BeforeEach
    void setUp() throws Exception {
        service = new GeminiService();

        sanitizeMethod = GeminiService.class.getDeclaredMethod(
                "sanitizeJsonString", String.class);
        sanitizeMethod.setAccessible(true);

        populateMethod = GeminiService.class.getDeclaredMethod(
                "populateApplication", Application.class, String.class);
        populateMethod.setAccessible(true);

        extractTextMethod = GeminiService.class.getDeclaredMethod(
                "extractTextFromResponse", String.class);
        extractTextMethod.setAccessible(true);
    }

    private String sanitize(String input) throws Exception {
        return (String) sanitizeMethod.invoke(service, input);
    }

    private Application populate(String json) throws Exception {
        Application app = new Application();
        populateMethod.invoke(service, app, json);
        return app;
    }

    private String extractText(String responseBody) throws Exception {
        return (String) extractTextMethod.invoke(service, responseBody);
    }

    // ------------------------------------------------------------------
    // TC-PARSER-01: Code-fence stripping — ```json ... ``` wrapper removed
    // ------------------------------------------------------------------

    @Test
    @Order(1)
    @DisplayName("TC-PARSER-01: ```json fence stripped before parsing")
    void sanitize_stripsJsonCodeFence() throws Exception {
        String fenced = "```json\n{\"aiMatchScore\":75}\n```";
        String result = sanitize(fenced);
        assertFalse(result.contains("```"),
            "Code fences must be stripped by sanitizeJsonString");
        assertTrue(result.contains("\"aiMatchScore\":75"),
            "The actual JSON payload must survive after stripping");
    }

    @Test
    @Order(2)
    @DisplayName("TC-PARSER-02: plain ``` fence (no 'json' tag) also stripped")
    void sanitize_stripsPlainCodeFence() throws Exception {
        String fenced = "```\n{\"aiMatchScore\":42}\n```";
        String result = sanitize(fenced);
        assertFalse(result.contains("```"));
        assertTrue(result.contains("\"aiMatchScore\":42"));
    }

    // ------------------------------------------------------------------
    // TC-PARSER-03: Newlines inside string values are escaped to \n
    // ------------------------------------------------------------------

    @Test
    @Order(3)
    @DisplayName("TC-PARSER-03: literal newline inside a JSON string value → escaped to \\n")
    void sanitize_escapesLiteralNewlineInStringValue() throws Exception {
        // A raw newline inside a JSON string would cause Gson to throw
        String withNewline = "{\"aiReasoning\":\"line one\nline two\"}";
        String result = sanitize(withNewline);
        assertFalse(result.contains("\n"),
            "Literal newline inside a string value must be escaped");
        assertTrue(result.contains("\\n"),
            "The newline must be replaced with the \\n escape sequence");
    }

    // ------------------------------------------------------------------
    // TC-PARSER-04: populateApplication() — all five fields mapped correctly
    // ------------------------------------------------------------------

    @Test
    @Order(4)
    @DisplayName("TC-PARSER-04: all five AI fields are mapped from JSON to Application")
    void populateApplication_allFieldsMappedCorrectly() throws Exception {
        String json = "{"
            + "\"aiMatchScore\":88,"
            + "\"aiMatchedSkills\":\"Java, OOP\","
            + "\"aiMissingSkills\":\"Docker\","
            + "\"aiReasoning\":\"Good fit overall.\","
            + "\"aiRecommendedAlternativeJob\":\"EBU5476 Lab TA\""
            + "}";

        Application app = populate(json);

        assertEquals(88, app.getAiMatchScore());
        assertEquals("Java, OOP", app.getAiMatchedSkills());
        assertEquals("Docker",    app.getAiMissingSkills());
        assertEquals("Good fit overall.", app.getAiReasoning());
        assertEquals("EBU5476 Lab TA", app.getAiRecommendedAlternativeJob());
    }

    // ------------------------------------------------------------------
    // TC-PARSER-05: populateApplication() — missing alt-job key → empty string
    // The field is optional; absence must not throw and must default to "".
    // ------------------------------------------------------------------

    @Test
    @Order(5)
    @DisplayName("TC-PARSER-05: absent aiRecommendedAlternativeJob → empty string, no NPE")
    void populateApplication_missingAltJobField_defaultsToEmptyString() throws Exception {
        // No aiRecommendedAlternativeJob key at all
        String json = "{"
            + "\"aiMatchScore\":55,"
            + "\"aiMatchedSkills\":\"Python\","
            + "\"aiMissingSkills\":\"Java\","
            + "\"aiReasoning\":\"Partial fit.\""
            + "}";

        Application app = assertDoesNotThrow(() -> populate(json),
            "Absent optional field must not throw an exception");

        assertEquals("", app.getAiRecommendedAlternativeJob(),
            "Missing aiRecommendedAlternativeJob must default to empty string, not null");
    }

    // ------------------------------------------------------------------
    // TC-PARSER-06: extractTextFromResponse() — thinking parts skipped
    // Gemini 2.5 Flash returns {"thought":true} parts first; they must be ignored.
    // ------------------------------------------------------------------

    @Test
    @Order(6)
    @DisplayName("TC-PARSER-06: extractTextFromResponse skips thought:true parts")
    void extractText_skipsThinkingParts_returnsActualJson() throws Exception {
        // Simulate the two-part Gemini 2.5 Flash response structure:
        // part[0] = thought (must be skipped), part[1] = actual answer
        String geminiResponse = "{"
            + "\"candidates\":[{"
            +   "\"content\":{"
            +     "\"parts\":["
            +       "{\"thought\":true,\"text\":\"Let me think about this...\"},"
            +       "{\"text\":\"{\\\"aiMatchScore\\\":90}\"}"
            +     "]"
            +   "}"
            + "}]}";

        String extracted = extractText(geminiResponse);

        assertFalse(extracted.contains("Let me think"),
            "The thinking part text must NOT appear in the extracted result");
        assertTrue(extracted.contains("aiMatchScore"),
            "The actual JSON answer must be extracted");
        assertTrue(extracted.contains("90"),
            "The extracted text must contain the score value");
    }

    // ------------------------------------------------------------------
    // TC-PARSER-07: extractTextFromResponse() — no thinking parts (simple response)
    // ------------------------------------------------------------------

    @Test
    @Order(7)
    @DisplayName("TC-PARSER-07: extractTextFromResponse works when there are no thinking parts")
    void extractText_noThinkingParts_returnsDirectTextPart() throws Exception {
        String geminiResponse = "{"
            + "\"candidates\":[{"
            +   "\"content\":{"
            +     "\"parts\":["
            +       "{\"text\":\"{\\\"aiMatchScore\\\":72,\\\"aiRecommendedAlternativeJob\\\":\\\"\\\"}\"}"
            +     "]"
            +   "}"
            + "}]}";

        String extracted = extractText(geminiResponse);
        assertTrue(extracted.contains("72"), "Score from direct (non-thinking) response must be extracted");
    }

    // ------------------------------------------------------------------
    // TC-PARSER-08: sanitize() is null-safe — returns "{}" for null input
    // ------------------------------------------------------------------

    @Test
    @Order(8)
    @DisplayName("TC-PARSER-08: sanitizeJsonString(null) returns '{}' without throwing")
    void sanitize_nullInput_returnsEmptyObjectSafely() throws Exception {
        String result = sanitize(null);
        assertEquals("{}", result,
            "A null input to sanitize must produce '{}' as a safe fallback");
    }
}
