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
            // List all jobs with applicant counts, categorized by ownership
            List<Job> allJobs = ds.getAllJobs();
            List<Map<String,String>> myJobMaps = new ArrayList<>();
            List<Map<String,String>> otherJobMaps = new ArrayList<>();
            int activeCourses = 0, pendingReviews = 0, acceptedTAs = 0;

            for (Job j : allJobs) {
                Map<String,String> m = new LinkedHashMap<>();
                m.put("id", j.getJobId());
                m.put("title", j.getTitle());
                m.put("code", j.getCourseCode() != null ? j.getCourseCode() : "");
                m.put("status", j.getStatus() != null ? j.getStatus() : "active");
                m.put("department", j.getDepartment() != null ? j.getDepartment() : "");
                m.put("postedBy", j.getPostedByName() != null ? j.getPostedByName() : "");
                m.put("postedDate", j.getPostedDate() != null ? j.getPostedDate() : "");

                List<Application> jobApps = ds.getApplicationsByJob(j.getJobId());
                m.put("applicantCount", String.valueOf(jobApps.size()));

                if (userId.equals(j.getPostedBy())) {
                    myJobMaps.add(m);
                    if ("active".equals(j.getStatus())) activeCourses++;
                    for (Application a : jobApps) {
                        if ("pending".equals(a.getStatus())) pendingReviews++;
                        else if ("accepted".equals(a.getStatus())) acceptedTAs++;
                    }
                } else {
                    otherJobMaps.add(m);
                }
            }

            req.setAttribute("myJobs", myJobMaps);
            req.setAttribute("otherJobs", otherJobMaps);
            req.setAttribute("activeCourses", activeCourses);
            req.setAttribute("pendingReviews", pendingReviews);
            req.setAttribute("acceptedTAs", acceptedTAs);
            req.getRequestDispatcher("/WEB-INF/jsp/mo/applicant-list.jsp").forward(req, resp);

        } else if (path.startsWith("/courses/")) {
            // Course detail – pass TA user details and split by status
            String jobId = path.substring("/courses/".length());
            Job job = ds.findJobByJobId(jobId);
            if (job == null) { resp.sendError(404); return; }
            List<Application> apps = ds.getApplicationsByJob(jobId);
            List<Map<String,String>> pendingMaps = new ArrayList<>();
            List<Map<String,String>> acceptedMaps = new ArrayList<>();
            List<Map<String,String>> rejectedMaps = new ArrayList<>();
            int pending = 0, accepted = 0, rejected = 0;
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
                if ("accepted".equals(a.getStatus())) { accepted++; acceptedMaps.add(appMap); }
                else if ("rejected".equals(a.getStatus())) { rejected++; rejectedMaps.add(appMap); }
                else { pending++; pendingMaps.add(appMap); }
            }
            req.setAttribute("pendingApplicants", pendingMaps);
            req.setAttribute("acceptedApplicants", acceptedMaps);
            req.setAttribute("rejectedApplicants", rejectedMaps);
            req.setAttribute("job", job.toMap());
            req.setAttribute("courseId", jobId);
            req.setAttribute("courseTitle", job.getTitle());
            req.setAttribute("courseCode", job.getCourseCode());
            req.setAttribute("totalApplicants", apps.size());
            req.setAttribute("pendingCount", pending);
            req.setAttribute("acceptedCount", accepted);
            req.setAttribute("rejectedCount", rejected);
            req.getRequestDispatcher("/WEB-INF/jsp/mo/course-detail.jsp").forward(req, resp);

        } else if (path.equals("/post-job") || path.equals("/post-job/")) {
            req.getRequestDispatcher("/WEB-INF/jsp/mo/post-job.jsp").forward(req, resp);

        } else if (path.startsWith("/cv/download")) {
            // Serve TA's CV file for MO review
            String appId = req.getParameter("appId");
            String cvFile = null;
            String taName = "TA";
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
            if (cvFile == null || cvFile.isEmpty()) { resp.sendError(404, "CV not found"); return; }
            String uploadsDir = req.getServletContext().getRealPath("/WEB-INF/uploads/cv/");
            java.io.File file = new java.io.File(uploadsDir, cvFile);
            if (!file.exists()) { resp.sendError(404, "CV file not found"); return; }
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
            // Accept/reject applicant – MO can only modify pending applications
            String appId = req.getParameter("appId");
            String action = req.getParameter("action");
            String jobId = req.getParameter("jobId");
            if (appId != null && action != null) {
                Application existingApp = ds.findApplicationById(appId);
                if (existingApp != null && "pending".equals(existingApp.getStatus())) {
                    if ("accept".equals(action)) ds.updateApplicationStatus(appId, "accepted");
                    else if ("reject".equals(action)) ds.updateApplicationStatus(appId, "rejected");
                }
                // accepted/rejected applications can only be changed by admin
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
