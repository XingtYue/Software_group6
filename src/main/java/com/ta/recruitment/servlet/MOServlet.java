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
            List<Map<String,String>> courseMaps = new ArrayList<>();
            for (Job j : myJobs) {
                Map<String,String> m = new LinkedHashMap<>();
                m.put("id", j.getJobId());          // use sequential jobId as the link key
                m.put("title", j.getTitle());
                m.put("code", j.getCourseCode() != null ? j.getCourseCode() : "");
                m.put("status", j.getStatus() != null ? j.getStatus() : "active");
                m.put("applicantCount", String.valueOf(ds.getApplicationsByJob(j.getJobId()).size()));
                courseMaps.add(m);
            }
            req.setAttribute("courses", courseMaps);
            req.getRequestDispatcher("/WEB-INF/jsp/mo/applicant-list.jsp").forward(req, resp);

        } else if (path.startsWith("/courses/")) {
            // Course detail – URL contains sequential jobId
            String jobId = path.substring("/courses/".length());
            Job job = ds.findJobByJobId(jobId);
            if (job == null) { resp.sendError(404); return; }
            List<Application> apps = ds.getApplicationsByJob(jobId);
            List<Map<String,String>> appMaps = new ArrayList<>();
            int pending = 0, accepted = 0, rejected = 0;
            for (Application a : apps) {
                appMaps.add(a.toMap());
                if ("accepted".equals(a.getStatus())) accepted++;
                else if ("rejected".equals(a.getStatus())) rejected++;
                else pending++;
            }
            req.setAttribute("applicants", appMaps);
            req.setAttribute("courseId", jobId);
            req.setAttribute("courseTitle", job.getTitle());
            req.setAttribute("courseCode", job.getCourseCode());
            req.setAttribute("totalApplicants", apps.size());
            req.setAttribute("pendingCount", pending);
            req.setAttribute("acceptedCount", accepted);
            req.setAttribute("rejectedCount", rejected);
            req.getRequestDispatcher("/WEB-INF/jsp/mo/course-detail.jsp").forward(req, resp);

        } else if (path.equals("/profile") || path.equals("/profile/")) {
            User user = ds.findUserById(userId);
            if (user != null) req.setAttribute("user", user.toMap());
            req.getRequestDispatcher("/WEB-INF/jsp/mo/profile.jsp").forward(req, resp);

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
                else if ("restore".equals(action)) ds.updateApplicationStatus(appId, "pending");
            }
            if (jobId != null) {
                resp.sendRedirect(req.getContextPath() + "/mo/courses/" + jobId);
            } else {
                resp.sendRedirect(req.getContextPath() + "/mo/applicants");
            }

        } else if (path.equals("/profile") || path.equals("/profile/")) {
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
            req.getRequestDispatcher("/WEB-INF/jsp/mo/profile.jsp").forward(req, resp);
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
