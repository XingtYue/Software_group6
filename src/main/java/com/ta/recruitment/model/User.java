package com.ta.recruitment.model;

import java.io.Serializable;

/**
 * Represents a system user (TA, MO, or Admin).
 *
 * <p>Role values: {@code "ta"}, {@code "mo"}, {@code "admin"}.
 * Status values: {@code "active"}, {@code "inactive"}.
 * The {@code modules} and {@code pendingModules} fields are MO-only and store
 * semicolon-separated {@code "courseCode|courseName"} pairs.
 */
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
    private String modules = ""; // semicolon-separated "courseCode|courseName" pairs, MO only (approved)
    private String pendingModules = ""; // same format, awaiting admin approval

    /** Creates an empty User; all fields must be set explicitly before persisting. */
    public User() {}

    /**
     * Creates a fully initialised User with {@code status} defaulting to {@code "active"}.
     *
     * @param id       unique user ID (e.g. {@code "u1"})
     * @param name     display name
     * @param email    login email (used as username)
     * @param password plaintext password
     * @param role     one of {@code "ta"}, {@code "mo"}, {@code "admin"}
     */
    public User(String id, String name, String email, String password, String role) {
        this.id = id;
        this.name = name;
        this.email = email;
        this.password = password;
        this.role = role;
        this.status = "active";
    }

    // Getters and setters
    /** @return the unique user ID */
    public String getId() { return id; }
    /** @param id the unique user ID to set */
    public void setId(String id) { this.id = id; }

    /** @return the user's display name */
    public String getName() { return name; }
    /** @param name the display name to set */
    public void setName(String name) { this.name = name; }

    /** @return the user's login email */
    public String getEmail() { return email; }
    /** @param email the login email to set */
    public void setEmail(String email) { this.email = email; }

    /** @return the user's plaintext password */
    public String getPassword() { return password; }
    /** @param password the plaintext password to set */
    public void setPassword(String password) { this.password = password; }

    /** @return the user's role ({@code "ta"}, {@code "mo"}, or {@code "admin"}) */
    public String getRole() { return role; }
    /** @param role the role to set */
    public void setRole(String role) { this.role = role; }

    /** @return the user's phone number, or {@code null} if not set */
    public String getPhone() { return phone; }
    /** @param phone the phone number to set */
    public void setPhone(String phone) { this.phone = phone; }

    /** @return the user's department, or {@code null} if not set */
    public String getDepartment() { return department; }
    /** @param department the department to set */
    public void setDepartment(String department) { this.department = department; }

    /** @return the account status ({@code "active"} or {@code "inactive"}) */
    public String getStatus() { return status; }
    /** @param status the account status to set */
    public void setStatus(String status) { this.status = status; }

    /** @return the stored CV filename (relative to the uploads directory), or {@code null} */
    public String getCvFileName() { return cvFileName; }
    /** @param cvFileName the CV filename to set */
    public void setCvFileName(String cvFileName) { this.cvFileName = cvFileName; }

    /** @return total committed TA hours (sum of accepted positions) */
    public int getWorkload() {return workload;}
    /** @param workload the total committed hours to set */
    public void setWorkload(int workload) {this.workload = workload;}

    /**
     * Returns the admin-approved modules string (MO only).
     *
     * @return semicolon-separated {@code "courseCode|courseName"} pairs, never {@code null}
     */
    public String getModules() { return modules != null ? modules : ""; }
    /**
     * Sets the admin-approved modules string (MO only).
     *
     * @param modules semicolon-separated {@code "courseCode|courseName"} pairs
     */
    public void setModules(String modules) { this.modules = modules != null ? modules : ""; }

    /**
     * Returns the pending (unapproved) modules string (MO only).
     *
     * @return semicolon-separated {@code "courseCode|courseName"} pairs, never {@code null}
     */
    public String getPendingModules() { return pendingModules != null ? pendingModules : ""; }
    /**
     * Sets the pending modules string (MO only).
     *
     * @param pendingModules semicolon-separated {@code "courseCode|courseName"} pairs
     */
    public void setPendingModules(String pendingModules) { this.pendingModules = pendingModules != null ? pendingModules : ""; }

    /**
     * Returns the pending (unapproved) module list as structured maps.
     *
     * @return list of maps each containing {@code "code"} and {@code "name"} keys
     */
    public java.util.List<java.util.Map<String,String>> getPendingModuleList() {
        return parseModuleString(pendingModules);
    }

    /**
     * Returns the approved module list as structured maps.
     *
     * @return list of maps each containing {@code "code"} and {@code "name"} keys
     */
    public java.util.List<java.util.Map<String,String>> getModuleList() {
        return parseModuleString(modules);
    }

    /**
     * Parses a semicolon-delimited module string into a list of {@code {code, name}} maps.
     *
     * @param raw the raw module string (may be {@code null} or empty)
     * @return parsed list, empty if input is blank
     */
    private java.util.List<java.util.Map<String,String>> parseModuleString(String raw) {
        java.util.List<java.util.Map<String,String>> list = new java.util.ArrayList<>();
        if (raw == null || raw.trim().isEmpty()) return list;
        for (String entry : raw.split(";")) {
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

    /**
     * Converts this User to a flat string map suitable for JSP EL access.
     * Password is intentionally excluded.
     *
     * @return map with keys: {@code id, name, email, role, status, department,
     *         phone, cvFileName, modules, pendingModules}
     */
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
        m.put("pendingModules", pendingModules != null ? pendingModules : "");
        return m;
    }
}
