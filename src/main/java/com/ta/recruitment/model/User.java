package com.ta.recruitment.model;

import java.io.Serializable;

public class User implements Serializable {
    private String id;
    private String name;
    private String email;
    private String password;
    private String role; // "ta", "mo", "admin"
    private String phone;
    private String department;
    private String status; // "active", "inactive"
    private String cvFileName;
    private int workload = 0;
    private String modules = ""; // semicolon-separated "courseCode|courseName" pairs, MO only

    public User() {}

    public User(String id, String name, String email, String password, String role) {
        this.id = id;
        this.name = name;
        this.email = email;
        this.password = password;
        this.role = role;
        this.status = "active";
    }

    // Getters and setters
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public String getDepartment() { return department; }
    public void setDepartment(String department) { this.department = department; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getCvFileName() { return cvFileName; }
    public void setCvFileName(String cvFileName) { this.cvFileName = cvFileName; }

    public int getWorkload() {return workload;}
    public void setWorkload(int workload) {this.workload = workload;}

    public String getModules() { return modules != null ? modules : ""; }
    public void setModules(String modules) { this.modules = modules != null ? modules : ""; }

    /** Returns list of maps with "code" and "name" keys, parsed from the modules string. */
    public java.util.List<java.util.Map<String,String>> getModuleList() {
        java.util.List<java.util.Map<String,String>> list = new java.util.ArrayList<>();
        if (modules == null || modules.trim().isEmpty()) return list;
        for (String entry : modules.split(";")) {
            entry = entry.trim();
            if (entry.isEmpty()) continue;
            int sep = entry.indexOf('|');
            java.util.Map<String,String> m = new java.util.LinkedHashMap<>();
            if (sep > 0) {
                m.put("code", entry.substring(0, sep).trim());
                m.put("name", entry.substring(sep + 1).trim());
            } else {
                m.put("code", entry);
                m.put("name", entry);
            }
            list.add(m);
        }
        return list;
    }

    public java.util.Map<String,String> toMap() {
        java.util.Map<String,String> m = new java.util.LinkedHashMap<>();
        m.put("id", id);
        m.put("name", name);
        m.put("email", email);
        m.put("role", role);
        m.put("status", status != null ? status : "active");
        m.put("department", department != null ? department : "");
        m.put("phone", phone != null ? phone : "");
        m.put("cvFileName", cvFileName != null ? cvFileName : "");
        m.put("modules", modules != null ? modules : "");
        return m;
    }
}
