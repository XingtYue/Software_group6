package com.ta.recruitment.model;

import org.junit.jupiter.api.*;
import java.lang.reflect.*;
import java.nio.file.*;
import java.util.*;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Tests for the DataStore's JSON response-parsing and persistence helpers.
 *
 * Covers:
 *   - parseDurationWeekCount()  — private helper, tested via reflection
 *   - updateApplicationAiResult() — public method, persists AI fields
 *   - countApplicationsInSameCourse() — public method, used by duplicate guards
 *   - User status toggling and persistence
 */
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
class DataStorePersistenceTest {

    private static Path tempDir;
    private DataStore ds;
    private Method parseDurationMethod;

    @BeforeAll
    static void createTempDir() throws Exception {
        tempDir = Files.createTempDirectory("ds_persist_test_");
    }

    @AfterAll
    static void cleanUp() throws Exception {
        Files.walk(tempDir)
             .sorted(Comparator.reverseOrder())
             .map(Path::toFile)
             .forEach(f -> f.delete());
    }

    @BeforeEach
    void freshInstance() throws Exception {
        // Reset singleton
        Field instanceField = DataStore.class.getDeclaredField("instance");
        instanceField.setAccessible(true);
        instanceField.set(null, null);

        ds = DataStore.getInstance();
        ds.init(tempDir.resolve("persist_" + System.nanoTime()).toString());

        // Expose parseDurationWeekCount for direct testing
        parseDurationMethod = DataStore.class.getDeclaredMethod(
                "parseDurationWeekCount", String.class);
        parseDurationMethod.setAccessible(true);
    }

    private int parseDuration(String input) throws Exception {
        return (int) parseDurationMethod.invoke(ds, input);
    }

    // Helper to inject a User directly into the in-memory list
    private void injectUser(User u) throws Exception {
        Field f = DataStore.class.getDeclaredField("users");
        f.setAccessible(true);
        @SuppressWarnings("unchecked")
        List<User> users = (List<User>) f.get(ds);
        users.removeIf(x -> x.getId().equals(u.getId()));
        users.add(u);
    }

    private void injectApplication(Application a) throws Exception {
        Field f = DataStore.class.getDeclaredField("applications");
        f.setAccessible(true);
        @SuppressWarnings("unchecked")
        List<Application> apps = (List<Application>) f.get(ds);
        apps.add(a);
    }

    // ------------------------------------------------------------------
    // TC-PARSE-01 to 05: parseDurationWeekCount() — boundary cases
    // ------------------------------------------------------------------

    @Test
    @Order(1)
    @DisplayName("TC-PARSE-01: '5,6,7' → 3 weeks")
    void parseDuration_threeCommaSeparatedWeeks() throws Exception {
        assertEquals(3, parseDuration("5,6,7"));
    }

    @Test
    @Order(2)
    @DisplayName("TC-PARSE-02: '1,2,3,4,5,6,7,8,9' → 9 weeks")
    void parseDuration_nineCommaSeparatedWeeks() throws Exception {
        assertEquals(9, parseDuration("1,2,3,4,5,6,7,8,9"));
    }

    @Test
    @Order(3)
    @DisplayName("TC-PARSE-03: single week '15' → 1 week")
    void parseDuration_singleWeek() throws Exception {
        assertEquals(1, parseDuration("15"));
    }

    @Test
    @Order(4)
    @DisplayName("TC-PARSE-04: legacy text 'Full Academic Year' → 18 weeks fallback")
    void parseDuration_legacyFullAcademicYear() throws Exception {
        assertEquals(18, parseDuration("Full Academic Year"));
    }

    @Test
    @Order(5)
    @DisplayName("TC-PARSE-05: null / empty input → defaults to 1 to avoid divide-by-zero")
    void parseDuration_nullOrEmpty_defaultsToOne() throws Exception {
        assertEquals(1, parseDuration(null));
        assertEquals(1, parseDuration(""));
        assertEquals(1, parseDuration("   "));
    }

    // ------------------------------------------------------------------
    // TC-PERSIST-01: updateApplicationAiResult() — AI fields written correctly
    // ------------------------------------------------------------------

    @Test
    @Order(6)
    @DisplayName("TC-PERSIST-01: AI result fields are stored and retrievable")
    void updateApplicationAiResult_fieldsPersistedCorrectly() throws Exception {
        // Arrange
        Application app = new Application();
        app.setId("ai_app_01");
        app.setJobId("99");
        app.setTaId("ta_ai01");
        app.setStatus("pending");
        injectApplication(app);

        // Act
        ds.updateApplicationAiResult(
                "ai_app_01",
                87,
                "Java, OOP, Maven",
                "Docker, Kubernetes",
                "Strong Java background; workload is within limits.",
                "Data Structures EBU5476 - Assignment Grading TA"
        );

        // Assert
        Application saved = ds.findApplicationById("ai_app_01");
        assertNotNull(saved);
        assertEquals(87,             saved.getAiMatchScore());
        assertEquals("Java, OOP, Maven",   saved.getAiMatchedSkills());
        assertEquals("Docker, Kubernetes", saved.getAiMissingSkills());
        assertTrue(saved.getAiReasoning().contains("Strong Java background"));
        assertEquals("Data Structures EBU5476 - Assignment Grading TA",
                     saved.getAiRecommendedAlternativeJob());
    }

    // ------------------------------------------------------------------
    // TC-PERSIST-02: countApplicationsInSameCourse() — counts correctly
    // ------------------------------------------------------------------

    @Test
    @Order(7)
    @DisplayName("TC-PERSIST-02: countApplicationsInSameCourse counts only matching TA+course")
    void countApplicationsInSameCourse_onlyCountsMatchingTaAndCourse() throws Exception {
        // Arrange: TA applies to 2 jobs in EBU5476, 1 job in EBU6304
        Application a1 = new Application();
        a1.setId("c_app1"); a1.setJobId("10"); a1.setTaId("ta_count");
        a1.setCourseCode("EBU5476"); a1.setStatus("pending");
        injectApplication(a1);

        Application a2 = new Application();
        a2.setId("c_app2"); a2.setJobId("11"); a2.setTaId("ta_count");
        a2.setCourseCode("EBU5476"); a2.setStatus("pending");
        injectApplication(a2);

        Application a3 = new Application();
        a3.setId("c_app3"); a3.setJobId("12"); a3.setTaId("ta_count");
        a3.setCourseCode("EBU6304"); a3.setStatus("pending");
        injectApplication(a3);

        // Another TA with the same course — must NOT be counted
        Application a4 = new Application();
        a4.setId("c_app4"); a4.setJobId("10"); a4.setTaId("ta_other");
        a4.setCourseCode("EBU5476"); a4.setStatus("pending");
        injectApplication(a4);

        // Assert
        assertEquals(2, ds.countApplicationsInSameCourse("ta_count", "EBU5476"),
            "ta_count should have 2 applications in EBU5476");
        assertEquals(1, ds.countApplicationsInSameCourse("ta_count", "EBU6304"),
            "ta_count should have 1 application in EBU6304");
        assertEquals(0, ds.countApplicationsInSameCourse("ta_count", "EBU6301"),
            "ta_count should have 0 applications in a course they haven't applied to");
        assertEquals(1, ds.countApplicationsInSameCourse("ta_other", "EBU5476"),
            "ta_other should have 1 application in EBU5476");
    }

    // ------------------------------------------------------------------
    // TC-PERSIST-03: setUserStatus() — toggling active/inactive persisted
    // ------------------------------------------------------------------

    @Test
    @Order(8)
    @DisplayName("TC-PERSIST-03: setUserStatus toggles status and persists to users list")
    void setUserStatus_togglesAndPersists() throws Exception {
        User ta = new User("ta_status01", "Status Test", "st@test.com", "pw", "ta");
        assertEquals("active", ta.getStatus());
        injectUser(ta);

        // Deactivate
        ds.setUserStatus("ta_status01", "inactive");
        assertEquals("inactive", ds.findUserById("ta_status01").getStatus());

        // Re-activate
        ds.setUserStatus("ta_status01", "active");
        assertEquals("active", ds.findUserById("ta_status01").getStatus());
    }

    // ------------------------------------------------------------------
    // TC-PERSIST-04: findUserByEmail() — case-insensitive lookup
    // ------------------------------------------------------------------

    @Test
    @Order(9)
    @DisplayName("TC-PERSIST-04: findUserByEmail is case-insensitive")
    void findUserByEmail_caseInsensitiveLookup() throws Exception {
        User ta = new User("ta_email01", "Email Test", "MYEMAIL@BUPT.EDU.CN", "pw", "ta");
        injectUser(ta);

        assertNotNull(ds.findUserByEmail("myemail@bupt.edu.cn"),
            "Lowercase lookup must find an uppercase-stored email");
        assertNotNull(ds.findUserByEmail("MYEMAIL@BUPT.EDU.CN"),
            "Uppercase lookup must also match");
        assertNull(ds.findUserByEmail("nonexistent@bupt.edu.cn"),
            "Non-existent email must return null");
    }
}
