package com.ta.recruitment.model;

import org.junit.jupiter.api.*;
import java.lang.reflect.*;
import java.nio.file.*;
import java.util.*;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Tests for DataStore workload calculation logic.
 *
 * DataStore is a singleton that writes to disk, so each test:
 *   1. Resets the singleton via reflection so there's no shared state.
 *   2. Initialises a fresh instance pointing at a temporary directory,
 *      so no real WEB-INF/data/ files are ever touched.
 *
 * The primary target is recalcAndSaveWorkload(), which is private and is
 * exercised indirectly through updateApplicationStatus().
 */
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
class DataStoreWorkloadTest {

    private static Path tempDir;
    private DataStore ds;

    // ------------------------------------------------------------------
    // Lifecycle
    // ------------------------------------------------------------------

    @BeforeAll
    static void createTempDir() throws Exception {
        tempDir = Files.createTempDirectory("ds_test_");
    }

    @AfterAll
    static void deleteTempDir() throws Exception {
        // Best-effort cleanup of the temp directory
        Files.walk(tempDir)
             .sorted(Comparator.reverseOrder())
             .map(Path::toFile)
             .forEach(f -> f.delete());
    }

    @BeforeEach
    void freshInstance() throws Exception {
        // Reset the singleton so each test gets a clean DataStore
        Field instanceField = DataStore.class.getDeclaredField("instance");
        instanceField.setAccessible(true);
        instanceField.set(null, null);

        ds = DataStore.getInstance();
        // Point at a fresh temp directory — no JSON files yet, so seed data is used
        ds.init(tempDir.resolve("data_" + System.nanoTime()).toString());
    }

    // ------------------------------------------------------------------
    // Helper: build a minimal Job and register it in the store via reflection
    // so we don't go through the full addJob() path (which generates IDs).
    // ------------------------------------------------------------------

    private void injectJob(String jobId, String hours, String duration, int openings) throws Exception {
        Job j = new Job();
        j.setId(jobId + "_internal");
        j.setJobId(jobId);
        j.setTitle("Test Job " + jobId);
        j.setHours(hours);
        j.setDuration(duration);
        j.setOpenings(openings);
        j.setStatus("active");

        Field jobsField = DataStore.class.getDeclaredField("jobs");
        jobsField.setAccessible(true);
        @SuppressWarnings("unchecked")
        List<Job> jobs = (List<Job>) jobsField.get(ds);
        jobs.add(j);
    }

    private void injectUser(User u) throws Exception {
        Field usersField = DataStore.class.getDeclaredField("users");
        usersField.setAccessible(true);
        @SuppressWarnings("unchecked")
        List<User> users = (List<User>) usersField.get(ds);
        // Replace if already present (seed data may have the same id)
        users.removeIf(existing -> existing.getId().equals(u.getId()));
        users.add(u);
    }

    private void injectApplication(Application a) throws Exception {
        Field appsField = DataStore.class.getDeclaredField("applications");
        appsField.setAccessible(true);
        @SuppressWarnings("unchecked")
        List<Application> apps = (List<Application>) appsField.get(ds);
        apps.add(a);
    }

    // ------------------------------------------------------------------
    // TC-DS-01: Standard workload — comma-separated duration "5,6,7"
    // Expected: 3 weeks × 4 h/week = 12 h
    // ------------------------------------------------------------------

    @Test
    @Order(1)
    @DisplayName("TC-DS-01: duration '5,6,7' × 4 h/week = 12 h")
    void workloadCalculation_commaSeparatedDuration_threeWeeks() throws Exception {
        // Arrange
        User ta = new User("ta_wl01", "Test TA 01", "ta01@test.com", "pw", "ta");
        injectUser(ta);
        injectJob("j_wl01", "4", "5,6,7", 2);

        Application app = new Application();
        app.setId("app_wl01");
        app.setJobId("j_wl01");
        app.setTaId("ta_wl01");
        app.setStatus("pending");
        injectApplication(app);

        // Act — accepting the application triggers recalcAndSaveWorkload()
        ds.updateApplicationStatus("app_wl01", "accepted");

        // Assert
        User result = ds.findUserById("ta_wl01");
        assertNotNull(result);
        assertEquals(12, result.getWorkload(),
            "4 h/week × 3 weeks (5,6,7) should equal 12 h");
    }

    // ------------------------------------------------------------------
    // TC-DS-02: Longer duration — "1,2,3,4,5,6,7,8,9" (9 weeks) × 6 h/week = 54 h
    // This mirrors the real Job 5 (EBU5476 Lab Assessment) in the live data.
    // ------------------------------------------------------------------

    @Test
    @Order(2)
    @DisplayName("TC-DS-02: duration '1,2,3,4,5,6,7,8,9' × 6 h/week = 54 h")
    void workloadCalculation_nineWeekDuration() throws Exception {
        // Arrange
        User ta = new User("ta_wl02", "Test TA 02", "ta02@test.com", "pw", "ta");
        injectUser(ta);
        injectJob("j_wl02", "6", "1,2,3,4,5,6,7,8,9", 2);

        Application app = new Application();
        app.setId("app_wl02");
        app.setJobId("j_wl02");
        app.setTaId("ta_wl02");
        app.setStatus("pending");
        injectApplication(app);

        // Act
        ds.updateApplicationStatus("app_wl02", "accepted");

        // Assert
        assertEquals(54, ds.findUserById("ta_wl02").getWorkload(),
            "6 h/week × 9 weeks should equal 54 h");
    }

    // ------------------------------------------------------------------
    // TC-DS-03: Multi-job accumulation — two accepted positions add up correctly.
    // Job A: 4 h × 6 weeks = 24 h
    // Job B: 6 h × 9 weeks = 54 h
    // Total expected: 78 h
    // ------------------------------------------------------------------

    @Test
    @Order(3)
    @DisplayName("TC-DS-03: two accepted jobs accumulate to 78 h total")
    void workloadCalculation_multipleAcceptedJobs_accumulatesCorrectly() throws Exception {
        // Arrange
        User ta = new User("ta_wl03", "Test TA 03", "ta03@test.com", "pw", "ta");
        injectUser(ta);

        injectJob("j_wl03a", "4", "5,6,7,13,14,15", 2);   // 6 weeks × 4 h = 24 h
        injectJob("j_wl03b", "6", "1,2,3,4,5,6,7,8,9", 2); // 9 weeks × 6 h = 54 h

        Application appA = new Application();
        appA.setId("app_wl03a"); appA.setJobId("j_wl03a");
        appA.setTaId("ta_wl03"); appA.setStatus("pending");
        injectApplication(appA);

        Application appB = new Application();
        appB.setId("app_wl03b"); appB.setJobId("j_wl03b");
        appB.setTaId("ta_wl03"); appB.setStatus("pending");
        injectApplication(appB);

        // Act — accept both
        ds.updateApplicationStatus("app_wl03a", "accepted");
        ds.updateApplicationStatus("app_wl03b", "accepted");

        // Assert
        assertEquals(78, ds.findUserById("ta_wl03").getWorkload(),
            "24 h + 54 h should accumulate to 78 h");
    }

    // ------------------------------------------------------------------
    // TC-DS-04: Rejecting an accepted application reduces workload back to 0.
    // ------------------------------------------------------------------

    @Test
    @Order(4)
    @DisplayName("TC-DS-04: rejecting an accepted application recalculates workload to 0")
    void workloadCalculation_rejectAcceptedApp_resetsWorkload() throws Exception {
        // Arrange
        User ta = new User("ta_wl04", "Test TA 04", "ta04@test.com", "pw", "ta");
        injectUser(ta);
        injectJob("j_wl04", "6", "5,6,7", 2);

        Application app = new Application();
        app.setId("app_wl04");
        app.setJobId("j_wl04");
        app.setTaId("ta_wl04");
        app.setStatus("pending");
        injectApplication(app);

        ds.updateApplicationStatus("app_wl04", "accepted");
        assertEquals(18, ds.findUserById("ta_wl04").getWorkload(),
            "Workload should be 18 h after acceptance (6h × 3 weeks)");

        // Act — admin then rejects
        ds.updateApplicationStatus("app_wl04", "rejected");

        // Assert
        assertEquals(0, ds.findUserById("ta_wl04").getWorkload(),
            "Workload should return to 0 after the only accepted app is rejected");
    }

    // ------------------------------------------------------------------
    // TC-DS-05: Duplicate application guard — hasDuplicateApplication() works correctly.
    // ------------------------------------------------------------------

    @Test
    @Order(5)
    @DisplayName("TC-DS-05: hasDuplicateApplication returns true when TA has already applied")
    void duplicateApplication_returnsTrueWhenAlreadyApplied() throws Exception {
        // Arrange
        Application existing = new Application();
        existing.setId("app_dup01");
        existing.setJobId("99");
        existing.setTaId("ta_dup");
        existing.setStatus("pending");
        injectApplication(existing);

        // Act + Assert
        assertTrue(ds.hasDuplicateApplication("ta_dup", "99"),
            "Should detect existing application for same TA and job");
        assertFalse(ds.hasDuplicateApplication("ta_dup", "100"),
            "Should not flag a different job as duplicate");
        assertFalse(ds.hasDuplicateApplication("ta_other", "99"),
            "Should not flag a different TA as duplicate");
    }

    // ------------------------------------------------------------------
    // TC-DS-06: workload stays correct when only SOME applications are accepted.
    // pending and rejected apps must NOT contribute to the total.
    // ------------------------------------------------------------------

    @Test
    @Order(6)
    @DisplayName("TC-DS-06: pending/rejected apps do not contribute to workload")
    void workloadCalculation_onlyAcceptedAppsCount() throws Exception {
        // Arrange
        User ta = new User("ta_wl06", "Test TA 06", "ta06@test.com", "pw", "ta");
        injectUser(ta);

        injectJob("j_wl06a", "4", "5,6,7", 2);  // 12 h — will be accepted
        injectJob("j_wl06b", "6", "8,9,10", 2); // 18 h — will stay pending
        injectJob("j_wl06c", "3", "1,2,3", 2);  //  9 h — will be rejected

        Application appAccepted = new Application();
        appAccepted.setId("app_wl06a"); appAccepted.setJobId("j_wl06a");
        appAccepted.setTaId("ta_wl06"); appAccepted.setStatus("pending");
        injectApplication(appAccepted);

        Application appPending = new Application();
        appPending.setId("app_wl06b"); appPending.setJobId("j_wl06b");
        appPending.setTaId("ta_wl06"); appPending.setStatus("pending");
        injectApplication(appPending);

        Application appRejected = new Application();
        appRejected.setId("app_wl06c"); appRejected.setJobId("j_wl06c");
        appRejected.setTaId("ta_wl06"); appRejected.setStatus("pending");
        injectApplication(appRejected);

        // Act
        ds.updateApplicationStatus("app_wl06a", "accepted");
        ds.updateApplicationStatus("app_wl06c", "rejected");
        // appPending remains pending — no status change

        // Assert: only the accepted job (4h × 3w = 12h) should count
        assertEquals(12, ds.findUserById("ta_wl06").getWorkload(),
            "Only the accepted application (12 h) should be counted; "
            + "pending and rejected must be excluded");
    }
}
