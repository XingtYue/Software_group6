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
 * matches a job's requirements, with workload penalty and competition-aware
 * redirection logic built into the prompt.
 */
public class GeminiService {

    private static final String API_KEY =
            System.getenv("GEMINI_API_KEY") != null
            ? System.getenv("GEMINI_API_KEY")
            : "YOUR_API_KEY_HERE";

    private static final String ENDPOINT =
            "https://generativelanguage.googleapis.com/v1beta/models/"
            + "gemini-2.5-flash:generateContent?key=" + API_KEY;

    private static final int TIMEOUT_SECONDS = 60;

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
     * Convenience overload — no PDF, no workload/competition context.
     */
    public Application analyzeMatch(String cvContent, String currentJobInfo) {
        return analyzeMatch(cvContent, currentJobInfo, null, 0, 0, 0, 1, false, "");
    }

    /**
     * Analyses CV-to-job fit.
     * <p>
     * Workload overload (>80 h) is evaluated locally:
     * if {@code applyWorkloadPenalty} is true (MO side) a strong warning is injected into
     * the prompt asking the AI to deduct points; on the TA side it is ignored.
     * <p>
     * Competition (applicants > openings*2) never adds a prompt warning — the AI
     * is simply given the other-jobs list and asked to recommend an alternative.
     *
     * @param applyWorkloadPenalty true = MO side (deduct for overload); false = TA side (no deduction)
     */
    public Application analyzeMatch(String cvContent,
                                    String currentJobInfo,
                                    byte[] cvPdfBytes,
                                    int currentWorkload,
                                    int applicantCount,
                                    int acceptedCount,
                                    int openings,
                                    boolean applyWorkloadPenalty,
                                    String otherAvailableJobs) {
        Application application = new Application();

        String requestBody = buildRequestBody(
                cvContent, currentJobInfo, cvPdfBytes,
                currentWorkload, applicantCount, acceptedCount, openings, applyWorkloadPenalty, otherAvailableJobs);

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
     * Builds the full JSON request body for the Gemini API, optionally embedding a
     * base64-encoded PDF as an inline data part before the text prompt.
     *
     * @param cvContent           plain-text CV / cover-letter content
     * @param currentJobInfo      formatted job requirements text
     * @param cvPdfBytes          raw PDF bytes to embed, or {@code null} for text-only
     * @param currentWorkload     the TA's current total committed hours
     * @param applicantCount      total number of applicants for this job
     * @param acceptedCount       number already accepted for this job
     * @param openings            maximum openings for this job
     * @param applyWorkloadPenalty {@code true} to instruct the AI to deduct for overload
     * @param otherAvailableJobs  formatted list of alternative jobs in the same course
     * @return the JSON request body string ready to POST to the Gemini endpoint
     */
    private String buildRequestBody(String cvContent,
                                    String currentJobInfo,
                                    byte[] cvPdfBytes,
                                    int currentWorkload,
                                    int applicantCount,
                                    int acceptedCount,
                                    int openings,
                                    boolean applyWorkloadPenalty,
                                    String otherAvailableJobs) {
        String prompt = buildPrompt(
                cvContent, currentJobInfo, cvPdfBytes != null,
                currentWorkload, applicantCount, acceptedCount, openings, applyWorkloadPenalty, otherAvailableJobs);
        String escapedPrompt = escapeJson(prompt);

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
            +   "\"maxOutputTokens\":4096"
            + "}"
            + "}";
    }

    /**
     * Builds the natural-language prompt sent to Gemini.
     * Injects a workload warning (MO-side only) and an alternative-job instruction
     * (TA-side only, when the position is highly competitive).
     *
     * @param cvContent           plain-text CV / cover-letter content
     * @param currentJobInfo      formatted job requirements text
     * @param hasPdf              {@code true} if a PDF was also attached
     * @param currentWorkload     the TA's current total committed hours
     * @param applicantCount      total number of applicants for this job
     * @param acceptedCount       number already accepted for this job
     * @param openings            maximum openings for this job
     * @param applyWorkloadPenalty {@code true} to inject the workload-penalty instruction
     * @param otherAvailableJobs  formatted list of alternative jobs in the same course
     * @return the complete prompt string
     */
    private String buildPrompt(String cvContent,
                               String currentJobInfo,
                               boolean hasPdf,
                               int currentWorkload,
                               int applicantCount,
                               int acceptedCount,
                               int openings,
                               boolean applyWorkloadPenalty,
                               String otherAvailableJobs) {

        // ── Local pre-computation ─────────────────────────────────────────────
        boolean overloaded        = applyWorkloadPenalty && currentWorkload > 80;
        int effectiveOpenings     = openings > 0 ? openings : 1;
        boolean highlyCompetitive = applicantCount > effectiveOpenings * 2;

        String cvSection = hasPdf
            ? "## Candidate CV\nThe candidate's full CV is provided as a PDF document above.\n"
              + "Additional context:\n" + cvContent
            : "## Candidate CV / Cover Letter\n" + cvContent;

        boolean hasOtherJobs = otherAvailableJobs != null && !otherAvailableJobs.isBlank();
        String otherJobsSection = hasOtherJobs
            ? "## Other Open Positions in the Same Course\n" + otherAvailableJobs
            : "## Other Open Positions in the Same Course\nNone provided.";

        // ── Workload warning (MO side only, injected when overloaded) ─────────
        String workloadWarning = overloaded
            ? "\n## 注意 — 工作量严重超标\n"
              + "该候选人目前已承担 " + currentWorkload + " 小时的TA工作量，"
              + "已严重超出合理上限（80小时），这将显著影响其工作状态与质量。\n"
              + "请在评分时适度扣分（扣除10–20分），并在aiReasoning中注明原因，例如：\n"
              + "  \"该候选人当前工作量（" + currentWorkload + " h）已超出80小时上限，扣除Y分。\"\n"
            : "";

        // ── Alternative job instruction (TA side only) ────────────────────────
        String altJobInstruction = (!applyWorkloadPenalty && highlyCompetitive && hasOtherJobs)
            ? "## Step 3 — Recommend an alternative job\n"
              + "This position is highly competitive. Review the 'Other Open Positions' list above.\n"
              + "If any position is a better or equally good fit for this candidate's skills "
              + "AND still has remaining capacity (accepted < openings), set "
              + "aiRecommendedAlternativeJob to that position's title. "
              + "Otherwise set aiRecommendedAlternativeJob to \"\".\n\n"
            : "## Step 3 — Recommended alternative job\n"
              + "Set aiRecommendedAlternativeJob to \"\".\n\n";

        return "You are an expert academic recruiter evaluating a Teaching Assistant (TA) candidate.\n\n"
            + "## Target Job Information\n"
            + currentJobInfo + "\n\n"
            + cvSection + "\n\n"
            + workloadWarning
            + otherJobsSection + "\n\n"

            + "## Step 1 — Compute a base match score (0–100)\n"
            + "Evaluate purely on skills, experience, and requirements:\n"
            + "  90-100 = outstanding fit, almost all required skills present\n"
            + "  70-89  = good fit, minor gaps\n"
            + "  50-69  = partial fit, notable gaps\n"
            + "  0-49   = poor fit, significant required skills missing\n\n"

            + "## Step 2 — Apply workload deduction (if instructed above)\n"
            + (overloaded
                ? "A workload warning was issued above. Apply the deduction and reflect it in aiMatchScore.\n\n"
                : "No workload deduction needed. Use the base score.\n\n")

            + altJobInstruction

            + "## Output\n"
            + "Return ONLY a single flat JSON object with EXACTLY these five keys "
            + "(no markdown, no code fences, no extra fields):\n\n"
            + "{\n"
            + "  \"aiMatchScore\": <integer 0-100, after any workload deduction>,\n"
            + "  \"aiMatchedSkills\": \"<comma-separated skills present in both CV and requirements>\",\n"
            + "  \"aiMissingSkills\": \"<comma-separated required skills absent from CV, or \\\"None\\\">\",\n"
            + "  \"aiReasoning\": \"<2-4 sentences: score justification; mention workload deduction if applied>\",\n"
            + "  \"aiRecommendedAlternativeJob\": \"<title of recommended alternative position, or empty string>\"\n"
            + "}";
    }

    // ---------------------------------------------------------------
    // PARSE GEMINI RESPONSE
    // ---------------------------------------------------------------

    /**
     * Extracts the text content from a Gemini API response body, skipping any
     * internal "thought" parts produced by the model's reasoning process.
     *
     * @param responseBody the raw JSON response body from the Gemini API
     * @return the trimmed text of the first non-thought part
     * @throws RuntimeException if no usable text part is found
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

        // gemini-2.5-flash returns thinking parts first (thought:true); skip them
        for (JsonElement partEl : parts) {
            JsonObject part = partEl.getAsJsonObject();
            JsonElement thoughtEl = part.get("thought");
            if (thoughtEl != null && !thoughtEl.isJsonNull() && thoughtEl.getAsBoolean()) {
                continue;
            }
            JsonElement textEl = part.get("text");
            if (textEl != null && !textEl.isJsonNull()) {
                return textEl.getAsString().trim();
            }
        }

        throw new RuntimeException("No non-thought text part found in Gemini response");
    }

    /**
     * Parses the five expected AI result fields from the JSON string returned by Gemini
     * and populates the given {@link Application} object.
     *
     * @param app  the application to populate
     * @param json the sanitized JSON string containing the AI result fields
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

        // Safe handling: field may be absent, null, or an explicit empty string
        JsonElement altJobEl = result.get("aiRecommendedAlternativeJob");
        if (altJobEl != null && !altJobEl.isJsonNull()) {
            app.setAiRecommendedAlternativeJob(altJobEl.getAsString());
        } else {
            app.setAiRecommendedAlternativeJob("");
        }
    }

    // ---------------------------------------------------------------
    // UTILITIES
    // ---------------------------------------------------------------

    /**
     * Strips Markdown code fences, escapes bare control characters inside JSON strings,
     * and attempts to repair common truncation issues (unclosed string or missing closing brace).
     *
     * @param json the raw JSON text from the API (may contain Markdown fences or control chars)
     * @return a best-effort valid JSON string, or {@code "{}"} if input is {@code null}
     */
    private String sanitizeJsonString(String json) {
        if (json == null) return "{}";
        json = json.replaceAll("^```json\\s*", "").replaceAll("^```\\s*", "").replaceAll("```\\s*$", "").trim();
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
            } else if (inString && c < 0x20) {
                switch (c) {
                    case '\n': sb.append("\\n"); break;
                    case '\r': sb.append("\\r"); break;
                    case '\t': sb.append("\\t"); break;
                    default: break; // drop other control chars
                }
            } else {
                sb.append(c);
            }
        }
        // Recovery: handles truncated responses (unclosed string or object)
        if (inString) sb.append('"');
        String s = sb.toString().trim();
        if (s.startsWith("{") && !s.endsWith("}")) s = s + "}";
        return s;
    }

    /**
     * Escapes a string for safe embedding inside a JSON double-quoted value.
     *
     * @param s the raw string (may be {@code null})
     * @return JSON-safe escaped string, or {@code ""} if input is {@code null}
     */
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
     * Extreme test case: candidate is already at 45 h workload (above 40 h threshold)
     * AND the target position is completely full (3 accepted out of 3 needed), with a
     * high applicant-to-accepted ratio.  Expect:
     *   - workload penalty applied in aiMatchScore
     *   - aiReasoning mentions overload
     *   - aiRecommendedAlternativeJob points to a less-contested opening
     *
     * Before running: set GEMINI_API_KEY env var, or replace the constant above.
     */
    public static void main(String[] args) {

        String currentJobInfo =
                "Position: Software Engineering Lab Assessment TA (EBU6304)\n"
                + "Requirements:\n"
                + "- Strong Java skills\n"
                + "- Experience with Agile methods\n"
                + "- Code review experience\n"
                + "- Good communication skills\n"
                + "Openings: 3\n"
                + "Hours: 6 hours/week, Full Academic Year";

        String cvContent =
                "Name: Alice Chen\n"
                + "Education: BSc Computer Science, BUPT (GPA 3.8/4.0)\n"
                + "Skills: Java, Python, Spring Boot, Git, Unit Testing\n"
                + "Experience:\n"
                + "  - 1-year internship; Agile sprints, daily stand-ups, sprint retrospectives.\n"
                + "  - Conducted peer code reviews on 3 group projects.\n"
                + "  - Tutored 5 junior students in Java fundamentals.\n"
                + "Languages: Mandarin (native), English (fluent)\n"
                + "Cover letter: I am enthusiastic about guiding students through lab sessions.";

        // Extreme mock values:
        int currentWorkload = 45;   // 5 h over the 40 h threshold → penalty expected
        int applicantCount  = 32;   // 32 applicants for 3 slots → very competitive
        int acceptedCount   = 3;    // already full

        String otherAvailableJobs =
                "1. Data Structures & Algorithms TA (EBU5476)\n"
                + "   Requirements: Python, algorithm analysis, graph theory\n"
                + "   Accepted so far: 0 / Openings: 2\n\n"
                + "2. Mobile App Development TA (EBU6402)\n"
                + "   Requirements: Android/iOS, Kotlin or Swift, UI design\n"
                + "   Accepted so far: 1 / Openings: 3\n\n"
                + "3. Database Systems Lab TA (EBU5316)\n"
                + "   Requirements: SQL, ER modelling, query optimisation\n"
                + "   Accepted so far: 0 / Openings: 2";

        System.out.println("=== GeminiService Local Test (Extreme Case) ===");
        System.out.println("currentWorkload : " + currentWorkload + " h  (threshold = 40 h)");
        System.out.println("applicantCount  : " + applicantCount);
        System.out.println("acceptedCount   : " + acceptedCount + " / 3 openings (position FULL)");
        System.out.println("Sending request to Gemini API...\n");

        GeminiService service = new GeminiService();

        try {
            Application result = service.analyzeMatch(
                    cvContent, currentJobInfo, null,
                    currentWorkload, applicantCount, acceptedCount, 3, true, otherAvailableJobs);

            System.out.println("--- AI Analysis Result ---");
            System.out.println("Score                    : " + result.getAiMatchScore());
            System.out.println("Matched Skills           : " + result.getAiMatchedSkills());
            System.out.println("Missing Skills           : " + result.getAiMissingSkills());
            System.out.println("Reasoning                : " + result.getAiReasoning());
            System.out.println("Recommended Alternative  : " + result.getAiRecommendedAlternativeJob());

        } catch (Exception e) {
            System.err.println("ERROR: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
