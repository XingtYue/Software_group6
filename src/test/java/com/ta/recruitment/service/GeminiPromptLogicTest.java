package com.ta.recruitment.service;

import org.junit.jupiter.api.*;
import java.lang.reflect.*;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Tests for GeminiService's LOCAL pre-computation logic —
 * specifically the workload-penalty decision and the competition-ratio
 * decision that are computed *before* any HTTP call is made.
 *
 * These tests use reflection to invoke the private buildPrompt() method
 * directly, so no Gemini API key or network access is required.
 *
 * Invariants under test (from GeminiService.java):
 *   - overloaded = applyWorkloadPenalty && currentWorkload > 80
 *   - highlyCompetitive = applicantCount > effectiveOpenings * 2
 *   - Workload warning section is injected into the prompt ONLY when overloaded.
 *   - Alternative-job instruction is injected ONLY when:
 *       !applyWorkloadPenalty && highlyCompetitive && hasOtherJobs
 */
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
class GeminiPromptLogicTest {

    private GeminiService service;
    private Method buildPromptMethod;

    // Shared fixture strings — mirror what MOServlet / TAServlet would pass
    private static final String JOB_INFO =
            "Job Title: Data Structures EBU5476 - Lab Assessment TA\n"
            + "Course: Data Structures EBU5476 (EBU5476)\n"
            + "Position Type: Lab Assessment\n"
            + "Description: Help students during lab sessions.\n"
            + "Openings (total positions needed): 2\n";

    private static final String CV_CONTENT =
            "Name: Test TA\n"
            + "Department: Computer Science\n"
            + "CV Content: Java, C++, algorithms, data structures, tutoring.";

    private static final String OTHER_JOBS =
            "- Data Structures EBU5476 - Assignment Grading TA (Assignment Grading), "
            + "openings: 2, accepted: 0, applicants: 3\n";

    @BeforeEach
    void setUp() throws Exception {
        service = new GeminiService();

        // Expose the private buildPrompt method
        buildPromptMethod = GeminiService.class.getDeclaredMethod(
                "buildPrompt",
                String.class,  // cvContent
                String.class,  // currentJobInfo
                boolean.class, // hasPdf
                int.class,     // currentWorkload
                int.class,     // applicantCount
                int.class,     // acceptedCount
                int.class,     // openings
                boolean.class, // applyWorkloadPenalty
                String.class   // otherAvailableJobs
        );
        buildPromptMethod.setAccessible(true);
    }

    // Convenience wrapper to reduce boilerplate in each test
    private String buildPrompt(int workload, int applicants, int accepted,
                               int openings, boolean applyPenalty, String otherJobs)
            throws Exception {
        return (String) buildPromptMethod.invoke(
                service,
                CV_CONTENT, JOB_INFO,
                false,          // hasPdf
                workload, applicants, accepted, openings,
                applyPenalty,
                otherJobs
        );
    }

    // ------------------------------------------------------------------
    // TC-AI-01: Workload OVER threshold (81 h) on MO side — penalty injected
    // ------------------------------------------------------------------

    @Test
    @Order(1)
    @DisplayName("TC-AI-01: workload 81 h on MO side (applyPenalty=true) → warning injected")
    void prompt_workloadOver80_MOSide_penaltyInjected() throws Exception {
        String prompt = buildPrompt(81, 5, 1, 2, true, "");

        // The Chinese-language overload section must appear
        assertTrue(prompt.contains("注意 — 工作量严重超标"),
            "Prompt must contain the overload warning header");
        assertTrue(prompt.contains("81 小时"),
            "Prompt must state the actual workload figure (81 h)");
        assertTrue(prompt.contains("80小时"),
            "Prompt must reference the 80-hour limit");
        // The deduction instruction to the AI should also be present
        assertTrue(prompt.contains("扣分") || prompt.contains("扣除"),
            "Prompt must instruct Gemini to deduct points");
    }

    // ------------------------------------------------------------------
    // TC-AI-02: Workload exactly AT threshold (80 h) — no penalty
    // Boundary: the condition is strictly > 80, so 80 h must NOT trigger it.
    // ------------------------------------------------------------------

    @Test
    @Order(2)
    @DisplayName("TC-AI-02: workload exactly 80 h → boundary value, no penalty injected")
    void prompt_workloadExactly80_boundaryValue_noPenalty() throws Exception {
        String prompt = buildPrompt(80, 5, 1, 2, true, "");

        assertFalse(prompt.contains("注意 — 工作量严重超标"),
            "80 h is NOT strictly > 80, so the overload warning must NOT appear");
        // Normal Step-2 instruction should still be present
        assertTrue(prompt.contains("No workload deduction needed"),
            "Without overload the prompt should say no deduction is needed");
    }

    // ------------------------------------------------------------------
    // TC-AI-03: Workload OVER threshold but on TA side (applyPenalty=false) —
    //           no penalty regardless of workload value.
    // ------------------------------------------------------------------

    @Test
    @Order(3)
    @DisplayName("TC-AI-03: workload 85 h on TA side (applyPenalty=false) → NO penalty")
    void prompt_workloadOver80_TASide_noPenalty() throws Exception {
        String prompt = buildPrompt(85, 5, 1, 2, false, "");

        assertFalse(prompt.contains("注意 — 工作量严重超标"),
            "TA-side analysis must never inject the workload penalty regardless of hours");
    }

    // ------------------------------------------------------------------
    // TC-AI-04: High competition on TA side → alternative-job section injected
    // highlyCompetitive: applicants(9) > openings(2) × 2  →  9 > 4  →  true
    // ------------------------------------------------------------------

    @Test
    @Order(4)
    @DisplayName("TC-AI-04: competitive ratio (9 applicants / 2 openings) on TA side → alt-job recommended")
    void prompt_highlyCompetitive_TASide_altJobInstructionInjected() throws Exception {
        String prompt = buildPrompt(30, 9, 0, 2, false, OTHER_JOBS);

        assertTrue(prompt.contains("highly competitive"),
            "Prompt must flag the position as highly competitive");
        assertTrue(prompt.contains("aiRecommendedAlternativeJob"),
            "Prompt must instruct the model to populate the alternative-job field");
        // The other-jobs list itself must be forwarded to the model
        assertTrue(prompt.contains("Data Structures EBU5476 - Assignment Grading TA"),
            "Prompt must include the other available jobs for comparison");
    }

    // ------------------------------------------------------------------
    // TC-AI-05: NOT competitive on TA side — alternative-job section suppressed.
    // applicants(3) > openings(2) × 2 = 4  →  3 > 4  →  false
    // ------------------------------------------------------------------

    @Test
    @Order(5)
    @DisplayName("TC-AI-05: low competition (3 applicants / 2 openings) → alt-job field set to empty")
    void prompt_lowCompetition_TASide_noAltJobInstruction() throws Exception {
        String prompt = buildPrompt(30, 3, 0, 2, false, OTHER_JOBS);

        // When not competitive the fallback instruction is used — alt-job should be set to ""
        assertTrue(prompt.contains("aiRecommendedAlternativeJob to \\\"\\\"")
                || prompt.contains("Set aiRecommendedAlternativeJob to \"\""),
            "Non-competitive prompt must instruct model to return an empty alt-job string");
        assertFalse(prompt.contains("highly competitive"),
            "Prompt must NOT flag the position as highly competitive when the ratio is low");
    }

    // ------------------------------------------------------------------
    // TC-AI-06: High competition on MO side (applyPenalty=true) —
    //           the alternative-job instruction must NOT appear on MO side.
    // ------------------------------------------------------------------

    @Test
    @Order(6)
    @DisplayName("TC-AI-06: high competition on MO side → no alternative-job recommendation")
    void prompt_highlyCompetitive_MOSide_noAltJobInstruction() throws Exception {
        // applicants(9) > openings(2)×2 = 4, but applyWorkloadPenalty=true (MO side)
        String prompt = buildPrompt(30, 9, 0, 2, true, OTHER_JOBS);

        assertFalse(prompt.contains("highly competitive"),
            "MO-side prompt must never contain the alternative-job competitive instruction");
    }

    // ------------------------------------------------------------------
    // TC-AI-07: Both penalty AND competition active (MO side, overloaded) —
    //           verify both overload warning appears and no alt-job instruction.
    // ------------------------------------------------------------------

    @Test
    @Order(7)
    @DisplayName("TC-AI-07: overloaded (85 h) + high competition on MO side → penalty present, no alt-job")
    void prompt_overloadedAndCompetitive_MOSide_onlyPenaltyPresent() throws Exception {
        String prompt = buildPrompt(85, 10, 0, 2, true, OTHER_JOBS);

        // Overload warning must appear
        assertTrue(prompt.contains("注意 — 工作量严重超标"),
            "Overloaded MO-side prompt must contain the workload warning");
        assertTrue(prompt.contains("85 小时"),
            "Prompt must show the actual workload value (85 h)");

        // Alt-job instruction must NOT appear (MO side never gets it)
        assertFalse(prompt.contains("highly competitive"),
            "MO-side prompt must not contain the competitive alternative-job instruction");
    }

    // ------------------------------------------------------------------
    // TC-AI-08: Output format — regardless of settings, required JSON keys
    //           must always be present in the prompt's output spec.
    // ------------------------------------------------------------------

    @Test
    @Order(8)
    @DisplayName("TC-AI-08: output spec always includes all five required JSON keys")
    void prompt_outputSpec_alwaysContainsAllFiveKeys() throws Exception {
        // Run with both normal and penalty scenarios
        for (boolean penalty : new boolean[]{true, false}) {
            String prompt = buildPrompt(50, 3, 0, 2, penalty, "");

            assertTrue(prompt.contains("\"aiMatchScore\""),
                "Prompt output spec must include aiMatchScore");
            assertTrue(prompt.contains("\"aiMatchedSkills\""),
                "Prompt output spec must include aiMatchedSkills");
            assertTrue(prompt.contains("\"aiMissingSkills\""),
                "Prompt output spec must include aiMissingSkills");
            assertTrue(prompt.contains("\"aiReasoning\""),
                "Prompt output spec must include aiReasoning");
            assertTrue(prompt.contains("\"aiRecommendedAlternativeJob\""),
                "Prompt output spec must include aiRecommendedAlternativeJob");
        }
    }
}
