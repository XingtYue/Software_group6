package com.ta.recruitment.model;

/**
 * Represents a TA's application for a job posting.
 *
 * <p>Status values: {@code "pending"} (awaiting MO review), {@code "accepted"},
 * {@code "rejected"}. AI analysis fields are populated asynchronously by
 * {@link com.ta.recruitment.service.GeminiService} after submission.
 */
public class Application {
    private String id;
    private String jobId;
    private String jobTitle;
    private String taId;
    private String taName;
    private String taEmail;
    private String status; // "pending", "accepted", "rejected"
    private String appliedDate;
    private String coverLetter;
    private String cvFileName;
    private String courseCode;
    private String courseName;
    private String positionType;

    // AI match analysis fields (populated by GeminiService)
    private Integer aiMatchScore;               // 0-100
    private String aiMatchedSkills;             // e.g. "Java, Agile"
    private String aiMissingSkills;             // e.g. "Python"
    private String aiReasoning;                 // analysis summary (includes workload penalty note if triggered)
    private String aiRecommendedAlternativeJob; // title of a better-fit open position, or "" if none

    /** Creates an Application with status defaulting to {@code "pending"}. */
    public Application() {
        this.status = "pending";
    }

    /** @return the unique application ID */
    public String getId() { return id; }
    /** @param id the unique application ID to set */
    public void setId(String id) { this.id = id; }

    /** @return the ID of the job this application is for */
    public String getJobId() { return jobId; }
    /** @param jobId the job ID to set */
    public void setJobId(String jobId) { this.jobId = jobId; }

    /** @return the title of the job at the time of application */
    public String getJobTitle() { return jobTitle; }
    /** @param jobTitle the job title snapshot to set */
    public void setJobTitle(String jobTitle) { this.jobTitle = jobTitle; }

    /** @return the TA applicant's user ID */
    public String getTaId() { return taId; }
    /** @param taId the TA user ID to set */
    public void setTaId(String taId) { this.taId = taId; }

    /** @return the TA applicant's display name at the time of application */
    public String getTaName() { return taName; }
    /** @param taName the TA display name to set */
    public void setTaName(String taName) { this.taName = taName; }

    /** @return the TA applicant's email at the time of application */
    public String getTaEmail() { return taEmail; }
    /** @param taEmail the TA email to set */
    public void setTaEmail(String taEmail) { this.taEmail = taEmail; }

    /** @return the application status ({@code "pending"}, {@code "accepted"}, or {@code "rejected"}) */
    public String getStatus() { return status; }
    /** @param status the status to set */
    public void setStatus(String status) { this.status = status; }

    /** @return the date submitted (ISO format {@code yyyy-MM-dd}) */
    public String getAppliedDate() { return appliedDate; }
    /** @param appliedDate the submission date to set */
    public void setAppliedDate(String appliedDate) { this.appliedDate = appliedDate; }

    /** @return the cover letter text, or {@code null} if not provided */
    public String getCoverLetter() { return coverLetter; }
    /** @param coverLetter the cover letter text to set */
    public void setCoverLetter(String coverLetter) { this.coverLetter = coverLetter; }

    /** @return the CV filename (relative to the uploads directory), or {@code null} */
    public String getCvFileName() { return cvFileName; }
    /** @param cvFileName the CV filename to set */
    public void setCvFileName(String cvFileName) { this.cvFileName = cvFileName; }

    /** @return the course code snapshot from the job at the time of application */
    public String getCourseCode() {
        return courseCode;
    }

    /** @param courseCode the course code to set */
    public void setCourseCode(String courseCode) {
        this.courseCode = courseCode;
    }

    /** @return the course name snapshot from the job at the time of application */
    public String getCourseName() {
        return courseName;
    }

    /** @param courseName the course name to set */
    public void setCourseName(String courseName) {
        this.courseName = courseName;
    }

    /** @return the position type snapshot from the job at the time of application */
    public String getPositionType() {
        return positionType;
    }

    /** @param positionType the position type to set */
    public void setPositionType(String positionType) {
        this.positionType = positionType;
    }

    /** @return the AI-computed match score (0–100), or {@code null} if analysis has not run yet */
    public Integer getAiMatchScore() { return aiMatchScore; }
    /** @param aiMatchScore the match score to set */
    public void setAiMatchScore(Integer aiMatchScore) { this.aiMatchScore = aiMatchScore; }

    /** @return comma-separated skills present in both the CV and the job requirements */
    public String getAiMatchedSkills() { return aiMatchedSkills; }
    /** @param aiMatchedSkills the matched skills string to set */
    public void setAiMatchedSkills(String aiMatchedSkills) { this.aiMatchedSkills = aiMatchedSkills; }

    /** @return comma-separated required skills absent from the CV */
    public String getAiMissingSkills() { return aiMissingSkills; }
    /** @param aiMissingSkills the missing skills string to set */
    public void setAiMissingSkills(String aiMissingSkills) { this.aiMissingSkills = aiMissingSkills; }

    /** @return the AI's reasoning narrative, including any workload deduction note */
    public String getAiReasoning() { return aiReasoning; }
    /** @param aiReasoning the reasoning text to set */
    public void setAiReasoning(String aiReasoning) { this.aiReasoning = aiReasoning; }

    /** @return the title of a recommended alternative job, or {@code ""} if none was suggested */
    public String getAiRecommendedAlternativeJob() { return aiRecommendedAlternativeJob; }
    /** @param v the recommended alternative job title to set */
    public void setAiRecommendedAlternativeJob(String v) { this.aiRecommendedAlternativeJob = v; }

    /**
     * Converts this Application to a flat string map suitable for JSP EL access.
     * Includes convenience aliases: {@code name} (= taName), {@code email} (= taEmail),
     * {@code submittedAt} (= appliedDate).
     *
     * @return map with all application and AI-analysis fields as strings
     */
    public java.util.Map<String,String> toMap() {
        java.util.Map<String,String> m = new java.util.LinkedHashMap<>();
        m.put("id", id);
        m.put("jobId", jobId);
        m.put("jobTitle", jobTitle != null ? jobTitle : "");
        m.put("taId", taId);
        m.put("taName", taName != null ? taName : "");
        m.put("taEmail", taEmail != null ? taEmail : "");
        m.put("name", taName != null ? taName : "");
        m.put("email", taEmail != null ? taEmail : "");
        m.put("status", status != null ? status : "pending");
        m.put("appliedDate", appliedDate != null ? appliedDate : "");
        m.put("submittedAt", appliedDate != null ? appliedDate : "");
        m.put("courseCode", courseCode != null ? courseCode : "");
        m.put("courseName", courseName != null ? courseName : "");
        m.put("positionType", positionType != null ? positionType : "");
        m.put("coverLetter", coverLetter != null ? coverLetter : "");
        m.put("cvFileName", cvFileName != null ? cvFileName : "");
        m.put("aiMatchScore", aiMatchScore != null ? String.valueOf(aiMatchScore) : "");
        m.put("aiMatchedSkills", aiMatchedSkills != null ? aiMatchedSkills : "");
        m.put("aiMissingSkills", aiMissingSkills != null ? aiMissingSkills : "");
        m.put("aiReasoning", aiReasoning != null ? aiReasoning : "");
        m.put("aiRecommendedAlternativeJob", aiRecommendedAlternativeJob != null ? aiRecommendedAlternativeJob : "");
        return m;
    }
}
