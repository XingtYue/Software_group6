package com.ta.recruitment.servlet;

import com.ta.recruitment.model.*;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.*;

/**
 * Handles all TA-related pages: /ta/jobs, /ta/jobs/{id}, /ta/apply/{id},
 * /ta/applications, /ta/profile
 */
@WebServlet("/ta/*")
public class TAServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!checkAuth(req, resp, "ta")) return;

        String path = req.getPathInfo();
        if (path == null) path = "/jobs";

        DataStore ds = DataStore.getInstance();
        String userId = (String) req.getSession().getAttribute("userId");

        if (path.equals("/jobs") || path.equals("/jobs/")) {
            // Job list
            List<Job> jobs = ds.getActiveJobs();
            List<Map<String,String>> jobMaps = new ArrayList<>();
            for (Job j : jobs) {
                Map<String,String> m = j.toMap();
                m.put("applicantCount", String.valueOf(ds.getApplicationsByJob(j.getId()).size()));
                m.put("hasApplied", String.valueOf(ds.hasApplied(userId, j.getId())));
                jobMaps.add(m);
            }
            req.setAttribute("jobs", jobMaps);
            req.getRequestDispatcher("/WEB-INF/jsp/ta/job-list.jsp").forward(req, resp);

        } else if (path.startsWith("/jobs/")) {
            // Job detail
            String jobId = path.substring("/jobs/".length());
            Job job = ds.findJobById(jobId);
            if (job == null) { resp.sendError(404); return; }
            req.setAttribute("job", job.toMap());
            req.setAttribute("jobId", jobId);
            req.setAttribute("hasApplied", ds.hasApplied(userId, jobId));
            req.getRequestDispatcher("/WEB-INF/jsp/ta/job-detail.jsp").forward(req, resp);

        } else if (path.startsWith("/apply/")) {
            // Apply form
            String jobId = path.substring("/apply/".length());
            Job job = ds.findJobById(jobId);
            if (job == null) { resp.sendError(404); return; }
            if (ds.hasApplied(userId, jobId)) {
                resp.sendRedirect(req.getContextPath() + "/ta/applications");
                return;
            }
            req.setAttribute("job", job.toMap());
            req.setAttribute("jobId", jobId);
            req.getRequestDispatcher("/WEB-INF/jsp/ta/apply-job.jsp").forward(req, resp);

        } else if (path.equals("/applications") || path.equals("/applications/")) {
            // Application status
            List<Application> apps = ds.getApplicationsByTA(userId);
            List<Map<String,String>> appMaps = new ArrayList<>();
            for (Application a : apps) appMaps.add(a.toMap());
            req.setAttribute("applications", appMaps);
            req.getRequestDispatcher("/WEB-INF/jsp/ta/application-status.jsp").forward(req, resp);

        } else if (path.equals("/profile") || path.equals("/profile/")) {
            User user = ds.findUserById(userId);
            if (user != null) req.setAttribute("user", user.toMap());
            req.getRequestDispatcher("/WEB-INF/jsp/ta/profile.jsp").forward(req, resp);

        } else {
            resp.sendRedirect(req.getContextPath() + "/ta/jobs");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!checkAuth(req, resp, "ta")) return;

        String path = req.getPathInfo();
        if (path == null) path = "";
        DataStore ds = DataStore.getInstance();
        String userId = (String) req.getSession().getAttribute("userId");

        if (path.startsWith("/apply/")) {
            // Submit application
            String jobId = path.substring("/apply/".length());
            Job job = ds.findJobById(jobId);
            if (job == null || ds.hasApplied(userId, jobId)) {
                resp.sendRedirect(req.getContextPath() + "/ta/applications");
                return;
            }
            User ta = ds.findUserById(userId);
            Application app = new Application();
            app.setJobId(jobId);
            app.setJobTitle(job.getTitle());
            app.setTaId(userId);
            app.setTaName(ta != null ? ta.getName() : "");
            app.setTaEmail(ta != null ? ta.getEmail() : "");
            app.setCoverLetter(req.getParameter("coverLetter"));
            ds.addApplication(app);
            resp.sendRedirect(req.getContextPath() + "/ta/applications");

        } else if (path.equals("/profile") || path.equals("/profile/")) {
            // Update profile
            User user = ds.findUserById(userId);
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
            resp.sendRedirect(req.getContextPath() + "/ta/profile");
        } else {
            resp.sendRedirect(req.getContextPath() + "/ta/jobs");
        }
    }

    private boolean checkAuth(HttpServletRequest req, HttpServletResponse resp, String role)
            throws IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return false;
        }
        String userRole = (String) session.getAttribute("userRole");
        if (!role.equals(userRole)) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return false;
        }
        return true;
    }
}
