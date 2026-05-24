package com.ta.recruitment.servlet;

import com.ta.recruitment.model.*;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.*;

/**
 * Handles all admin portal requests under {@code /admin/*}.
 *
 * <p>GET routes: user dashboard, job management, job detail, application management,
 * CV download, workload management, workload edit, profile, add-MO form, and user
 * edit page (including per-module approval).
 *
 * <p>POST routes: job open/close, openings update, application accept/reject/restore,
 * user activate/deactivate, module approve/reject (bulk and per-entry), add-MO form
 * submission, user info / password / module edits, and workload save.
 */
@WebServlet("/admin/*")
public class AdminServlet extends BaseServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String path = req.getPathInfo();
        if (path == null || path.equals("/") || path.isEmpty()) path = "/dashboard";

        DataStore ds = DataStore.getInstance();

        if (path.equals("/dashboard")) {
            String roleParam   = req.getParameter("role");
            String statusParam = req.getParameter("status");
            List<User> users = ds.getAllUsers();
            if (roleParam != null && !"all".equalsIgnoreCase(roleParam)) {
                users = filter(users, u -> roleParam.equalsIgnoreCase(u.getRole()));
            }
            if (statusParam != null && !"all".equalsIgnoreCase(statusParam)) {
                users = filter(users, u -> statusParam.equalsIgnoreCase(u.getStatus()));
            }
            List<Map<String,String>> userMaps = toMaps(users);
            req.setAttribute("users",      userMaps);
            req.setAttribute("totalUsers", ds.getAllUsers().size());
            req.setAttribute("taCount",    ds.getUsersByRole("ta").size());
            req.setAttribute("moCount",    ds.getUsersByRole("mo").size());
            req.setAttribute("adminCount", ds.getUsersByRole("admin").size());

            // Pending module approval notifications
            List<User> pendingModuleUsers = ds.getUsersWithPendingModules();
            req.setAttribute("pendingModuleUsers", toMaps(pendingModuleUsers));
            req.setAttribute("pendingModuleCount", pendingModuleUsers.size());
            forward(req, resp, "/WEB-INF/jsp/admin/dashboard.jsp");

        } else if (path.equals("/jobs") || path.equals("/jobs/")) {
            List<Job> allJobs = ds.getAllJobs();
            List<Map<String,String>> jobMaps = new ArrayList<>();
            int activeCount = 0, closedCount = 0, deactiveCount = 0, totalApplicants = 0;
            for (Job j : allJobs) {
                Map<String,String> m = j.toMap();
                int cnt = ds.getApplicationsByJob(j.getJobId()).size();
                m.put("applicantCount", String.valueOf(cnt));
                totalApplicants += cnt;
                if ("active".equals(j.getStatus()))        activeCount++;
                else if ("closed".equals(j.getStatus()))   closedCount++;
                else if ("deactive".equals(j.getStatus())) deactiveCount++;
                jobMaps.add(m);
            }
            req.setAttribute("jobs",            jobMaps);
            req.setAttribute("totalJobs",       allJobs.size());
            req.setAttribute("activeJobs",      activeCount);
            req.setAttribute("closedJobs",      closedCount);
            req.setAttribute("deactiveJobs",    deactiveCount);
            req.setAttribute("totalApplicants", totalApplicants);
            forward(req, resp, "/WEB-INF/jsp/admin/job-management.jsp");

        } else if (path.startsWith("/jobs/")) {
            String jobId = path.substring("/jobs/".length());
            Job job = ds.findJobByJobId(jobId);
            if (job == null) { resp.sendError(404); return; }
            List<Application> jobApps = ds.getApplicationsByJob(jobId);
            int acceptedCnt = 0;
            for (Application a : jobApps) if ("accepted".equals(a.getStatus())) acceptedCnt++;
            req.setAttribute("job",            job.toMap());
            req.setAttribute("jobId",          jobId);
            req.setAttribute("applicants",     enrichedAppMaps(jobApps, ds));
            req.setAttribute("openings",       job.getOpenings());
            req.setAttribute("acceptedCount",  acceptedCnt);
            req.setAttribute("applicantCount", jobApps.size());
            req.setAttribute("isFull",         acceptedCnt >= job.getOpenings());
            forward(req, resp, "/WEB-INF/jsp/admin/job-detail.jsp");

        } else if (path.equals("/applications") || path.equals("/applications/")) {
            List<Application> allApps = ds.getAllApplications();
            int pending = 0, accepted = 0, rejected = 0;
            List<Map<String,String>> appMaps = new ArrayList<>();
            for (Application a : allApps) {
                Map<String,String> m = a.toMap();
                enrichAppWithTaInfo(m, a.getTaId(), ds);
                appMaps.add(m);
                if ("accepted".equals(a.getStatus())) accepted++;
                else if ("rejected".equals(a.getStatus())) rejected++;
                else pending++;
            }
            req.setAttribute("applications",      appMaps);
            req.setAttribute("totalApplications", allApps.size());
            req.setAttribute("pendingCount",       pending);
            req.setAttribute("acceptedCount",      accepted);
            req.setAttribute("rejectedCount",      rejected);
            forward(req, resp, "/WEB-INF/jsp/admin/application-management.jsp");

        } else if (path.startsWith("/cv/download")) {
            String cvFile = null, taName = "TA";
            String userId = req.getParameter("userId");
            if (userId != null) {
                User user = ds.findUserById(userId);
                if (user != null) { cvFile = user.getCvFileName(); taName = user.getName(); }
            }
            String appId = req.getParameter("appId");
            if (appId != null) {
                Application app = ds.findApplicationById(appId);
                if (app != null) {
                    cvFile  = app.getCvFileName();
                    taName  = app.getTaName() != null ? app.getTaName() : "TA";
                    if (cvFile == null || cvFile.isEmpty()) {
                        User ta = ds.findUserById(app.getTaId());
                        if (ta != null) { cvFile = ta.getCvFileName(); if (ta.getName() != null) taName = ta.getName(); }
                    }
                }
            }
            serveCV(req, resp, cvFile, taName);

        } else if (path.equals("/workload") || path.equals("/workload/")) {
            List<Map<String,String>> workloads = ds.getWorkloadData();
            int normal = 0, overloaded = 0, light = 0;

            // ========== 已更新：统一全局阈值 ==========
            // Light: < 40h | Normal: 40h - 80h | Overloaded: > 40h
            for (Map<String,String> w : workloads) {
                int h = parseInt(w.getOrDefault("totalHours", "0"));
                if (h > 80) overloaded++;
                else if (h >= 40) normal++;
                else light++;
            }

            req.setAttribute("workloads",       workloads);
            req.setAttribute("totalTAs",        workloads.size());
            req.setAttribute("normalCount",     normal);
            req.setAttribute("overloadedCount", overloaded);
            req.setAttribute("lightCount",      light);
            forward(req, resp, "/WEB-INF/jsp/admin/workload-management.jsp");
        } else if (path.startsWith("/workload/edit/")) {
            String taId = path.substring("/workload/edit/".length());
            User ta = ds.findUserById(taId);
            if (ta == null) { resp.sendRedirect(req.getContextPath() + "/admin/workload"); return; }

            List<Application> taApps = ds.getApplicationsByTA(taId);
            List<Map<String,String>> taApplications = new ArrayList<>();

            for (Application app : taApps) {
                Map<String,String> map = app.toMap();
                Job job = ds.findJobByJobId(app.getJobId());
                if (job != null) {
                    map.put("jobHours", job.getHours() != null ? job.getHours() : "0");
                    map.put("jobDurationWeeks", String.valueOf(
                        job.getDuration() != null && !job.getDuration().isEmpty()
                            ? job.getDuration().split(",").length : 1));
                } else {
                    map.put("jobHours", "0");
                    map.put("jobDurationWeeks", "1");
                }
                taApplications.add(map);
            }

            req.setAttribute("ta", ta);
            req.setAttribute("taApplications", taApplications);
            forward(req, resp, "/WEB-INF/jsp/admin/edit-workload.jsp");

        } else if (path.equals("/profile") || path.equals("/profile/")) {
            String userId = (String) req.getSession().getAttribute("userId");
            User user = ds.findUserById(userId);
            if (user != null) req.setAttribute("user", user.toMap());
            forward(req, resp, "/WEB-INF/jsp/admin/profile.jsp");

        } else if (path.equals("/add-mo") || path.equals("/add-mo/")) {
            forward(req, resp, "/WEB-INF/jsp/admin/add-mo.jsp");

        } else if (path.matches("/users/[^/]+/edit")) {
            String uid = path.substring("/users/".length(), path.lastIndexOf("/edit"));
            User u = ds.findUserById(uid);
            if (u == null) { resp.sendRedirect(req.getContextPath() + "/admin"); return; }
            req.setAttribute("editUser", u);
            req.setAttribute("editUserModules", u.getModuleList());
            req.setAttribute("editUserPendingModules", u.getPendingModuleList());
            forward(req, resp, "/WEB-INF/jsp/admin/edit-user.jsp");

        } else if (path.matches("/users/[^/]+/modules")) {
            String moId = path.substring("/users/".length(), path.lastIndexOf("/modules"));
            resp.sendRedirect(req.getContextPath() + "/admin/users/" + moId + "/edit");

        } else {
            resp.sendRedirect(req.getContextPath() + "/admin");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String path = req.getPathInfo();
        if (path == null) path = "";
        DataStore ds = DataStore.getInstance();

        if (path.equals("/jobs/action") || path.equals("/jobs/action/")) {
            String jobId  = req.getParameter("jobId");
            String action = req.getParameter("action");
            if ("close".equals(action) && jobId != null)    ds.closeJob(jobId);
            else if ("activate".equals(action) && jobId != null) ds.openJob(jobId);
            resp.sendRedirect(req.getContextPath() + "/admin/jobs");

        } else if (path.equals("/jobs/update-openings") || path.equals("/jobs/update-openings/")) {
            String jobId = req.getParameter("jobId");
            String openingsStr = req.getParameter("openings");
            if (jobId != null && openingsStr != null) {
                try {
                    int openings = Integer.parseInt(openingsStr.trim());
                    ds.updateJobOpenings(jobId, openings);
                } catch (NumberFormatException ignored) {}
            }
            resp.sendRedirect(req.getContextPath() + "/admin/jobs/" + jobId);

        } else if (path.equals("/applications/action") || path.equals("/applications/action/")) {
            String appId    = req.getParameter("appId");
            String action   = req.getParameter("action");
            String returnTo = req.getParameter("returnTo");
            if (appId != null && action != null) {
                if ("accept".equals(action))   ds.updateApplicationStatus(appId, "accepted");
                else if ("reject".equals(action))  ds.updateApplicationStatus(appId, "rejected");
                else if ("restore".equals(action)) ds.updateApplicationStatus(appId, "pending");
            }
            String redirect = (returnTo != null && !returnTo.trim().isEmpty() && returnTo.startsWith("/"))
                    ? returnTo : "/admin/applications";
            resp.sendRedirect(req.getContextPath() + redirect);

        } else if (path.equals("/users/action") || path.equals("/users/action/")) {
            String userId = req.getParameter("userId");
            String action = req.getParameter("action");
            if (userId != null && action != null) {
                if ("deactivate".equals(action)) ds.setUserStatus(userId, "inactive");
                else if ("activate".equals(action)) ds.setUserStatus(userId, "active");
                else if ("approvePendingModules".equals(action)) {
                    User u = ds.findUserById(userId);
                    if (u != null) {
                        String pending = u.getPendingModules();
                        if (pending != null && !pending.trim().isEmpty()) {
                            String existing = u.getModules();
                            String merged = (existing == null || existing.trim().isEmpty())
                                    ? pending : existing + ";" + pending;
                            u.setModules(merged);
                            u.setPendingModules("");
                            ds.updateUser(u);
                        }
                    }
                } else if ("rejectPendingModules".equals(action)) {
                    User u = ds.findUserById(userId);
                    if (u != null) { u.setPendingModules(""); ds.updateUser(u); }
                }
            }
            resp.sendRedirect(req.getContextPath() + "/admin");

        } else if (path.startsWith("/workload/save")) {
            String taId     = req.getParameter("taId");
            String hoursStr = req.getParameter("hours");
            User ta = ds.findUserById(taId);
            if (ta != null && hoursStr != null && !hoursStr.trim().isEmpty()) {
                try {
                    ta.setWorkload(Integer.parseInt(hoursStr.trim()));
                    ds.updateUser(ta);   // updateUser already calls saveUsers()
                } catch (NumberFormatException ignored) {}
            }
            resp.sendRedirect(req.getContextPath() + "/admin/workload");

        } else if (path.equals("/profile") || path.equals("/profile/")) {
            String userId = (String) req.getSession().getAttribute("userId");
            User user = ds.findUserById(userId);
            if (user != null) req.setAttribute("user", user.toMap());
            forward(req, resp, "/WEB-INF/jsp/admin/profile.jsp");

        } else if (path.equals("/add-mo") || path.equals("/add-mo/")) {
            String username = req.getParameter("username");
            String password = req.getParameter("password");
            String fullName = req.getParameter("fullName");
            String email = req.getParameter("email");
            String phone = req.getParameter("phone");
            String department = req.getParameter("department");

            if (username == null || username.trim().isEmpty() ||
                password == null || password.trim().isEmpty() ||
                fullName == null || fullName.trim().isEmpty() ||
                email == null || email.trim().isEmpty()) {
                resp.sendRedirect(req.getContextPath() + "/admin/add-mo?error=missing");
                return;
            }

            for (User u : ds.getAllUsers()) {
                if (username.trim().equalsIgnoreCase(u.getId())) {
                    resp.sendRedirect(req.getContextPath() + "/admin/add-mo?error=duplicate");
                    return;
                }
            }

            User newMO = new User(username.trim(), fullName.trim(), email.trim(), password.trim(), "mo");
            newMO.setStatus("active");

            if (phone != null && !phone.trim().isEmpty()) {
                newMO.setPhone(phone.trim());
            }
            if (department != null && !department.trim().isEmpty()) {
                newMO.setDepartment(department.trim());
            }

            ds.addUser(newMO);
            resp.sendRedirect(req.getContextPath() + "/admin?success=mo");

        } else if (path.matches("/users/[^/]+/edit")) {
            String uid = path.substring("/users/".length(), path.lastIndexOf("/edit"));
            User u = ds.findUserById(uid);
            if (u == null) { resp.sendRedirect(req.getContextPath() + "/admin"); return; }
            String action = req.getParameter("action");
            String redirectUrl = req.getContextPath() + "/admin/users/" + uid + "/edit";

            if ("saveInfo".equals(action)) {
                String name  = req.getParameter("name");
                String email = req.getParameter("email");
                String phone = req.getParameter("phone");
                String dept  = req.getParameter("department");
                if (name != null && !name.trim().isEmpty()) u.setName(name.trim());
                if (email != null && !email.trim().isEmpty()) {
                    String newEmail = email.trim().toLowerCase();
                    boolean taken = false;
                    for (User x : ds.getAllUsers()) {
                        if (!x.getId().equals(uid) && newEmail.equals(x.getEmail() != null ? x.getEmail().toLowerCase() : "")) {
                            taken = true; break;
                        }
                    }
                    if (!taken) u.setEmail(newEmail);
                    else { resp.sendRedirect(redirectUrl + "?error=email"); return; }
                }
                if (phone != null) u.setPhone(phone.trim());
                if (dept  != null) u.setDepartment(dept.trim());
                ds.updateUser(u);
                resp.sendRedirect(redirectUrl + "?success=info");

            } else if ("changePassword".equals(action)) {
                String newPwd     = req.getParameter("newPassword");
                String confirmPwd = req.getParameter("confirmPassword");
                if (newPwd != null && newPwd.length() >= 4 && newPwd.equals(confirmPwd)) {
                    u.setPassword(newPwd);
                    ds.updateUser(u);
                    resp.sendRedirect(redirectUrl + "?success=pwd");
                } else {
                    resp.sendRedirect(redirectUrl + "?error=pwd");
                }

            } else if ("addModule".equals(action) && "mo".equals(u.getRole())) {
                String courseCode = req.getParameter("courseCode");
                String courseName = req.getParameter("courseName");
                if (courseCode != null && !courseCode.trim().isEmpty()) {
                    String code  = courseCode.trim();
                    String mname = (courseName != null && !courseName.trim().isEmpty()) ? courseName.trim() : code;
                    String existing = u.getModules();
                    boolean exists = false;
                    if (existing != null && !existing.isEmpty()) {
                        for (String entry : existing.split(";"))
                            if (entry.startsWith(code + "|") || entry.equals(code)) { exists = true; break; }
                    }
                    if (!exists) {
                        u.setModules((existing == null || existing.isEmpty()) ? code + "|" + mname : existing + ";" + code + "|" + mname);
                        ds.updateUser(u);
                    }
                }
                resp.sendRedirect(redirectUrl + "?success=mod");

            } else if ("removeModule".equals(action) && "mo".equals(u.getRole())) {
                String code = req.getParameter("courseCode");
                if (code != null) {
                    String existing = u.getModules();
                    if (existing != null && !existing.isEmpty()) {
                        StringBuilder sb = new StringBuilder();
                        for (String entry : existing.split(";")) {
                            if (!entry.startsWith(code.trim() + "|") && !entry.equals(code.trim())) {
                                if (sb.length() > 0) sb.append(";");
                                sb.append(entry);
                            }
                        }
                        u.setModules(sb.toString());
                        ds.updateUser(u);
                    }
                }
                resp.sendRedirect(redirectUrl + "?success=mod");

            } else if ("approvePendingModules".equals(action) && "mo".equals(u.getRole())) {
                String pending = u.getPendingModules();
                if (pending != null && !pending.trim().isEmpty()) {
                    String existing = u.getModules();
                    u.setModules((existing == null || existing.trim().isEmpty()) ? pending : existing + ";" + pending);
                    u.setPendingModules("");
                    ds.updateUser(u);
                }
                resp.sendRedirect(redirectUrl + "?success=mod");

            } else if ("rejectPendingModules".equals(action) && "mo".equals(u.getRole())) {
                u.setPendingModules("");
                ds.updateUser(u);
                resp.sendRedirect(redirectUrl + "?success=mod");

            } else if ("approvePendingModule".equals(action) && "mo".equals(u.getRole())) {
                String code = req.getParameter("courseCode");
                if (code != null && !code.trim().isEmpty()) {
                    String trimCode = code.trim();
                    String pending = u.getPendingModules();
                    String matchedEntry = null;
                    StringBuilder newPending = new StringBuilder();
                    if (pending != null && !pending.isEmpty()) {
                        for (String entry : pending.split(";")) {
                            if (entry.startsWith(trimCode + "|") || entry.equals(trimCode)) {
                                matchedEntry = entry;
                            } else {
                                if (newPending.length() > 0) newPending.append(";");
                                newPending.append(entry);
                            }
                        }
                    }
                    if (matchedEntry != null) {
                        String existing = u.getModules();
                        boolean alreadyApproved = false;
                        if (existing != null && !existing.isEmpty()) {
                            for (String e : existing.split(";")) {
                                if (e.startsWith(trimCode + "|") || e.equals(trimCode)) { alreadyApproved = true; break; }
                            }
                        }
                        if (!alreadyApproved) {
                            u.setModules((existing == null || existing.isEmpty()) ? matchedEntry : existing + ";" + matchedEntry);
                        }
                        u.setPendingModules(newPending.toString());
                        ds.updateUser(u);
                    }
                }
                resp.sendRedirect(redirectUrl + "?success=mod");

            } else if ("rejectPendingModule".equals(action) && "mo".equals(u.getRole())) {
                String code = req.getParameter("courseCode");
                if (code != null && !code.trim().isEmpty()) {
                    String trimCode = code.trim();
                    String pending = u.getPendingModules();
                    StringBuilder newPending = new StringBuilder();
                    if (pending != null && !pending.isEmpty()) {
                        for (String entry : pending.split(";")) {
                            if (!entry.startsWith(trimCode + "|") && !entry.equals(trimCode)) {
                                if (newPending.length() > 0) newPending.append(";");
                                newPending.append(entry);
                            }
                        }
                    }
                    u.setPendingModules(newPending.toString());
                    ds.updateUser(u);
                }
                resp.sendRedirect(redirectUrl + "?success=mod");

            } else {
                resp.sendRedirect(redirectUrl);
            }

        } else if (path.matches("/users/[^/]+/modules")) {
            String moId = path.substring("/users/".length(), path.lastIndexOf("/modules"));
            User mo = ds.findUserById(moId);
            if (mo == null || !"mo".equals(mo.getRole())) { resp.sendRedirect(req.getContextPath() + "/admin"); return; }
            String moAction = req.getParameter("action");
            String courseCode = req.getParameter("courseCode");
            String courseName = req.getParameter("courseName");
            if ("add".equals(moAction) && courseCode != null && !courseCode.trim().isEmpty()) {
                String code = courseCode.trim();
                String name = (courseName != null && !courseName.trim().isEmpty()) ? courseName.trim() : code;
                String existing = mo.getModules();
                boolean exists = false;
                if (existing != null && !existing.isEmpty()) {
                    for (String entry : existing.split(";")) {
                        if (entry.startsWith(code + "|") || entry.equals(code)) { exists = true; break; }
                    }
                }
                if (!exists) {
                    String newModules = (existing == null || existing.isEmpty()) ? code + "|" + name : existing + ";" + code + "|" + name;
                    mo.setModules(newModules);
                    ds.updateUser(mo);
                }
            } else if ("remove".equals(moAction) && courseCode != null) {
                String code = courseCode.trim();
                String existing = mo.getModules();
                if (existing != null && !existing.isEmpty()) {
                    StringBuilder sb = new StringBuilder();
                    for (String entry : existing.split(";")) {
                        if (!entry.startsWith(code + "|") && !entry.equals(code.trim())) {
                            if (sb.length() > 0) sb.append(";");
                            sb.append(entry);
                        }
                    }
                    mo.setModules(sb.toString());
                    ds.updateUser(mo);
                }
            }
            resp.sendRedirect(req.getContextPath() + "/admin/users/" + moId + "/modules");

        } else {
            resp.sendRedirect(req.getContextPath() + "/admin");
        }
    }

    // ---- private helpers ----

    /**
     * Converts a list of applications to enriched maps, adding TA contact info to each.
     *
     * @param apps the applications to convert
     * @param ds   the data store used to look up TA details
     * @return list of enriched application maps
     */
    private List<Map<String,String>> enrichedAppMaps(List<Application> apps, DataStore ds) {
        List<Map<String,String>> result = new ArrayList<>();
        for (Application a : apps) {
            Map<String,String> m = a.toMap();
            enrichAppWithTaInfo(m, a.getTaId(), ds);
            result.add(m);
        }
        return result;
    }

    /**
     * Filters a list using the given predicate.
     *
     * @param <T>  element type
     * @param list the source list
     * @param pred the predicate to test each element
     * @return new list containing only elements that match the predicate
     */
    private static <T> List<T> filter(List<T> list, java.util.function.Predicate<T> pred) {
        List<T> out = new ArrayList<>();
        for (T t : list) if (pred.test(t)) out.add(t);
        return out;
    }

    /**
     * Converts a list of {@link User} objects to a list of flat string maps.
     *
     * @param users the users to convert
     * @return list of maps as returned by {@link User#toMap()}
     */
    private static List<Map<String,String>> toMaps(List<User> users) {
        List<Map<String,String>> out = new ArrayList<>();
        for (User u : users) out.add(u.toMap());
        return out;
    }

    /**
     * Parses a string to an integer, returning 0 on failure.
     *
     * @param s the string to parse
     * @return the parsed integer, or 0 if parsing fails
     */
    private static int parseInt(String s) {
        try { return Integer.parseInt(s); } catch (Exception e) { return 0; }
    }

    /**
     * Forwards the request to the given JSP path.
     *
     * @param req  the HTTP request
     * @param resp the HTTP response
     * @param jsp  the JSP path to forward to (relative to the web root)
     * @throws ServletException if the forward fails
     * @throws IOException      if an I/O error occurs
     */
    private static void forward(HttpServletRequest req, HttpServletResponse resp, String jsp)
            throws ServletException, IOException {
        req.getRequestDispatcher(jsp).forward(req, resp);
    }
}