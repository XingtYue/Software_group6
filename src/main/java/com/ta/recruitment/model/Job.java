package com.ta.recruitment.model;

import java.util.ArrayList;
import java.util.List;

public class Job {
    private String id;
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

    public Job() {
        this.requirements = new ArrayList<>();
        this.status = "active";
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getDepartment() { return department; }
    public void setDepartment(String department) { this.department = department; }

    public String getCourseCode() { return courseCode; }
    public void setCourseCode(String courseCode) { this.courseCode = courseCode; }

    public String getHours() { return hours; }
    public void setHours(String hours) { this.hours = hours; }

    public String getDuration() { return duration; }
    public void setDuration(String duration) { this.duration = duration; }

    public String getPostedBy() { return postedBy; }
    public void setPostedBy(String postedBy) { this.postedBy = postedBy; }

    public String getPostedByName() { return postedByName; }
    public void setPostedByName(String postedByName) { this.postedByName = postedByName; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getPostedDate() { return postedDate; }
    public void setPostedDate(String postedDate) { this.postedDate = postedDate; }

    public List<String> getRequirements() { return requirements; }
    public void setRequirements(List<String> requirements) { this.requirements = requirements; }

    public java.util.Map<String,String> toMap() {
        java.util.Map<String,String> m = new java.util.LinkedHashMap<>();
        m.put("id", id);
        m.put("title", title);
        m.put("description", description != null ? description : "");
        m.put("department", department != null ? department : "");
        m.put("courseCode", courseCode != null ? courseCode : "");
        m.put("hours", hours != null ? hours : "");
        m.put("duration", duration != null ? duration : "");
        m.put("postedBy", postedByName != null ? postedByName : "");
        m.put("status", status != null ? status : "active");
        m.put("postedDate", postedDate != null ? postedDate : "");
        return m;
    }
}
