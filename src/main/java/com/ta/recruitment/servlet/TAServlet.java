package com.ta.recruitment.servlet;

import com.ta.recruitment.model.*;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.*;
import java.util.*;

@WebServlet("/ta/*")
@MultipartConfig(maxFileSize = 10 * 1024 * 1024)
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
            List<Job> jobs = ds.getActiveJobs();
            List<Map<String,String>> jobMaps = new ArrayList<>();
            for (Job j : jobs) {
                Map<String,String> m = j.toMap();
                // Use sequential jobId for all lookups
                m.put("applicantCount", String.valueOf(ds.getApplicationsByJob(j.getJobId()).size()));
                m.put("hasApplied", String.valueOf(ds.hasApplied(userId, j.getJobId())));
                jobMaps.add(m);
            }
            req.setAttribute("jobs", jobMaps);
            List<Application> myApps = ds.getApplicationsByTA(userId);
            int activeApps = 0, acceptedPositions = 0;
            for (Application a : myApps) {
                if (!"rejected".equals(a.getStatus())) activeApps++;
                if ("accepted".equals(a.getStatus())) acceptedPositions++;
            }
            req.setAttribute("activeApplications", activeApps);
            req.setAttribute("totalJobs", jobs.size());
            req.setAttribute("acceptedPositions", acceptedPositions);
            req.getRequestDispatcher("/WEB-INF/jsp/ta/job-list.jsp").forward(req, resp);

        } else if (path.startsWith("/jobs/")) {
            // URL contains sequential jobId (e.g. /ta/jobs/1)
            String jobId = path.substring("/jobs/".length());
            Job job = ds.findJobByJobId(jobId);
            if (job == null) { resp.sendError(404); return; }
            req.setAttribute("job", job.toMap());
            req.setAttribute("jobId", jobId);
            req.setAttribute("hasApplied", ds.hasApplied(userId, jobId));
            req.setAttribute("requirements", job.getRequirements());
            req.getRequestDispatcher("/WEB-INF/jsp/ta/job-detail.jsp").forward(req, resp);

        } else if (path.startsWith("/apply/")) {
            // URL contains sequential jobId (e.g. /ta/apply/1)
            String jobId = path.substring("/apply/".length());
            Job job = ds.findJobByJobId(jobId);
            if (job == null) { resp.sendError(404); return; }
            if (ds.hasApplied(userId, jobId)) {
                resp.sendRedirect(req.getContextPath() + "/ta/applications");
                return;
            }
            User ta = ds.findUserById(userId);
            req.setAttribute("job", job.toMap());
            req.setAttribute("jobId", jobId);
            req.setAttribute("userCvFileName", ta != null && ta.getCvFileName() != null ? ta.getCvFileName() : "");
            req.getRequestDispatcher("/WEB-INF/jsp/ta/apply-job.jsp").forward(req, resp);


        } else if (path.equals("/applications") || path.equals("/applications/")) {
            List<Application> apps = ds.getApplicationsByTA(userId);
            List<Map<String,String>> appMaps = new ArrayList<>();
            int pending = 0, accepted = 0, rejected = 0;
            for (Application a : apps) {
                appMaps.add(a.toMap());
                if ("accepted".equals(a.getStatus())) accepted++;
                else if ("rejected".equals(a.getStatus())) rejected++;
                else pending++;
            }
            req.setAttribute("applications", appMaps);
            req.setAttribute("pendingCount", pending);
            req.setAttribute("acceptedCount", accepted);
            req.setAttribute("rejectedCount", rejected);
            req.setAttribute("totalCount", apps.size());
            req.getRequestDispatcher("/WEB-INF/jsp/ta/application-status.jsp").forward(req, resp);

        } else if (path.equals("/profile") || path.equals("/profile/")) {
            User user = ds.findUserById(userId);
            if (user != null) req.setAttribute("user", user.toMap());
            req.getRequestDispatcher("/WEB-INF/jsp/ta/profile.jsp").forward(req, resp);

        } else if (path.startsWith("/cv/download")) {
            User user = ds.findUserById(userId);
            String cvFileName = user != null ? user.getCvFileName() : null;
            if (cvFileName == null || cvFileName.isEmpty()) { resp.sendError(404); return; }
            String uploadDir = getServletContext().getRealPath("/WEB-INF/uploads/cv/");
            File cvFile = new File(uploadDir, cvFileName);
            if (!cvFile.exists()) { resp.sendError(404); return; }
            resp.setHeader("Content-Disposition", "attachment; filename=\"" + cvFileName + "\"");
            resp.setContentType("application/octet-stream");
            try (InputStream in = new FileInputStream(cvFile);
                 OutputStream out = resp.getOutputStream()) {
                byte[] buf = new byte[4096];
                int n;
                while ((n = in.read(buf)) != -1) out.write(buf, 0, n);
            }

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
            // URL contains sequential jobId
            String jobId = path.substring("/apply/".length());
            Job job = ds.findJobByJobId(jobId);

            if (job == null || ds.hasApplied(userId, jobId)) {
                resp.sendRedirect(req.getContextPath() + "/ta/applications");
                return;
            }

            User ta = ds.findUserById(userId);
            Application app = new Application();
            app.setJobId(jobId);          // store sequential jobId
            app.setJobTitle(job.getTitle());
            app.setTaId(userId);
            app.setTaName(ta != null ? ta.getName() : "");
            app.setTaEmail(ta != null ? ta.getEmail() : "");
            app.setCoverLetter(req.getParameter("coverLetter"));

            // If user uploads a new CV, save it and update their profile
            String savedCv = saveCvPart(req.getPart("cv"), userId, getServletContext().getRealPath("/WEB-INF/uploads/cv/"));
            if (savedCv != null) {
                if (ta != null) { ta.setCvFileName(savedCv); ds.updateUser(ta); }
                app.setCvFileName(savedCv);
            } else if (ta != null && ta.getCvFileName() != null && !ta.getCvFileName().isEmpty()) {
                // Use existing profile CV
                app.setCvFileName(ta.getCvFileName());
            }

            ds.addApplication(app);
            resp.sendRedirect(req.getContextPath() + "/ta/applications");

        } else if (path.equals("/profile") || path.equals("/profile/")) {
            User user = ds.findUserById(userId);
            String action = req.getParameter("action");

            if ("uploadCV".equals(action)) {
                String savedCv = saveCvPart(req.getPart("cvFile"), userId, getServletContext().getRealPath("/WEB-INF/uploads/cv/"));
                if (savedCv != null && user != null) {
                    user.setCvFileName(savedCv);
                    ds.updateUser(user);
                    req.setAttribute("success", "CV uploaded successfully.");
                } else {
                    req.setAttribute("error", "No file selected or upload failed.");
                }

            } else if ("changePassword".equals(action)) {
                if (user != null) {
                    String oldPwd     = req.getParameter("oldPassword");
                    String newPwd     = req.getParameter("newPassword");
                    String confirmPwd = req.getParameter("confirmPassword");
                    if (oldPwd == null || !oldPwd.equals(user.getPassword())) {
                        req.setAttribute("error", "Current password is incorrect.");
                    } else if (newPwd == null || newPwd.length() < 4) {
                        req.setAttribute("error", "New password must be at least 4 characters.");
                    } else if (!newPwd.equals(confirmPwd)) {
                        req.setAttribute("error", "New passwords do not match.");
                    } else {
                        user.setPassword(newPwd);
                        ds.updateUser(user);
                        req.setAttribute("success", "Password changed successfully.");
                    }
                }

            } else {
                // Default: save profile info
                if (user != null) {
                    String name  = req.getParameter("name");
                    String phone = req.getParameter("phone");
                    String dept  = req.getParameter("department");
                    if (name != null && !name.trim().isEmpty()) user.setName(name.trim());
                    if (phone != null) user.setPhone(phone.trim());
                    if (dept  != null) user.setDepartment(dept.trim());
                    ds.updateUser(user);
                    req.getSession().setAttribute("userName", user.getName());
                }
                req.setAttribute("success", "Profile saved successfully.");
            }

            // Always re-load user map so the page reflects the latest data
            user = ds.findUserById(userId);
            if (user != null) req.setAttribute("user", user.toMap());
            req.getRequestDispatcher("/WEB-INF/jsp/ta/profile.jsp").forward(req, resp);

        } else {
            resp.sendRedirect(req.getContextPath() + "/ta/jobs");
        }
    }

    /**
     * Saves a Part (file upload) to the given directory.
     * Returns the saved filename, or null if nothing was uploaded.
     */
    private String saveCvPart(Part part, String userId, String uploadDir) {
        if (part == null || part.getSize() == 0) return null;
        // Parse filename from Content-Disposition (compatible with older Tomcat versions)
        String originalName = null;
        String disposition = part.getHeader("Content-Disposition");
        if (disposition != null) {
            for (String token : disposition.split(";")) {
                token = token.trim();
                if (token.startsWith("filename")) {
                    originalName = token.substring(token.indexOf('=') + 1).trim().replace("\"", "");
                    break;
                }
            }
        }
        if (originalName == null || originalName.trim().isEmpty()) return null;
        String ext = originalName.contains(".")
                ? originalName.substring(originalName.lastIndexOf('.'))
                : "";
        String savedName = userId + "_cv_" + System.currentTimeMillis() + ext;
        try {
            new File(uploadDir).mkdirs();
            part.write(uploadDir + File.separator + savedName);
            return savedName;
        } catch (IOException e) {
            e.printStackTrace();
            return null;
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