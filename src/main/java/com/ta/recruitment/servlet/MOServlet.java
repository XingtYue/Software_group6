package com.ta.recruitment.servlet;

import com.ta.recruitment.model.*;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.*;

/**
 * Handles all MO-related pages: /mo/applicants, /mo/applicants/{jobId},
 * /mo/post-job, /mo/courses/{jobId}
 */
@WebServlet("/mo/*")
public class MOServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!checkAuth(req, resp, "mo")) return;

        String path = req.getPathInfo();
        if (path == null) path = "/applicants";

        DataStore ds = DataStore.getInstance();
        String userId = (String) req.getSession().getAttribute("userId");

        if (path.equals("/applicants") || path.equals("/applicants/")) {
            // List jobs posted by this MO with applicant counts
            List<Job> myJobs = ds.getJobsByMO(userId);
            List<Map<String,String>> jobMaps = new ArrayList<>();
            for (Job j : myJobs) {
                Map<String,String> m = j.toMap();
                m.put("applicantCount", String.valueOf(ds.getApplicationsByJob(j.getId()).size()));
                jobMaps.add(m);
            }
            req.setAttribute("jobs", jobMaps);
            req.getRequestDispatcher("/WEB-INF/jsp/mo/applicant-list.jsp").forward(req, resp);

        } else if (path.startsWith("/applicants/")) {
            // Applicants for a specific job
            String jobId = path.substring("/applicants/".length());
            Job job = ds.findJobById(jobId);
            if (job == null) { resp.sendError(404); return; }
            List<Application> apps = ds.getApplicationsByJob(jobId);
            List<Map<String,String>> appMaps = new ArrayList<>();
            for (Application a : apps) appMaps.add(a.toMap());
            req.setAttribute("job", job.toMap());
            req.setAttribute("jobId", jobId);
            req.setAttribute("applicants", appMaps);
            req.getRequestDispatcher("/WEB-INF/jsp/mo/applicant-list.jsp").forward(req, resp);

        } else if (path.equals("/post-job") || path.equals("/post-job/")) {
            req.getRequestDispatcher("/WEB-INF/jsp/mo/post-job.jsp").forward(req, resp);

        } else if (path.startsWith("/courses/")) {
            // Course detail (job detail for MO)
            String jobId = path.substring("/courses/".length());
            Job job = ds.findJobById(jobId);
            if (job == null) { resp.sendError(404); return; }
            List<Application> apps = ds.getApplicationsByJob(jobId);
            List<Map<String,String>> appMaps = new ArrayList<>();
            for (Application a : apps) appMaps.add(a.toMap());
            req.setAttribute("job", job.toMap());
            req.setAttribute("jobId", jobId);
            req.setAttribute("applicants", appMaps);
            req.getRequestDispatcher("/WEB-INF/jsp/mo/course-detail.jsp").forward(req, resp);

        } else if (path.equals("/profile") || path.equals("/profile/")) {
            User user = ds.findUserById(userId);
            if (user != null) req.setAttribute("user", user.toMap());
            req.getRequestDispatcher("/WEB-INF/jsp/ta/profile.jsp").forward(req, resp);

        } else {
            resp.sendRedirect(req.getContextPath() + "/mo/applicants");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!checkAuth(req, resp, "mo")) return;

        String path = req.getPathInfo();
        if (path == null) path = "";
        DataStore ds = DataStore.getInstance();
        String userId = (String) req.getSession().getAttribute("userId");
        User moUser = ds.findUserById(userId);

        if (path.equals("/post-job") || path.equals("/post-job/")) {
            // Create new job
            Job job = new Job();
            job.setTitle(req.getParameter("title"));
            job.setDescription(req.getParameter("description"));
            job.setDepartment(req.getParameter("department"));
            job.setCourseCode(req.getParameter("courseCode"));
            job.setHours(req.getParameter("hours"));
            job.setDuration(req.getParameter("duration"));
            job.setPostedBy(userId);
            job.setPostedByName(moUser != null ? moUser.getName() : "");
            String reqsParam = req.getParameter("requirements");
            if (reqsParam != null && !reqsParam.trim().isEmpty()) {
                String[] parts = reqsParam.split("\n");
                List<String> reqs = new ArrayList<>();
                for (String p : parts) {
                    String t = p.trim();
                    if (!t.isEmpty()) reqs.add(t);
                }
                job.setRequirements(reqs);
            }
            ds.addJob(job);
            resp.sendRedirect(req.getContextPath() + "/mo/applicants");

        } else if (path.startsWith("/select/")) {
            // Accept/reject applicant
            String appId = req.getParameter("appId");
            String action = req.getParameter("action");
            String jobId = req.getParameter("jobId");
            if (appId != null && action != null) {
                if ("accept".equals(action)) ds.updateApplicationStatus(appId, "accepted");
                else if ("reject".equals(action)) ds.updateApplicationStatus(appId, "rejected");
            }
            if (jobId != null) {
                resp.sendRedirect(req.getContextPath() + "/mo/courses/" + jobId);
            } else {
                resp.sendRedirect(req.getContextPath() + "/mo/applicants");
            }

        } else if (path.equals("/profile") || path.equals("/profile/")) {
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
            resp.sendRedirect(req.getContextPath() + "/mo/profile");
        } else {
            resp.sendRedirect(req.getContextPath() + "/mo/applicants");
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
