package com.ta.recruitment.service;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.ta.recruitment.model.Application;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;
import java.util.Base64;

/**
 * Calls the Google Gemini 2.5 Flash API to analyse how well a TA's CV
 * matches a job's requirements.
 *
 * Only Gson is used here (to parse the Gemini response).
 * All business-data persistence is handled by the caller via DataStore.
 */
public class GeminiService {

    // ---------------------------------------------------------------
    // CONFIGURATION — replace with your real key, or pass via env var
    // ---------------------------------------------------------------
    private static final String API_KEY =
            System.getenv("GEMINI_API_KEY") != null
            ? System.getenv("GEMINI_API_KEY")
            : "YOUR_API_KEY_HERE";

    private static final String ENDPOINT =
            "https://generativelanguage.googleapis.com/v1beta/models/"
            + "gemini-2.5-flash:generateContent?key=" + API_KEY;

    private static final int TIMEOUT_SECONDS = 60;

    // ---------------------------------------------------------------
    // DEPENDENCIES
    // ---------------------------------------------------------------
    private final HttpClient httpClient;
    private final Gson gson;

    public GeminiService() {
        this.httpClient = HttpClient.newBuilder()
                .connectTimeout(Duration.ofSeconds(TIMEOUT_SECONDS))
                .build();
        this.gson = new Gson();
    }

    // ---------------------------------------------------------------
    // PUBLIC API
    // ---------------------------------------------------------------

    /**
     * Sends CV text and job requirements to Gemini, then writes the
     * analysis results (score, matched/missing skills, reasoning) back
     * onto the supplied {@code application} object.
     *
     * @param cvContent       plain-text context (name, dept, cover letter)
     * @param jobRequirements plain-text description of the job requirements
     * @return the same {@code application} instance, enriched with AI fields
     */
    public Application analyzeMatch(String cvContent, String jobRequirements) {
        return analyzeMatch(cvContent, jobRequirements, null);
    }

    /**
     * Overload that also accepts the raw bytes of a PDF CV file.
     * If {@code cvPdfBytes} is non-null, the PDF is sent as inline_data
     * alongside the text prompt so Gemini reads the actual resume document.
     *
     * @param cvContent       plain-text context (name, dept, cover letter)
     * @param jobRequirements plain-text description of the job requirements
     * @param cvPdfBytes      raw bytes of the TA's CV PDF, or null if unavailable
     */
    public Application analyzeMatch(String cvContent, String jobRequirements, byte[] cvPdfBytes) {
        Application application = new Application();

        String requestBody = buildRequestBody(cvContent, jobRequirements, cvPdfBytes);

        try {
            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(ENDPOINT))
                    .timeout(Duration.ofSeconds(TIMEOUT_SECONDS))
                    .header("Content-Type", "application/json")
                    .POST(HttpRequest.BodyPublishers.ofString(requestBody))
                    .build();

            HttpResponse<String> response =
                    httpClient.send(request, HttpResponse.BodyHandlers.ofString());

            if (response.statusCode() != 200) {
                throw new RuntimeException(
                    "Gemini API returned HTTP " + response.statusCode()
                    + ": " + response.body());
            }

            String resultJson = extractTextFromResponse(response.body());
            resultJson = sanitizeJsonString(resultJson);
            populateApplication(application, resultJson);

        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            throw new RuntimeException("Gemini API call interrupted", e);
        } catch (RuntimeException e) {
            throw e;
        } catch (Exception e) {
            throw new RuntimeException("Gemini API call failed", e);
        }

        return application;
    }

    // ---------------------------------------------------------------
    // BUILD REQUEST BODY
    // ---------------------------------------------------------------

    /**
     * Constructs the Gemini request JSON manually with StringBuilder,
     * consistent with the project's no-framework JSON approach.
     *
     * Uses generationConfig.responseMimeType = "application/json" so
     * the model returns bare JSON with no markdown fences.
     */
    private String buildRequestBody(String cvContent, String jobRequirements, byte[] cvPdfBytes) {
        String prompt = buildPrompt(cvContent, jobRequirements, cvPdfBytes != null);
        String escapedPrompt = escapeJson(prompt);

        // Build the parts array: optionally prepend the PDF, then the text prompt
        StringBuilder parts = new StringBuilder();
        if (cvPdfBytes != null && cvPdfBytes.length > 0) {
            String b64 = Base64.getEncoder().encodeToString(cvPdfBytes);
            parts.append("{\"inline_data\":{\"mime_type\":\"application/pdf\",\"data\":\"")
                 .append(b64)
                 .append("\"}},");
        }
        parts.append("{\"text\":\"").append(escapedPrompt).append("\"}");

        return "{"
            + "\"contents\":["
            +   "{"
            +     "\"parts\":[" + parts + "]"
            +   "}"
            + "],"
            + "\"generationConfig\":{"
            +   "\"responseMimeType\":\"application/json\","
            +   "\"temperature\":0.2,"
            +   "\"maxOutputTokens\":2048"
            + "}"
            + "}";
    }

    /**
     * Prompt template designed to produce stable, schema-compliant JSON
     * with exactly 4 fields every time.
     */
    private String buildPrompt(String cvContent, String jobRequirements, boolean hasPdf) {
        String cvSection = hasPdf
            ? "## Candidate CV\nThe candidate's full CV is provided as a PDF document above.\n"
              + "Additional context:\n" + cvContent
            : "## Candidate CV / Cover Letter\n" + cvContent;

        return "You are an expert academic recruiter evaluating a Teaching Assistant candidate.\n\n"
            + "## Job Requirements\n"
            + jobRequirements + "\n\n"
            + cvSection + "\n\n"
            + "## Task\n"
            + "Analyse how well this candidate matches the job requirements.\n"
            + "Return ONLY a single JSON object with EXACTLY these four keys:\n\n"
            + "{\n"
            + "  \"aiMatchScore\": <integer 0-100>,\n"
            + "  \"aiMatchedSkills\": \"<comma-separated skills present in both CV and requirements>\",\n"
            + "  \"aiMissingSkills\": \"<comma-separated skills required but absent from CV, or \\\"None\\\" if all matched>\",\n"
            + "  \"aiReasoning\": \"<2-3 sentence explanation of the score>\"\n"
            + "}\n\n"
            + "Scoring guide:\n"
            + "  90-100 = outstanding fit, almost all required skills present\n"
            + "  70-89  = good fit, minor gaps\n"
            + "  50-69  = partial fit, notable gaps\n"
            + "  0-49   = poor fit, significant required skills missing\n\n"
            + "Do NOT include any markdown, code fences, or extra fields. "
            + "Output the raw JSON object only.";
    }

    // ---------------------------------------------------------------
    // PARSE GEMINI RESPONSE
    // ---------------------------------------------------------------

    /**
     * Navigates the Gemini response envelope:
     *   candidates[0].content.parts[0].text
     * and returns the inner text string (which should already be JSON
     * thanks to responseMimeType).
     */
    private String extractTextFromResponse(String responseBody) {
        JsonObject root = gson.fromJson(responseBody, JsonObject.class);

        JsonArray candidates = root.getAsJsonArray("candidates");
        if (candidates == null || candidates.size() == 0) {
            throw new RuntimeException("No candidates in Gemini response: " + responseBody);
        }

        JsonObject content = candidates.get(0)
                .getAsJsonObject()
                .getAsJsonObject("content");

        JsonArray parts = content.getAsJsonArray("parts");
        if (parts == null || parts.size() == 0) {
            throw new RuntimeException("No parts in Gemini response content");
        }

        JsonElement textElement = parts.get(0).getAsJsonObject().get("text");
        if (textElement == null) {
            throw new RuntimeException("No text field in Gemini response part");
        }

        return textElement.getAsString().trim();
    }

    /**
     * Deserialises the inner JSON string returned by Gemini into the
     * four AI fields on the Application object.
     */
    private void populateApplication(Application app, String json) {
        JsonObject result = gson.fromJson(json, JsonObject.class);

        JsonElement scoreEl = result.get("aiMatchScore");
        if (scoreEl != null && !scoreEl.isJsonNull()) {
            app.setAiMatchScore(scoreEl.getAsInt());
        }

        JsonElement matchedEl = result.get("aiMatchedSkills");
        if (matchedEl != null && !matchedEl.isJsonNull()) {
            app.setAiMatchedSkills(matchedEl.getAsString());
        }

        JsonElement missingEl = result.get("aiMissingSkills");
        if (missingEl != null && !missingEl.isJsonNull()) {
            app.setAiMissingSkills(missingEl.getAsString());
        }

        JsonElement reasoningEl = result.get("aiReasoning");
        if (reasoningEl != null && !reasoningEl.isJsonNull()) {
            app.setAiReasoning(reasoningEl.getAsString());
        }
    }

    // ---------------------------------------------------------------
    // UTILITIES
    // ---------------------------------------------------------------

    /**
     * Fixes common issues in Gemini-generated JSON:
     * replaces literal newlines/tabs inside JSON string values with escape sequences.
     */
    private String sanitizeJsonString(String json) {
        if (json == null) return "{}";
        // Remove markdown code fences if present
        json = json.replaceAll("^```json\\s*", "").replaceAll("^```\\s*", "").replaceAll("```\\s*$", "").trim();
        // Replace literal newlines/tabs inside string values
        StringBuilder sb = new StringBuilder();
        boolean inString = false;
        boolean escape = false;
        for (int i = 0; i < json.length(); i++) {
            char c = json.charAt(i);
            if (escape) {
                sb.append(c);
                escape = false;
            } else if (c == '\\') {
                sb.append(c);
                escape = true;
            } else if (c == '"') {
                sb.append(c);
                inString = !inString;
            } else if (inString && c == '\n') {
                sb.append("\\n");
            } else if (inString && c == '\r') {
                sb.append("\\r");
            } else if (inString && c == '\t') {
                sb.append("\\t");
            } else {
                sb.append(c);
            }
        }
        return sb.toString();
    }

    /** Escapes a string so it can be safely embedded in a JSON value. */
    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }

    // ---------------------------------------------------------------
    // LOCAL TEST ENTRY POINT
    // ---------------------------------------------------------------

    /**
     * Run this main method directly in your IDE to smoke-test the API
     * integration before wiring it into the servlet layer.
     *
     * Before running, either:
     *   a) set the GEMINI_API_KEY environment variable in your run config, or
     *   b) temporarily replace API_KEY constant above with your real key.
     */
    public static void main(String[] args) {
        // --- Mock job requirements (mirrors seed data in DataStore) ---
        String jobRequirements =
                "Position: Software Engineering Lab Assessment TA (EBU6304)\n"
                + "Requirements:\n"
                + "- Strong Java skills\n"
                + "- Experience with Agile methods\n"
                + "- Code review experience\n"
                + "- Good communication skills\n"
                + "Hours: 6 hours/week, Full Academic Year";

        // --- Mock CV / cover letter ---
        String cvContent =
                "Name: Alice Chen\n"
                + "Education: BSc Computer Science, BUPT (GPA 3.8/4.0)\n"
                + "Skills: Java, Python, Spring Boot, Git, Unit Testing\n"
                + "Experience:\n"
                + "  - 1-year internship at a software company, participated in Agile sprints,\n"
                + "    daily stand-ups, and sprint retrospectives.\n"
                + "  - Conducted peer code reviews on 3 group projects.\n"
                + "  - Tutored 5 junior students in Java fundamentals.\n"
                + "Languages: Mandarin (native), English (fluent)\n"
                + "Cover letter: I am enthusiastic about guiding students through lab sessions "
                + "and believe my hands-on Agile and code-review background makes me a strong fit.";

        System.out.println("=== GeminiService Local Test ===");
        System.out.println("Sending request to Gemini API...\n");

        GeminiService service = new GeminiService();

        try {
            Application result = service.analyzeMatch(cvContent, jobRequirements);

            System.out.println("--- AI Analysis Result ---");
            System.out.println("Score         : " + result.getAiMatchScore());
            System.out.println("Matched Skills: " + result.getAiMatchedSkills());
            System.out.println("Missing Skills: " + result.getAiMissingSkills());
            System.out.println("Reasoning     : " + result.getAiReasoning());

        } catch (Exception e) {
            System.err.println("ERROR: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
