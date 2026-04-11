package com.ta.recruitment.servlet;

import com.ta.recruitment.model.*;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.*;

/**
 * Handles all Admin pages: /admin, /admin/jobs, /admin/jobs/{id},
 * /admin/applications, /admin/workload
 */
@WebServlet("/admin/*")
public class AdminServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!checkAuth(req, resp)) return;

        String path = req.getPathInfo();
        if (path == null || path.equals("/") || path.isEmpty()) path = "/dashboard";

        DataStore ds = DataStore.getInstance();

        if (path.equals("/dashboard") || path.equals("/")) {
            // Admin dashboard - user management
            String roleParam = req.getParameter("role");
            String statusParam = req.getParameter("status");
            List<User> allUsers = ds.getAllUsers();
            // 联合过滤
            if (roleParam != null && !"all".equalsIgnoreCase(roleParam)) {
                List<User> filtered = new ArrayList<>();
                for (User u : allUsers) {
                    if (roleParam.equalsIgnoreCase(u.getRole())) filtered.add(u);
                }
                allUsers = filtered;
            }
            if (statusParam != null && !"all".equalsIgnoreCase(statusParam)) {
                List<User> filtered = new ArrayList<>();
                for (User u : allUsers) {
                    if (statusParam.equalsIgnoreCase(u.getStatus())) filtered.add(u);
                }
                allUsers = filtered;
            }
            List<Map<String,String>> userMaps = new ArrayList<>();
            for (User u : allUsers) userMaps.add(u.toMap());
            req.setAttribute("users", userMaps);
            req.setAttribute("totalUsers", ds.getAllUsers().size());
            req.setAttribute("taCount", ds.getUsersByRole("ta").size());
            req.setAttribute("moCount", ds.getUsersByRole("mo").size());
            req.setAttribute("adminCount", ds.getUsersByRole("admin").size());
            req.getRequestDispatcher("/WEB-INF/jsp/admin/dashboard.jsp").forward(req, resp);

        } else if (path.equals("/jobs") || path.equals("/jobs/")) {
            List<Job> allJobs = ds.getAllJobs();
            List<Map<String,String>> jobMaps = new ArrayList<>();
            int activeCount = 0, closedCount = 0, totalApplicants = 0;
            for (Job j : allJobs) {
                Map<String,String> m = j.toMap();
                int cnt = ds.getApplicationsByJob(j.getJobId()).size();
                m.put("applicantCount", String.valueOf(cnt));
                totalApplicants += cnt;
                if ("active".equals(j.getStatus())) activeCount++;
                else closedCount++;
                jobMaps.add(m);
            }
            req.setAttribute("jobs", jobMaps);
            req.setAttribute("totalJobs", allJobs.size());
            req.setAttribute("activeJobs", activeCount);
            req.setAttribute("closedJobs", closedCount);
            req.setAttribute("totalApplicants", totalApplicants);
            req.getRequestDispatcher("/WEB-INF/jsp/admin/job-management.jsp").forward(req, resp);

        } else if (path.startsWith("/jobs/")) {
            // URL contains sequential jobId
            String jobId = path.substring("/jobs/".length());
            Job job = ds.findJobByJobId(jobId);
            if (job == null) { resp.sendError(404); return; }
            List<Application> apps = ds.getApplicationsByJob(jobId);
            List<Map<String,String>> appMaps = new ArrayList<>();
            for (Application a : apps) {
                Map<String,String> appMap = a.toMap();
                User taUser = ds.findUserById(a.getTaId());
                if (taUser != null) {
                    appMap.put("taPhone", taUser.getPhone() != null ? taUser.getPhone() : "");
                    appMap.put("taDepartment", taUser.getDepartment() != null ? taUser.getDepartment() : "");
                } else {
                    appMap.put("taPhone", "");
                    appMap.put("taDepartment", "");
                }
                appMaps.add(appMap);
            }
            req.setAttribute("job", job.toMap());
            req.setAttribute("jobId", jobId);
            req.setAttribute("applicants", appMaps);
            req.getRequestDispatcher("/WEB-INF/jsp/admin/job-detail.jsp").forward(req, resp);

        } else if (path.equals("/applications") || path.equals("/applications/")) {
            List<Application> allApps = ds.getAllApplications();
            List<Map<String,String>> appMaps = new ArrayList<>();
            int pending = 0, accepted = 0, rejected = 0;
            for (Application a : allApps) {
                Map<String,String> appMap = a.toMap();
                User taUser = ds.findUserById(a.getTaId());
                if (taUser != null) {
                    appMap.put("taPhone", taUser.getPhone() != null ? taUser.getPhone() : "");
                    appMap.put("taDepartment", taUser.getDepartment() != null ? taUser.getDepartment() : "");
                } else {
                    appMap.put("taPhone", "");
                    appMap.put("taDepartment", "");
                }
                appMaps.add(appMap);
                String s = a.getStatus();
                if ("accepted".equals(s)) accepted++;
                else if ("rejected".equals(s)) rejected++;
                else pending++;
            }
            req.setAttribute("applications", appMaps);
            req.setAttribute("totalApplications", allApps.size());
            req.setAttribute("pendingCount", pending);
            req.setAttribute("acceptedCount", accepted);
            req.setAttribute("rejectedCount", rejected);
            req.getRequestDispatcher("/WEB-INF/jsp/admin/application-management.jsp").forward(req, resp);

        } else if (path.startsWith("/cv/download")) {
            String appId = req.getParameter("appId");
            String cvFile = null;
            String taName = "TA";
            String userId = req.getParameter("userId");
            if (userId != null) {
                User user = ds.findUserById(userId);
                if (user != null) {
                    cvFile = user.getCvFileName();
                    taName = user.getName();
                }
            }
            if (appId != null) {
                Application app = ds.findApplicationById(appId);
                if (app != null) {
                    cvFile = app.getCvFileName();
                    taName = app.getTaName() != null ? app.getTaName() : "TA";
                    if (cvFile == null || cvFile.isEmpty()) {
                        User ta = ds.findUserById(app.getTaId());
                        if (ta != null) {
                            cvFile = ta.getCvFileName();
                            if (ta.getName() != null) taName = ta.getName();
                        }
                    }
                }
            }
            if (cvFile == null || cvFile.isEmpty()) {
                resp.sendError(404, "CV not found");
                return;
            }
            String uploadsDir = req.getServletContext().getRealPath("/WEB-INF/uploads/cv/");
            java.io.File file = new java.io.File(uploadsDir, cvFile);
            if (!file.exists()) {
                resp.sendError(404, "CV file not found");
                return;
            }
            String contentType = cvFile.toLowerCase().endsWith(".pdf") ? "application/pdf" : "application/octet-stream";
            resp.setContentType(contentType);
            String safeFileName = taName.replaceAll("[^a-zA-Z0-9\\s._-]", "_") + "_CV.pdf";
            resp.setHeader("Content-Disposition", "inline; filename=\"" + safeFileName + "\"");
            resp.setContentLength((int) file.length());
            try (java.io.FileInputStream fis = new java.io.FileInputStream(file);
                 java.io.OutputStream os = resp.getOutputStream()) {
                byte[] buf = new byte[4096];
                int len;
                while ((len = fis.read(buf)) != -1) os.write(buf, 0, len);
            }
            return;

        } else if (path.equals("/workload") || path.equals("/workload/")) {
            List<Map<String,String>> workloads = ds.getWorkloadData();
            req.setAttribute("workloads", workloads);
            req.setAttribute("totalTAs", workloads.size());
            int normal = 0, overloaded = 0, light = 0;
            for (Map<String,String> w : workloads) {
                int h = 0;
                try { h = Integer.parseInt(w.getOrDefault("totalHours","0")); } catch(Exception e){}
                if (h > 15) overloaded++;
                else if (h > 8) normal++;
                else light++;
            }
            req.setAttribute("normalCount", normal);
            req.setAttribute("overloadedCount", overloaded);
            req.setAttribute("lightCount", light);
            req.getRequestDispatcher("/WEB-INF/jsp/admin/workload-management.jsp").forward(req, resp);

        } else if (path.startsWith("/workload/edit/")) {
            String taId = path.substring("/workload/edit/".length());
            User ta = DataStore.getInstance().findUserById(taId);

            if (ta == null) {
                resp.sendRedirect(req.getContextPath() + "/admin/workload");
                return;
            }

            // ✅【核心修复】获取这个 TA 的所有申请（已录用 + 待处理 + 已拒绝）
            List<Application> taApps = DataStore.getInstance().getApplicationsByTA(taId);
            List<Map<String, String>> taApplications = new ArrayList<>();

            for (Application app : taApps) {
                Map<String, String> map = app.toMap();

                // ✅ 把职位的小时数放进 map，给前端页面显示
                Job job = DataStore.getInstance().findJobByJobId(app.getJobId());
                if (job != null) {
                    map.put("jobHours", job.getHours()); // 职位小时数
                } else {
                    map.put("jobHours", "0");
                }

                taApplications.add(map);
            }

            // ✅ 传给 JSP 页面
            req.setAttribute("ta", ta);
            req.setAttribute("taApplications", taApplications);

            req.getRequestDispatcher("/WEB-INF/jsp/admin/edit-workload.jsp").forward(req, resp);
        }else if (path.equals("/profile") || path.equals("/profile/")) {
            String userId = (String) req.getSession().getAttribute("userId");
            User user = ds.findUserById(userId);
            if (user != null) req.setAttribute("user", user.toMap());
            req.getRequestDispatcher("/WEB-INF/jsp/admin/profile.jsp").forward(req, resp);

        } else {
            resp.sendRedirect(req.getContextPath() + "/admin");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!checkAuth(req, resp)) return;

        String path = req.getPathInfo();
        if (path == null) path = "";
        DataStore ds = DataStore.getInstance();

        if (path.equals("/jobs/action") || path.equals("/jobs/action/")) {
            String jobId = req.getParameter("jobId");
            String action = req.getParameter("action");
            if ("close".equals(action) && jobId != null) {
                ds.closeJob(jobId);
            }
            else if ("activate".equals(action) && jobId != null) {
                ds.openJob(jobId);
            }
            resp.sendRedirect(req.getContextPath() + "/admin/jobs");

        } else if (path.equals("/applications/action") || path.equals("/applications/action/")) {
            String appId = req.getParameter("appId");
            String action = req.getParameter("action");
            String returnTo = req.getParameter("returnTo");

            if (appId != null && action != null) {
                if ("accept".equals(action)) ds.updateApplicationStatus(appId, "accepted");
                else if ("reject".equals(action)) ds.updateApplicationStatus(appId, "rejected");
                else if ("restore".equals(action)) ds.updateApplicationStatus(appId, "pending");
            }
            if (returnTo != null && !returnTo.trim().isEmpty()) {
                if (!returnTo.startsWith("/")) returnTo = "/admin/applications";
                resp.sendRedirect(req.getContextPath() + returnTo);
            } else {
                resp.sendRedirect(req.getContextPath() + "/admin/applications");
            }
        }else if (path.equals("/users/action") || path.equals("/users/action/")) {
            String userId = req.getParameter("userId");
            String action = req.getParameter("action");
            if (userId != null && action != null) {
                if ("deactivate".equals(action)) ds.setUserStatus(userId, "inactive");
                else if ("activate".equals(action)) ds.setUserStatus(userId, "active");
            }
            resp.sendRedirect(req.getContextPath() + "/admin");

        } else if (path.startsWith("/workload/save")) {
            String taId = req.getParameter("taId");
            String hoursStr = req.getParameter("hours");
            User ta = ds.findUserById(taId);

            if (ta != null && hoursStr != null && !hoursStr.trim().isEmpty()) {
                try {
                    int newHours = Integer.parseInt(hoursStr.trim());
                    ta.setWorkload(newHours);
                    ds.updateUser(ta);
                } catch (NumberFormatException e) {}
            }
            resp.sendRedirect(req.getContextPath() + "/admin/workload");

        } else if (path.equals("/profile") || path.equals("/profile/")) {
            String userId = (String) req.getSession().getAttribute("userId");
            User user = ds.findUserById(userId);
            String action = req.getParameter("action");
            if ("changePassword".equals(action)) {
                String error = null;
                if (user != null) {
                    String oldPwd = req.getParameter("oldPassword");
                    String newPwd = req.getParameter("newPassword");
                    String confirmPwd = req.getParameter("confirmPassword");
                    if (!user.getPassword().equals(oldPwd)) {
                        error = "Current password is incorrect.";
                    } else if (newPwd == null || newPwd.length() < 4) {
                        error = "New password must be at least 4 characters.";
                    } else if (!newPwd.equals(confirmPwd)) {
                        error = "New passwords do not match.";
                    } else {
                        user.setPassword(newPwd);
                        ds.updateUser(user);
                    }
                }
                if (error != null) req.setAttribute("error", error);
                else req.setAttribute("success", "Password changed successfully.");
            } else {
                if (user != null) {
                    String name = req.getParameter("name");
                    String phone = req.getParameter("phone");
                    String dept = req.getParameter("department");
                    if (name != null && !name.trim().isEmpty()) user.setName(name.trim());
                    if (phone != null) user.setPhone(phone.trim());
                    if (dept != null) user.setDepartment(dept.trim());
                    ds.updateUser(user);
                    req.getSession().setAttribute("userName", user.getName());
                }
                req.setAttribute("success", "Profile saved successfully.");
            }
            if (user != null) req.setAttribute("user", user.toMap());
            req.getRequestDispatcher("/WEB-INF/jsp/admin/profile.jsp").forward(req, resp);

        } else {
            resp.sendRedirect(req.getContextPath() + "/admin");
        }
    }

    private boolean checkAuth(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return false;
        }
        String userRole = (String) session.getAttribute("userRole");
        if (!"admin".equals(userRole)) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return false;
        }
        return true;
    }
}
