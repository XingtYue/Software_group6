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
                int cnt = ds.getApplicationsByJob(j.getId()).size();
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
            String jobId = path.substring("/jobs/".length());
            Job job = ds.findJobById(jobId);
            if (job == null) { resp.sendError(404); return; }
            List<Application> apps = ds.getApplicationsByJob(jobId);
            List<Map<String,String>> appMaps = new ArrayList<>();
            for (Application a : apps) appMaps.add(a.toMap());
            req.setAttribute("job", job.toMap());
            req.setAttribute("jobId", jobId);
            req.setAttribute("applicants", appMaps);
            req.getRequestDispatcher("/WEB-INF/jsp/admin/job-detail.jsp").forward(req, resp);

        } else if (path.equals("/applications") || path.equals("/applications/")) {
            List<Application> allApps = ds.getAllApplications();
            List<Map<String,String>> appMaps = new ArrayList<>();
            int pending = 0, accepted = 0, rejected = 0;
            for (Application a : allApps) {
                appMaps.add(a.toMap());
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

            req.setAttribute("ta", ta);
            req.getRequestDispatcher("/WEB-INF/jsp/admin/edit-workload.jsp").forward(req, resp);

        } else if (path.equals("/profile") || path.equals("/profile/")) {
            String userId = (String) req.getSession().getAttribute("userId");
            User user = ds.findUserById(userId);
            if (user != null) req.setAttribute("user", user.toMap());
            req.getRequestDispatcher("/WEB-INF/jsp/ta/profile.jsp").forward(req, resp);

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
            resp.sendRedirect(req.getContextPath() + "/admin/jobs");

        } else if (path.equals("/applications/action") || path.equals("/applications/action/")) {
            String appId = req.getParameter("appId");
            String action = req.getParameter("action");
            if (appId != null && action != null) {
                if ("accept".equals(action)) ds.updateApplicationStatus(appId, "accepted");
                else if ("reject".equals(action)) ds.updateApplicationStatus(appId, "rejected");
                else if ("restore".equals(action)) ds.updateApplicationStatus(appId, "pending");
            }
            resp.sendRedirect(req.getContextPath() + "/admin/applications");

        } else if (path.equals("/users/action") || path.equals("/users/action/")) {
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
