package com.ta.recruitment.model;

import java.util.ArrayList;
import java.util.List;

/**
 * Represents a TA job posting created by a Module Organiser (MO).
 *
 * <p>Status values: {@code "active"} (visible to TAs), {@code "deactive"} (hidden from TAs,
 * visible to owner MO), {@code "closed"} (admin-only visibility).
 * The {@code openings} field sets the maximum number of accepted TAs; defaults to 1.
 */
public class Job {
    private String id;
    private String jobId;
    private String title;
    private String description;
    private String department;
    private String courseCode;
    private String hours;
    private String duration;
    private String postedBy; // MO user id
    private String postedByName;
    private String status; // "active", "closed"
    private String postedDate;
    private List<String> requirements;
    private String courseName;    // 课程名称（如：软件工程EBU6304），同一课程名称对应同一个MO
    private String positionType;  // 岗位类型（如：批改作业、监考、验收lab、验收大作业）
    private int openings = 1;     // 需要招募的 TA 人数，默认 1

    /** Creates a Job with an empty requirements list and status defaulting to {@code "active"}. */
    public Job() {
        this.requirements = new ArrayList<>();
        this.status = "active";
    }

    /** @return the internal auto-generated ID (not exposed in URLs) */
    public String getId() { return id; }
    /** @param id the internal ID to set */
    public void setId(String id) { this.id = id; }

    /** @return the public job ID used in URLs (e.g. {@code "3"}) */
    public String getJobId() { return jobId; }
    /** @param jobId the public job ID to set */
    public void setJobId(String jobId) { this.jobId = jobId; }

    /** @return the job title */
    public String getTitle() { return title; }
    /** @param title the job title to set */
    public void setTitle(String title) { this.title = title; }

    /** @return the job description */
    public String getDescription() { return description; }
    /** @param description the job description to set */
    public void setDescription(String description) { this.description = description; }

    /** @return the department associated with this job */
    public String getDepartment() { return department; }
    /** @param department the department to set */
    public void setDepartment(String department) { this.department = department; }

    /** @return the course code (e.g. {@code "EBU6304"}) */
    public String getCourseCode() { return courseCode; }
    /** @param courseCode the course code to set */
    public void setCourseCode(String courseCode) { this.courseCode = courseCode; }

    /** @return the weekly hours commitment as a string (e.g. {@code "4"}) */
    public String getHours() { return hours; }
    /** @param hours the weekly hours string to set */
    public void setHours(String hours) { this.hours = hours; }

    /** @return the duration description (e.g. {@code "Full Academic Year"} or comma-separated week numbers) */
    public String getDuration() { return duration; }
    /** @param duration the duration string to set */
    public void setDuration(String duration) { this.duration = duration; }

    /** @return the ID of the MO who posted this job */
    public String getPostedBy() { return postedBy; }
    /** @param postedBy the MO user ID to set */
    public void setPostedBy(String postedBy) { this.postedBy = postedBy; }

    /** @return the display name of the MO who posted this job */
    public String getPostedByName() { return postedByName; }
    /** @param postedByName the MO display name to set */
    public void setPostedByName(String postedByName) { this.postedByName = postedByName; }

    /** @return the job status ({@code "active"}, {@code "deactive"}, or {@code "closed"}) */
    public String getStatus() { return status; }
    /** @param status the job status to set */
    public void setStatus(String status) { this.status = status; }

    /** @return the date this job was posted (ISO format {@code yyyy-MM-dd}) */
    public String getPostedDate() { return postedDate; }
    /** @param postedDate the posted date to set */
    public void setPostedDate(String postedDate) { this.postedDate = postedDate; }

    /** @return the list of requirement strings for this position */
    public List<String> getRequirements() { return requirements; }
    /** @param requirements the requirements list to set */
    public void setRequirements(List<String> requirements) { this.requirements = requirements; }

    /** @return the full course name (e.g. {@code "Software Engineering EBU6304"}) */
    public String getCourseName() {
        return courseName;
    }

    /** @param courseName the full course name to set */
    public void setCourseName(String courseName) {
        this.courseName = courseName;
    }

    /** @return the position type (e.g. {@code "Assignment Grading"}, {@code "Lab Assessment"}) */
    public String getPositionType() {
        return positionType;
    }

    /** @param positionType the position type to set */
    public void setPositionType(String positionType) {
        this.positionType = positionType;
    }

    /** @return the maximum number of TAs to accept for this position (minimum 1) */
    public int getOpenings() { return openings; }
    /**
     * Sets the number of openings, enforcing a minimum of 1.
     *
     * @param openings the desired number of openings
     */
    public void setOpenings(int openings) { this.openings = Math.max(1, openings); }

    /**
     * Converts this Job to a flat string map suitable for JSP EL access.
     * Note: {@code postedBy} in the map holds the MO's display name (not the user ID).
     *
     * @return map with keys: {@code id, jobId, title, description, department, courseCode,
     *         courseName, positionType, hours, duration, postedBy, status, postedDate, openings}
     */
    public java.util.Map<String,String> toMap() {
        java.util.Map<String,String> m = new java.util.LinkedHashMap<>();
        m.put("id", id);
        m.put("jobId", jobId != null ? jobId : "");
        m.put("title", title);
        m.put("description", description != null ? description : "");
        m.put("department", department != null ? department : "");
        m.put("courseCode", courseCode != null ? courseCode : "");
        m.put("courseName", courseName != null ? courseName : "");
        m.put("positionType", positionType != null ? positionType : "");
        m.put("hours", hours != null ? hours : "");
        m.put("duration", duration != null ? duration : "");
        m.put("postedBy", postedByName != null ? postedByName : "");
        m.put("status", status != null ? status : "active");
        m.put("postedDate", postedDate != null ? postedDate : "");
        m.put("openings", String.valueOf(openings));
        return m;
    }
}
