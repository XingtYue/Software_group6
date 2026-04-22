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
public class TAServlet extends BaseServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String path = req.getPathInfo();
        if (path == null) path = "/jobs";

        DataStore ds = DataStore.getInstance();
        String userId = (String) req.getSession().getAttribute("userId");

        if (path.equals("/jobs") || path.equals("/jobs/")) {
            List<Job> jobs = ds.getActiveJobs();
            List<Map<String,String>> jobMaps = new ArrayList<>();
            for (Job j : jobs) {
                Map<String,String> m = j.toMap();
                m.put("applicantCount", String.valueOf(ds.getApplicationsByJob(j.getJobId()).size()));
                m.put("hasApplied", String.valueOf(ds.hasApplied(userId, j.getJobId())));
                jobMaps.add(m);
            }
            List<Application> myApps = ds.getApplicationsByTA(userId);
            int activeApps = 0, acceptedPositions = 0;
            for (Application a : myApps) {
                if (!"rejected".equals(a.getStatus())) activeApps++;
                if ("accepted".equals(a.getStatus()))  acceptedPositions++;
            }
            req.setAttribute("jobs",               jobMaps);
            req.setAttribute("activeApplications", activeApps);
            req.setAttribute("totalJobs",          jobs.size());
            req.setAttribute("acceptedPositions",  acceptedPositions);
            req.getRequestDispatcher("/WEB-INF/jsp/ta/job-list.jsp").forward(req, resp);

        } else if (path.startsWith("/jobs/")) {
            String jobId = path.substring("/jobs/".length());
            Job job = ds.findJobByJobId(jobId);
            if (job == null) { resp.sendError(404); return; }
            req.setAttribute("job",          job.toMap());
            req.setAttribute("jobId",        jobId);
            req.setAttribute("hasApplied",   ds.hasApplied(userId, jobId));
            req.setAttribute("requirements", job.getRequirements());
            req.getRequestDispatcher("/WEB-INF/jsp/ta/job-detail.jsp").forward(req, resp);

        } else if (path.startsWith("/apply/")) {
            String jobId = path.substring("/apply/".length());
            Job job = ds.findJobByJobId(jobId);
            if (job == null) { resp.sendError(404); return; }
            if (ds.hasApplied(userId, jobId)) { resp.sendRedirect(req.getContextPath() + "/ta/applications"); return; }
            User ta = ds.findUserById(userId);
            req.setAttribute("job",             job.toMap());
            req.setAttribute("jobId",           jobId);
            req.setAttribute("userCvFileName",  ta != null && ta.getCvFileName() != null ? ta.getCvFileName() : "");
            req.getRequestDispatcher("/WEB-INF/jsp/ta/apply-job.jsp").forward(req, resp);

        } else if (path.equals("/applications") || path.equals("/applications/")) {
            List<Application> apps = ds.getApplicationsByTA(userId);
            List<Map<String,String>> appMaps = new ArrayList<>();
            int pending = 0, accepted = 0, rejected = 0;
            for (Application a : apps) {
                appMaps.add(a.toMap());
                if ("accepted".equals(a.getStatus()))      accepted++;
                else if ("rejected".equals(a.getStatus())) rejected++;
                else                                       pending++;
            }
            req.setAttribute("applications",  appMaps);
            req.setAttribute("pendingCount",  pending);
            req.setAttribute("acceptedCount", accepted);
            req.setAttribute("rejectedCount", rejected);
            req.setAttribute("totalCount",    apps.size());
            req.getRequestDispatcher("/WEB-INF/jsp/ta/application-status.jsp").forward(req, resp);

        } else if (path.equals("/profile") || path.equals("/profile/")) {
            User user = ds.findUserById(userId);
            if (user != null) req.setAttribute("user", user.toMap());
            req.getRequestDispatcher("/WEB-INF/jsp/ta/profile.jsp").forward(req, resp);

        } else if (path.startsWith("/cv/download")) {
            User user = ds.findUserById(userId);
            String cvFileName = user != null ? user.getCvFileName() : null;
            serveCV(req, resp, cvFileName, user != null && user.getName() != null ? user.getName() : "TA");

        } else {
            resp.sendRedirect(req.getContextPath() + "/ta/jobs");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String path = req.getPathInfo();
        if (path == null) path = "";
        DataStore ds = DataStore.getInstance();
        String userId = (String) req.getSession().getAttribute("userId");

        if (path.startsWith("/apply/")) {
            String jobId = path.substring("/apply/".length());
            Job job = ds.findJobByJobId(jobId);

            // ========== 校验1：岗位是否存在 ==========
            if (job == null) {
                resp.sendError(404);
                return;
            }

            // ========== 校验2：是否重复申请同一岗位 ==========
            if (ds.hasApplied(userId, jobId)) {
                req.setAttribute("errorMsg", "You have already applied for this position, duplicate applications are not allowed!");
                req.setAttribute("job", job.toMap());
                req.setAttribute("jobId", jobId);
                req.setAttribute("hasApplied", true);
                req.setAttribute("requirements", job.getRequirements());
                req.getRequestDispatcher("/WEB-INF/jsp/ta/job-detail.jsp").forward(req, resp);
                return;
            }

// ========== 校验3：同一课程是否超过2个岗位申请 ==========
            int appliedCount = ds.countApplicationsInSameCourse(userId, job.getCourseCode());
            if (appliedCount >= 2) {
                req.setAttribute("errorMsg", "You can apply for a maximum of 2 positions per course, you have reached the application limit!");
                req.setAttribute("job", job.toMap());
                req.setAttribute("jobId", jobId);
                req.setAttribute("hasApplied", false);
                req.setAttribute("requirements", job.getRequirements());
                req.getRequestDispatcher("/WEB-INF/jsp/ta/job-detail.jsp").forward(req, resp);
                return;
            }

            // ========== 校验通过，创建申请记录 ==========
            User ta = ds.findUserById(userId);
            Application app = new Application();
            app.setJobId(jobId);
            app.setJobTitle(job.getTitle());
            // ========== 填充新增的课程/岗位字段 ==========
            app.setCourseCode(job.getCourseCode());
            app.setCourseName(job.getCourseName());
            app.setPositionType(job.getPositionType());
            // ==========================================
            app.setTaId(userId);
            app.setTaName(ta != null ? ta.getName() : "");
            app.setTaEmail(ta != null ? ta.getEmail() : "");
            app.setCoverLetter(req.getParameter("coverLetter"));

            // 保存CV的原有逻辑
            String savedCv = saveCvPart(req.getPart("cv"), userId,
                    getServletContext().getRealPath("/WEB-INF/uploads/cv/"));
            if (savedCv != null) {
                if (ta != null) { ta.setCvFileName(savedCv); ds.updateUser(ta); }
                app.setCvFileName(savedCv);
            } else if (ta != null && ta.getCvFileName() != null && !ta.getCvFileName().isEmpty()) {
                app.setCvFileName(ta.getCvFileName());
            }

            // 保存申请
            ds.addApplication(app);
            resp.sendRedirect(req.getContextPath() + "/ta/applications");

        } else if (path.equals("/profile") || path.equals("/profile/")) {
            String action = req.getParameter("action");
            if ("uploadCV".equals(action)) {
                User user = ds.findUserById(userId);
                String savedCv = saveCvPart(req.getPart("cvFile"), userId,
                        getServletContext().getRealPath("/WEB-INF/uploads/cv/"));
                if (savedCv != null && user != null) {
                    user.setCvFileName(savedCv);
                    ds.updateUser(user);
                    req.setAttribute("success", "CV uploaded successfully.");
                } else {
                    req.setAttribute("error", "No file selected or upload failed.");
                }
                user = ds.findUserById(userId);
                if (user != null) req.setAttribute("user", user.toMap());
                req.getRequestDispatcher("/WEB-INF/jsp/ta/profile.jsp").forward(req, resp);
            } else {
                handleProfilePost(req, resp, ds, userId, "/WEB-INF/jsp/ta/profile.jsp");
            }

        } else {
            resp.sendRedirect(req.getContextPath() + "/ta/jobs");
        }
    }

    private String saveCvPart(Part part, String userId, String uploadDir) {
        if (part == null || part.getSize() == 0) return null;
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
        String ext = originalName.contains(".") ? originalName.substring(originalName.lastIndexOf('.')) : "";
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
}