package com.ta.recruitment.model;

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
    private String courseCode;    // 课程编号（和Job的courseCode对应，用于统计）
    private String courseName;    // 课程名称（前端展示用）
    private String positionType;  // 申请的岗位类型（前端展示用）

    public Application() {
        this.status = "pending";
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getJobId() { return jobId; }
    public void setJobId(String jobId) { this.jobId = jobId; }

    public String getJobTitle() { return jobTitle; }
    public void setJobTitle(String jobTitle) { this.jobTitle = jobTitle; }

    public String getTaId() { return taId; }
    public void setTaId(String taId) { this.taId = taId; }

    public String getTaName() { return taName; }
    public void setTaName(String taName) { this.taName = taName; }

    public String getTaEmail() { return taEmail; }
    public void setTaEmail(String taEmail) { this.taEmail = taEmail; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getAppliedDate() { return appliedDate; }
    public void setAppliedDate(String appliedDate) { this.appliedDate = appliedDate; }

    public String getCoverLetter() { return coverLetter; }
    public void setCoverLetter(String coverLetter) { this.coverLetter = coverLetter; }

    public String getCvFileName() { return cvFileName; }
    public void setCvFileName(String cvFileName) { this.cvFileName = cvFileName; }

    public String getCourseCode() {
        return courseCode;
    }

    public void setCourseCode(String courseCode) {
        this.courseCode = courseCode;
    }

    public String getCourseName() {
        return courseName;
    }

    public void setCourseName(String courseName) {
        this.courseName = courseName;
    }

    public String getPositionType() {
        return positionType;
    }

    public void setPositionType(String positionType) {
        this.positionType = positionType;
    }

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
<<<<<<< Updated upstream
=======
        m.put("courseCode", courseCode != null ? courseCode : "");
        m.put("courseName", courseName != null ? courseName : "");
        m.put("positionType", positionType != null ? positionType : "");
        m.put("coverLetter", coverLetter != null ? coverLetter : "");
        m.put("cvFileName", cvFileName != null ? cvFileName : "");
>>>>>>> Stashed changes
        return m;
    }
}
