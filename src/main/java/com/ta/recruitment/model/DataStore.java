package com.ta.recruitment.model;

import java.io.*;
import java.nio.file.*;
import java.text.SimpleDateFormat;
import java.util.*;

/**
 * Singleton data store that reads/writes JSON files for persistence.
 * All data is stored in WEB-INF/data/ directory.
 */
public class DataStore {

    private static DataStore instance;
    private String dataDir;

    // In-memory collections
    private List<User> users = new ArrayList<>();
    private List<Job> jobs = new ArrayList<>();
    private List<Application> applications = new ArrayList<>();

    private DataStore() {
    }

    public static synchronized DataStore getInstance() {
        if (instance == null) {
            instance = new DataStore();
        }
        return instance;
    }

    public void init(String dataDirectory) {
        this.dataDir = dataDirectory;
        File dir = new File(dataDirectory);
        if (!dir.exists()) dir.mkdirs();
        loadAll();
    }

    // ==================== LOAD ====================

    private void loadAll() {
        loadUsers();
        loadJobs();
        loadApplications();
    }

    private void loadUsers() {
        users.clear();
        File f = new File(dataDir, "users.json");
        if (!f.exists()) {
            seedUsers();
            return;
        }
        try {
            String content = new String(Files.readAllBytes(f.toPath()), "UTF-8");
            users = parseUsers(content);
        } catch (Exception e) {
            seedUsers();
        }
    }

    private void loadJobs() {
        jobs.clear();
        File f = new File(dataDir, "jobs.json");
        if (!f.exists()) {
            seedJobs();
            return;
        }
        try {
            String content = new String(Files.readAllBytes(f.toPath()), "UTF-8");
            jobs = parseJobs(content);
        } catch (Exception e) {
            seedJobs();
        }
    }

    private void loadApplications() {
        applications.clear();
        File f = new File(dataDir, "applications.json");
        if (!f.exists()) {
            seedApplications();
            return;
        }
        try {
            String content = new String(Files.readAllBytes(f.toPath()), "UTF-8");
            applications = parseApplications(content);
        } catch (Exception e) {
            seedApplications();
        }
    }

    // ==================== SAVE ====================

    public synchronized void saveUsers() {
        writeFile("users.json", usersToJson());
    }

    public synchronized void saveJobs() {
        writeFile("jobs.json", jobsToJson());
    }

    public synchronized void saveApplications() {
        writeFile("applications.json", applicationsToJson());
    }

    private void writeFile(String filename, String content) {
        try {
            File f = new File(dataDir, filename);
            Files.write(f.toPath(), content.getBytes("UTF-8"));
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // ==================== USER OPERATIONS ====================

    public User findUserByEmailAndPassword(String email, String password) {
        if (email == null || password == null) return null;
        for (User u : users) {
            if (email.equalsIgnoreCase(u.getEmail()) && password.equals(u.getPassword())) {
                return u;
            }
        }
        return null;
    }

    public User findUserById(String id) {
        for (User u : users) {
            if (id != null && id.equals(u.getId())) return u;
        }
        return null;
    }

    public List<User> getAllUsers() {
        return new ArrayList<>(users);
    }

    public List<User> getUsersByRole(String role) {
        List<User> result = new ArrayList<>();
        for (User u : users) {
            if (role.equals(u.getRole())) result.add(u);
        }
        return result;
    }

    public void updateUser(User user) {
        for (int i = 0; i < users.size(); i++) {
            if (users.get(i).getId().equals(user.getId())) {
                users.set(i, user);
                break;
            }
        }
        saveUsers();
    }

    public void setUserStatus(String userId, String status) {
        User u = findUserById(userId);
        if (u != null) {
            u.setStatus(status);
            saveUsers();
        }
    }

    // ==================== JOB OPERATIONS ====================

    public List<Job> getAllJobs() {
        return new ArrayList<>(jobs);
    }

    public List<Job> getActiveJobs() {
        List<Job> result = new ArrayList<>();
        for (Job j : jobs) {
            if ("active".equals(j.getStatus())) result.add(j);
        }
        return result;
    }

    public List<Job> getJobsByMO(String moId) {
        List<Job> result = new ArrayList<>();
        for (Job j : jobs) {
            if (moId.equals(j.getPostedBy())) result.add(j);
        }
        return result;
    }

    public Job findJobById(String id) {
        for (Job j : jobs) {
            if (id != null && id.equals(j.getId())) return j;
        }
        return null;
    }

    public Job findJobByJobId(String id) {
        for (Job j : jobs) {
            if (id != null && id.equals(j.getJobId())) return j;
        }
        return null;
    }

    public void addJob(Job job) {
        job.setId(generateId());
        job.setJobId(String.valueOf(jobs.size() + 1));
        job.setPostedDate(today());
        jobs.add(job);
        saveJobs();
    }

    public void closeJob(String jobId) {
        Job j = findJobById(jobId);
        if (j != null) {
            j.setStatus("closed");
            saveJobs();
        }
    }

    public void openJob(String jobId) {
        Job j = findJobById(jobId);
        if (j != null) {
            j.setStatus("active");
            saveJobs();
        }
    }

    // ==================== APPLICATION OPERATIONS ====================

    public List<Application> getAllApplications() {
        return new ArrayList<>(applications);
    }

    public List<Application> getApplicationsByTA(String taId) {
        List<Application> result = new ArrayList<>();
        for (Application a : applications) {
            if (taId.equals(a.getTaId())) result.add(a);
        }
        return result;
    }

    public List<Application> getApplicationsByJob(String jobId) {
        List<Application> result = new ArrayList<>();
        for (Application a : applications) {
            if (jobId.equals(a.getJobId())) result.add(a);
        }
        return result;
    }

    public Application findApplicationById(String id) {
        for (Application a : applications) {
            if (id != null && id.equals(a.getId())) return a;
        }
        return null;
    }

    public boolean hasApplied(String taId, String jobId) {
        for (Application a : applications) {
            if (taId.equals(a.getTaId()) && jobId.equals(a.getJobId())) return true;
        }
        return false;
    }

    public void addApplication(Application app) {
        app.setId(generateId());
        app.setAppliedDate(today());
        applications.add(app);
        saveApplications();
    }

    public void updateApplicationStatus(String appId, String status) {
        Application a = findApplicationById(appId);
        if (a != null) {
            a.setStatus(status);
            saveApplications();
        }
    }

    // ==================== WORKLOAD ====================
    public List<Map<String,String>> getWorkloadData() {
        List<Map<String,String>> result = new ArrayList<>();
        List<User> tas = getUsersByRole("ta");

        for (User ta : tas) {
            int totalHours = ta.getWorkload();
            List<Application> accepted = new ArrayList<>();

            // 找出已录取的申请
            for (Application a : applications) {
                if (ta.getId().equals(a.getTaId()) && "accepted".equals(a.getStatus())) {
                    accepted.add(a);
                }
            }

            // 计算工时
            for (Application a : accepted) {
                Job j = findJobByJobId(a.getJobId());
                if (j != null && j.getHours() != null) {
                    try {
                        String h = j.getHours().replaceAll("[^0-9]", "");
                        if (!h.isEmpty()) {
                            if(totalHours==0)  totalHours += Integer.parseInt(h);
                        }
                    } catch (Exception ignored) {}
                }
            }

            // 保存工时
            ta.setWorkload(totalHours);

            // 把当前 TA 加入结果
            Map<String, String> m = new LinkedHashMap<>();
            m.put("id", ta.getId());
            m.put("name", ta.getName());
            m.put("positions", String.valueOf(countAcceptedPositions(ta.getId())));
            m.put("totalHours", String.valueOf(totalHours));
            m.put("status", ta.getStatus());
            result.add(m);
        }

        // 排序
        result.sort((A, B) -> {
            boolean aActive = "active".equals(A.get("status"));
            boolean bActive = "active".equals(B.get("status"));
            if (aActive && !bActive) return -1;
            if (!aActive && bActive) return 1;
            int hA = Integer.parseInt(A.get("totalHours"));
            int hB = Integer.parseInt(B.get("totalHours"));
            return Integer.compare(hB, hA);
        });

        saveUsers();
        return result; // ✅ 正确位置
    }

    private int countAcceptedPositions(String taId) {
        int count = 0;
        for (Application a : applications) {
            if (taId.equals(a.getTaId()) && "accepted".equals(a.getStatus())) {
                count++;
            }
        }
        return count;
    }
    // ==================== SEED DATA ====================

    private void seedUsers() {
        users.add(new User("u1", "Admin User", "admin@bupt.edu.cn", "admin123", "admin"));
        users.add(new User("u2", "Dr. Smith", "mo1@bupt.edu.cn", "mo123", "mo"));
        users.add(new User("u3", "Dr. Johnson", "mo2@bupt.edu.cn", "mo123", "mo"));
        users.add(new User("u4", "Alice Chen", "ta1@bupt.edu.cn", "ta123", "ta"));
        users.add(new User("u5", "Bob Wang", "ta2@bupt.edu.cn", "ta123", "ta"));
        users.add(new User("u6", "Carol Li", "ta3@bupt.edu.cn", "ta123", "ta"));
        users.add(new User("u7", "David Zhang", "ta4@bupt.edu.cn", "ta123", "ta"));
        users.add(new User("u8", "Emma Liu", "ta5@bupt.edu.cn", "ta123", "ta"));
        for (User u : users) u.setDepartment("Computer Science");
        saveUsers();
    }

    private void seedJobs() {
        Job j1 = new Job();
        j1.setTitle("TA for Software Engineering (EBU6304)");
        j1.setDescription("Support students in software engineering labs and tutorials. Help with project guidance and code reviews.");
        j1.setDepartment("Computer Science");
        j1.setCourseCode("EBU6304");
        j1.setHours("10");
        j1.setDuration("Full Academic Year");
        j1.setPostedBy("u2");
        j1.setPostedByName("Dr. Smith");
        j1.setRequirements(Arrays.asList("Strong Java skills", "Experience with Agile methods", "Available 10 hours/week"));
        addJob(j1);

        Job j2 = new Job();
        j2.setTitle("TA for Data Structures (EBU5476)");
        j2.setDescription("Assist students with data structures and algorithms coursework.");
        j2.setDepartment("Computer Science");
        j2.setCourseCode("EBU5476");
        j2.setHours("8");
        j2.setDuration("Semester 1");
        j2.setPostedBy("u2");
        j2.setPostedByName("Dr. Smith");
        j2.setRequirements(Arrays.asList("Strong algorithms knowledge", "Python or Java proficiency"));
        addJob(j2);

        Job j3 = new Job();
        j3.setTitle("TA for Web Development (EBU6301)");
        j3.setDescription("Support web development module with HTML, CSS, JavaScript and Java Servlet topics.");
        j3.setDepartment("Computer Science");
        j3.setCourseCode("EBU6301");
        j3.setHours("12");
        j3.setDuration("Semester 2");
        j3.setPostedBy("u3");
        j3.setPostedByName("Dr. Johnson");
        j3.setRequirements(Arrays.asList("HTML/CSS/JavaScript", "Java Servlet/JSP knowledge", "Good communication skills"));
        addJob(j3);

        Job j4 = new Job();
        j4.setTitle("Invigilation Assistant");
        j4.setDescription("Assist with exam invigilation across multiple modules.");
        j4.setDepartment("Computer Science");
        j4.setCourseCode("N/A");
        j4.setHours("5");
        j4.setDuration("Semester 1");
        j4.setPostedBy("u3");
        j4.setPostedByName("Dr. Johnson");
        j4.setRequirements(Arrays.asList("Punctual and reliable", "Good attention to detail"));
        addJob(j4);
    }

    private void seedApplications() {
        Application a1 = new Application();
        a1.setJobId("1"); a1.setJobTitle("TA for Software Engineering (EBU6304)");
        a1.setTaId("u4"); a1.setTaName("Alice Chen"); a1.setTaEmail("ta1@bupt.edu.cn");
        a1.setStatus("pending");
        addApplication(a1);

        Application a2 = new Application();
        a2.setJobId("1"); a2.setJobTitle("TA for Software Engineering (EBU6304)");
        a2.setTaId("u5"); a2.setTaName("Bob Wang"); a2.setTaEmail("ta2@bupt.edu.cn");
        a2.setStatus("accepted");
        addApplication(a2);

        Application a3 = new Application();
        a3.setJobId("2"); a3.setJobTitle("TA for Data Structures (EBU5476)");
        a3.setTaId("u4"); a3.setTaName("Alice Chen"); a3.setTaEmail("ta1@bupt.edu.cn");
        a3.setStatus("accepted");
        addApplication(a3);
    }

    // ==================== JSON SERIALIZATION ====================

    private String usersToJson() {
        StringBuilder sb = new StringBuilder("[\n");
        for (int i = 0; i < users.size(); i++) {
            User u = users.get(i);
            sb.append("  {");
            sb.append("\"id\":\"").append(esc(u.getId())).append("\",");
            sb.append("\"name\":\"").append(esc(u.getName())).append("\",");
            sb.append("\"email\":\"").append(esc(u.getEmail())).append("\",");
            sb.append("\"password\":\"").append(esc(u.getPassword())).append("\",");
            sb.append("\"role\":\"").append(esc(u.getRole())).append("\",");
            sb.append("\"status\":\"").append(esc(u.getStatus() != null ? u.getStatus() : "active")).append("\",");
            sb.append("\"department\":\"").append(esc(u.getDepartment() != null ? u.getDepartment() : "")).append("\",");
            sb.append("\"phone\":\"").append(esc(u.getPhone() != null ? u.getPhone() : "")).append("\",");
            sb.append("\"workload\":\"").append(esc(String.valueOf(u.getWorkload()))).append("\"");
            sb.append("}");
            if (i < users.size() - 1) sb.append(",");
            sb.append("\n");
        }
        sb.append("]");
        return sb.toString();
    }

    private String jobsToJson() {
        StringBuilder sb = new StringBuilder("[\n");
        for (int i = 0; i < jobs.size(); i++) {
            Job j = jobs.get(i);
            sb.append("  {");
            sb.append("\"id\":\"").append(esc(j.getId())).append("\",");
            sb.append("\"jobId\":\"").append(esc(j.getJobId())).append("\",");
            sb.append("\"title\":\"").append(esc(j.getTitle())).append("\",");
            sb.append("\"description\":\"").append(esc(j.getDescription() != null ? j.getDescription() : "")).append("\",");
            sb.append("\"department\":\"").append(esc(j.getDepartment() != null ? j.getDepartment() : "")).append("\",");
            sb.append("\"courseCode\":\"").append(esc(j.getCourseCode() != null ? j.getCourseCode() : "")).append("\",");
            sb.append("\"hours\":\"").append(esc(j.getHours() != null ? j.getHours() : "")).append("\",");
            sb.append("\"duration\":\"").append(esc(j.getDuration() != null ? j.getDuration() : "")).append("\",");
            sb.append("\"postedBy\":\"").append(esc(j.getPostedBy() != null ? j.getPostedBy() : "")).append("\",");
            sb.append("\"postedByName\":\"").append(esc(j.getPostedByName() != null ? j.getPostedByName() : "")).append("\",");
            sb.append("\"status\":\"").append(esc(j.getStatus() != null ? j.getStatus() : "active")).append("\",");
            sb.append("\"postedDate\":\"").append(esc(j.getPostedDate() != null ? j.getPostedDate() : "")).append("\",");
            sb.append("\"requirements\":[");
            List<String> reqs = j.getRequirements();
            if (reqs != null) {
                for (int k = 0; k < reqs.size(); k++) {
                    sb.append("\"").append(esc(reqs.get(k))).append("\"");
                    if (k < reqs.size() - 1) sb.append(",");
                }
            }
            sb.append("]}");
            if (i < jobs.size() - 1) sb.append(",");
            sb.append("\n");
        }
        sb.append("]");
        return sb.toString();
    }

    private String applicationsToJson() {
        StringBuilder sb = new StringBuilder("[\n");
        for (int i = 0; i < applications.size(); i++) {
            Application a = applications.get(i);
            sb.append("  {");
            sb.append("\"id\":\"").append(esc(a.getId())).append("\",");
            sb.append("\"jobId\":\"").append(esc(a.getJobId())).append("\",");
            sb.append("\"jobTitle\":\"").append(esc(a.getJobTitle() != null ? a.getJobTitle() : "")).append("\",");
            sb.append("\"taId\":\"").append(esc(a.getTaId())).append("\",");
            sb.append("\"taName\":\"").append(esc(a.getTaName() != null ? a.getTaName() : "")).append("\",");
            sb.append("\"taEmail\":\"").append(esc(a.getTaEmail() != null ? a.getTaEmail() : "")).append("\",");
            sb.append("\"status\":\"").append(esc(a.getStatus() != null ? a.getStatus() : "pending")).append("\",");
            sb.append("\"appliedDate\":\"").append(esc(a.getAppliedDate() != null ? a.getAppliedDate() : "")).append("\",");
            sb.append("\"coverLetter\":\"").append(esc(a.getCoverLetter() != null ? a.getCoverLetter() : "")).append("\"");
            sb.append("}");
            if (i < applications.size() - 1) sb.append(",");
            sb.append("\n");
        }
        sb.append("]");
        return sb.toString();
    }

    // ==================== JSON PARSING (simple) ====================

    private List<User> parseUsers(String json) {
        List<User> list = new ArrayList<>();
        List<Map<String,String>> records = parseJsonArray(json);
        for (Map<String,String> r : records) {
            User u = new User();
            u.setId(r.get("id"));
            u.setName(r.get("name"));
            u.setEmail(r.get("email"));
            u.setPassword(r.get("password"));
            u.setRole(r.get("role"));
            u.setStatus(r.getOrDefault("status","active"));
            u.setDepartment(r.get("department"));
            u.setPhone(r.get("phone"));
            u.setWorkload(Integer.parseInt(r.get("totalHours")));
            list.add(u);
        }
        return list;
    }

    private List<Job> parseJobs(String json) {
        List<Job> list = new ArrayList<>();
        // Simple line-by-line object parsing
        String[] objects = json.split("\\},\\s*\\{");
        for (String obj : objects) {
            obj = obj.replaceAll("[\\[\\]{}]", "").trim();
            if (obj.isEmpty()) continue;
            Map<String,String> r = parseSimpleObject(obj);
            Job j = new Job();
            j.setId(r.get("id"));
            j.setJobId(r.get("jobId"));
            j.setTitle(r.get("title"));
            j.setDescription(r.get("description"));
            j.setDepartment(r.get("department"));
            j.setCourseCode(r.get("courseCode"));
            j.setHours(r.get("hours"));
            j.setDuration(r.get("duration"));
            j.setPostedBy(r.get("postedBy"));
            j.setPostedByName(r.get("postedByName"));
            j.setStatus(r.getOrDefault("status","active"));
            j.setPostedDate(r.get("postedDate"));
            list.add(j);
        }
        return list;
    }

    private List<Application> parseApplications(String json) {
        List<Application> list = new ArrayList<>();
        List<Map<String,String>> records = parseJsonArray(json);
        for (Map<String,String> r : records) {
            Application a = new Application();
            a.setId(r.get("id"));
            a.setJobId(r.get("jobId"));
            a.setJobTitle(r.get("jobTitle"));
            a.setTaId(r.get("taId"));
            a.setTaName(r.get("taName"));
            a.setTaEmail(r.get("taEmail"));
            a.setStatus(r.getOrDefault("status","pending"));
            a.setAppliedDate(r.get("appliedDate"));
            a.setCoverLetter(r.get("coverLetter"));
            list.add(a);
        }
        return list;
    }

    /**
     * Very simple JSON array parser for flat objects (no nested arrays).
     */
    private List<Map<String,String>> parseJsonArray(String json) {
        List<Map<String,String>> list = new ArrayList<>();
        // Split by object boundaries
        int depth = 0;
        int start = -1;
        for (int i = 0; i < json.length(); i++) {
            char c = json.charAt(i);
            if (c == '{') {
                if (depth == 0) start = i;
                depth++;
            } else if (c == '}') {
                depth--;
                if (depth == 0 && start >= 0) {
                    String obj = json.substring(start + 1, i);
                    list.add(parseSimpleObject(obj));
                    start = -1;
                }
            }
        }
        return list;
    }

    private Map<String,String> parseSimpleObject(String obj) {
        Map<String,String> map = new LinkedHashMap<>();
        // Match "key":"value" pairs
        int i = 0;
        while (i < obj.length()) {
            // Find key
            int ks = obj.indexOf('"', i);
            if (ks < 0) break;
            int ke = obj.indexOf('"', ks + 1);
            if (ke < 0) break;
            String key = obj.substring(ks + 1, ke);
            // Find colon
            int colon = obj.indexOf(':', ke + 1);
            if (colon < 0) break;
            // Find value start
            int vs = colon + 1;
            while (vs < obj.length() && (obj.charAt(vs) == ' ' || obj.charAt(vs) == '\t')) vs++;
            if (vs >= obj.length()) break;
            String value;
            if (obj.charAt(vs) == '"') {
                // String value
                int ve = vs + 1;
                while (ve < obj.length()) {
                    if (obj.charAt(ve) == '"' && obj.charAt(ve - 1) != '\\') break;
                    ve++;
                }
                value = obj.substring(vs + 1, ve).replace("\\\"", "\"").replace("\\n", "\n").replace("\\\\", "\\");
                i = ve + 1;
            } else if (obj.charAt(vs) == '[') {
                // Skip arrays
                int ve = obj.indexOf(']', vs);
                value = "";
                i = ve + 1;
            } else {
                // Number or boolean
                int ve = vs;
                while (ve < obj.length() && obj.charAt(ve) != ',' && obj.charAt(ve) != '}') ve++;
                value = obj.substring(vs, ve).trim();
                i = ve + 1;
            }
            map.put(key, value);
        }
        return map;
    }

    // ==================== UTILITIES ====================

    private String generateId() {
        return String.valueOf(System.currentTimeMillis()).substring(7) +
               String.valueOf((int)(Math.random() * 1000));
    }

    private String today() {
        return new SimpleDateFormat("yyyy-MM-dd").format(new Date());
    }

    private String esc(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "");
    }
}
