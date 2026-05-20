package com.ta.recruitment.servlet;

import com.ta.recruitment.model.*;
import com.ta.recruitment.service.GeminiService;
import org.apache.poi.xwpf.usermodel.XWPFDocument;
import org.apache.poi.xwpf.usermodel.XWPFParagraph;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.*;
import java.nio.file.Files;
import java.util.*;

@WebServlet("/mo/*")
public class MOServlet extends BaseServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
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
                Map<String,String> m = new LinkedHashMap<>(j.toMap());
                List<Application> jobApps = ds.getApplicationsByJob(j.getJobId());
                m.put("applicantCount", String.valueOf(jobApps.size()));
                if (userId.equals(j.getPostedBy())) {
                    myJobMaps.add(m);
                    if ("active".equals(j.getStatus())) activeCourses++;
                    for (Application a : jobApps) {
                        if ("pending".equals(a.getStatus()))   pendingReviews++;
                        else if ("accepted".equals(a.getStatus())) acceptedTAs++;
                    }
                } else {
                    otherJobMaps.add(m);
                }
            }
            req.setAttribute("myJobs",        myJobMaps);
            req.setAttribute("otherJobs",      otherJobMaps);
            req.setAttribute("activeCourses",  activeCourses);
            req.setAttribute("pendingReviews", pendingReviews);
            req.setAttribute("acceptedTAs",    acceptedTAs);
            User moUser = ds.findUserById(userId);
            if (moUser != null) req.setAttribute("moModules", moUser.getModuleList());
            req.getRequestDispatcher("/WEB-INF/jsp/mo/applicant-list.jsp").forward(req, resp);

        } else if (path.startsWith("/courses/")) {
            String jobId = path.substring("/courses/".length());
            Job job = ds.findJobByJobId(jobId);
            if (job == null) { resp.sendError(404); return; }

            List<Application> apps = ds.getApplicationsByJob(jobId);
            List<Map<String,String>> pendingMaps = new ArrayList<>(),
                    acceptedMaps = new ArrayList<>(), rejectedMaps = new ArrayList<>();
            int pending = 0, accepted = 0, rejected = 0;
            for (Application a : apps) {
                Map<String,String> m = a.toMap();
                enrichAppWithTaInfo(m, a.getTaId(), ds);
                if ("accepted".equals(a.getStatus()))      { accepted++; acceptedMaps.add(m); }
                else if ("rejected".equals(a.getStatus())) { rejected++; rejectedMaps.add(m); }
                else                                       { pending++;  pendingMaps.add(m);  }
            }
            req.setAttribute("pendingApplicants",  pendingMaps);
            req.setAttribute("acceptedApplicants", acceptedMaps);
            req.setAttribute("rejectedApplicants", rejectedMaps);
            req.setAttribute("job",             job.toMap());
            req.setAttribute("courseId",        jobId);
            req.setAttribute("courseTitle",     job.getTitle());
            req.setAttribute("courseCode",      job.getCourseCode());
            req.setAttribute("totalApplicants", apps.size());
            req.setAttribute("pendingCount",    pending);
            req.setAttribute("acceptedCount",   accepted);
            req.setAttribute("rejectedCount",   rejected);
            req.setAttribute("openings",        job.getOpenings());
            req.setAttribute("isFull",          accepted >= job.getOpenings());
            req.setAttribute("isOwner",         userId.equals(job.getPostedBy()));
            req.getRequestDispatcher("/WEB-INF/jsp/mo/course-detail.jsp").forward(req, resp);

        } else if (path.equals("/post-job") || path.equals("/post-job/")) {
            User moUser = ds.findUserById(userId);
            if (moUser != null) req.setAttribute("moModules", moUser.getModuleList());
            req.getRequestDispatcher("/WEB-INF/jsp/mo/post-job.jsp").forward(req, resp);

        } else if (path.startsWith("/cv/download")) {
            String appId = req.getParameter("appId");
            String cvFile = null, taName = "TA";
            if (appId != null) {
                Application app = ds.findApplicationById(appId);
                if (app != null) {
                    cvFile = app.getCvFileName();
                    taName = app.getTaName() != null ? app.getTaName() : "TA";
                    if (cvFile == null || cvFile.isEmpty()) {
                        User ta = ds.findUserById(app.getTaId());
                        if (ta != null) { cvFile = ta.getCvFileName(); if (ta.getName() != null) taName = ta.getName(); }
                    }
                }
            }
            serveCV(req, resp, cvFile, taName);

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
        String path = req.getPathInfo();
        if (path == null) path = "";
        DataStore ds = DataStore.getInstance();
        String userId = (String) req.getSession().getAttribute("userId");

        if (path.equals("/post-job") || path.equals("/post-job/")) {
            User moUser = ds.findUserById(userId);
            Job job = new Job();
            job.setTitle(req.getParameter("title"));
            job.setDescription(req.getParameter("description"));
            job.setDepartment(req.getParameter("department"));
            job.setCourseCode(req.getParameter("courseCode"));
            job.setCourseName(req.getParameter("courseName"));
            job.setPositionType(req.getParameter("positionType"));
            job.setHours(req.getParameter("hours"));
            job.setDuration(req.getParameter("duration"));
            String openingsParam = req.getParameter("openings");
            if (openingsParam != null && !openingsParam.trim().isEmpty()) {
                try { job.setOpenings(Integer.parseInt(openingsParam.trim())); } catch (NumberFormatException ignored) {}
            }
            job.setPostedBy(userId);
            job.setPostedByName(moUser != null ? moUser.getName() : "");
            String reqsParam = req.getParameter("requirements");
            if (reqsParam != null && !reqsParam.trim().isEmpty()) {
                List<String> reqs = new ArrayList<>();
                for (String p : reqsParam.split("\n")) {
                    String t = p.trim();
                    if (!t.isEmpty()) reqs.add(t);
                }
                job.setRequirements(reqs);
            }
            ds.addJob(job);
            resp.sendRedirect(req.getContextPath() + "/mo/applicants");

        } else if (path.startsWith("/select/")) {
            String appId  = req.getParameter("appId");
            String action = req.getParameter("action");
            String jobId  = req.getParameter("jobId");
            if (appId != null && action != null) {
                Application existing = ds.findApplicationById(appId);
                if (existing != null && "pending".equals(existing.getStatus())) {
                    Job appJob = ds.findJobByJobId(existing.getJobId());
                    if (appJob != null && userId.equals(appJob.getPostedBy())) {
                        if ("accept".equals(action))      ds.updateApplicationStatus(appId, "accepted");
                        else if ("reject".equals(action)) ds.updateApplicationStatus(appId, "rejected");
                    }
                }
            }
            String redirect = jobId != null ? "/mo/courses/" + jobId : "/mo/applicants";
            resp.sendRedirect(req.getContextPath() + redirect);

        } else if (path.equals("/delete-job") || path.equals("/delete-job/")) {
            String jobId = req.getParameter("jobId");
            if (jobId != null && !jobId.trim().isEmpty()) {
                Job job = ds.findJobByJobId(jobId);
                if (job != null && userId.equals(job.getPostedBy())) {
                    ds.deleteJob(jobId);
                    ds.getAllApplications().removeIf(app -> app.getJobId().equals(jobId));
                    ds.saveApplications();
                    resp.sendRedirect(req.getContextPath() + "/mo/applicants?success=deleted");
                    return;
                }
            }
            resp.sendRedirect(req.getContextPath() + "/mo/applicants?error=delete");

        } else if (path.equals("/profile") || path.equals("/profile/")) {
            handleProfilePost(req, resp, ds, userId, "/WEB-INF/jsp/mo/profile.jsp");

        } else if (path.equals("/analyze-application") || path.equals("/analyze-application/")) {
            // ── AI 匹配分析接口（AJAX POST，返回纯 JSON）──────────────────────
            resp.setContentType("application/json");
            resp.setCharacterEncoding("UTF-8");
            PrintWriter out = resp.getWriter();

            String appId = req.getParameter("applicationId");
            if (appId == null || appId.trim().isEmpty()) {
                resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.write("{\"error\":\"Missing applicationId\"}");
                return;
            }

            // 1. 查出申请、岗位、申请人
            Application app = ds.findApplicationById(appId);
            if (app == null) {
                resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
                out.write("{\"error\":\"Application not found\"}");
                return;
            }
            Job job = ds.findJobByJobId(app.getJobId());
            if (job == null) {
                resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
                out.write("{\"error\":\"Job not found\"}");
                return;
            }
            // 只有岗位所有者才能触发分析
            if (!userId.equals(job.getPostedBy())) {
                resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
                out.write("{\"error\":\"Permission denied\"}");
                return;
            }
            User ta = ds.findUserById(app.getTaId());

            // 2. 组装 CV 文本上下文
            StringBuilder cvBuilder = new StringBuilder();
            if (ta != null) {
                cvBuilder.append("Name: ").append(ta.getName()).append("\n");
                if (ta.getDepartment() != null && !ta.getDepartment().isEmpty())
                    cvBuilder.append("Department: ").append(ta.getDepartment()).append("\n");
                if (ta.getPhone() != null && !ta.getPhone().isEmpty())
                    cvBuilder.append("Phone: ").append(ta.getPhone()).append("\n");
            }
            String cover = app.getCoverLetter();
            if (cover != null && !cover.trim().isEmpty())
                cvBuilder.append("Cover Letter:\n").append(cover.trim()).append("\n");

            // 3. 读取 CV 文件（优先用申请附件，其次用 TA 账户简历）
            byte[] cvPdfBytes = null;
            String cvFileName = app.getCvFileName();
            if (cvFileName == null || cvFileName.isEmpty()) {
                cvFileName = ta != null ? ta.getCvFileName() : null;
            }
            if (cvFileName != null && !cvFileName.isEmpty()) {
                String uploadsDir = req.getServletContext().getRealPath("/WEB-INF/uploads/cv/");
                File cvFile = new File(uploadsDir, cvFileName);
                if (cvFile.exists() && cvFile.length() > 0) {
                    String lowerName = cvFileName.toLowerCase();
                    if (lowerName.endsWith(".pdf")) {
                        try {
                            byte[] bytes = Files.readAllBytes(cvFile.toPath());
                            // 验证 PDF magic bytes
                            if (bytes.length > 4
                                    && bytes[0] == '%' && bytes[1] == 'P'
                                    && bytes[2] == 'D' && bytes[3] == 'F') {
                                cvPdfBytes = bytes;
                            }
                        } catch (IOException ignored) {}
                    } else if (lowerName.endsWith(".docx")) {
                        // 从 Word 文档提取文本，追加到 CV 上下文
                        try (XWPFDocument doc = new XWPFDocument(new FileInputStream(cvFile))) {
                            StringBuilder wordText = new StringBuilder();
                            for (XWPFParagraph para : doc.getParagraphs()) {
                                String text = para.getText().trim();
                                if (!text.isEmpty()) wordText.append(text).append("\n");
                            }
                            if (wordText.length() > 0) {
                                cvBuilder.append("\nCV Content (from Word document):\n")
                                         .append(wordText);
                            }
                        } catch (Exception ignored) {}
                    }
                }
            }

            // 岗位要求：description + requirements 列表
            StringBuilder reqBuilder = new StringBuilder();
            reqBuilder.append("Job Title: ").append(job.getTitle()).append("\n");
            reqBuilder.append("Course: ").append(job.getCourseName()).append(" (").append(job.getCourseCode()).append(")\n");
            reqBuilder.append("Position Type: ").append(job.getPositionType()).append("\n");
            if (job.getDescription() != null && !job.getDescription().isEmpty()) {
                reqBuilder.append("Description: ").append(job.getDescription()).append("\n");
            }
            if (job.getRequirements() != null && !job.getRequirements().isEmpty()) {
                reqBuilder.append("Requirements:\n");
                for (String r : job.getRequirements()) {
                    reqBuilder.append("- ").append(r).append("\n");
                }
            }
            reqBuilder.append("Openings (total positions needed): ").append(job.getOpenings()).append("\n");

            // 4. 收集 Gemini 新增参数
            // ── 该 TA 当前已录用总工时（直接从 user 读取，由状态变更时自动维护）
            int currentWorkload = ta != null ? ta.getWorkload() : 0;
            // ── 当前岗位报名人数 / 已录取人数
            List<Application> jobApps = ds.getApplicationsByJob(app.getJobId());
            int applicantCount = jobApps.size();
            int acceptedCount  = 0;
            for (Application a2 : jobApps) {
                if ("accepted".equals(a2.getStatus())) acceptedCount++;
            }
            // ── 同课程其他活跃岗位列表
            StringBuilder otherJobsSb = new StringBuilder();
            for (Job j2 : ds.getAllJobs()) {
                if (!j2.getJobId().equals(job.getJobId())
                        && job.getCourseCode() != null
                        && job.getCourseCode().equals(j2.getCourseCode())
                        && "active".equals(j2.getStatus())) {
                    List<Application> j2Apps = ds.getApplicationsByJob(j2.getJobId());
                    int j2Accepted = 0;
                    for (Application a2 : j2Apps) {
                        if ("accepted".equals(a2.getStatus())) j2Accepted++;
                    }
                    otherJobsSb.append("- ").append(j2.getTitle())
                               .append(" (").append(j2.getPositionType()).append(")")
                               .append(", openings: ").append(j2.getOpenings())
                               .append(", accepted: ").append(j2Accepted)
                               .append(", applicants: ").append(j2Apps.size());
                    if (j2.getRequirements() != null && !j2.getRequirements().isEmpty()) {
                        otherJobsSb.append(", requirements: ")
                                   .append(String.join(", ", j2.getRequirements()));
                    }
                    otherJobsSb.append("\n");
                }
            }

            // 5. 调用 Gemini（传入所有参数）
            GeminiService gemini = new GeminiService();
            try {
                Application aiResult = gemini.analyzeMatch(
                        cvBuilder.toString(), reqBuilder.toString(), cvPdfBytes,
                        currentWorkload, applicantCount, acceptedCount, job.getOpenings(), true, otherJobsSb.toString());

                // 6. 持久化 AI 结果（含新字段）
                ds.updateApplicationAiResult(
                    appId,
                    aiResult.getAiMatchScore()                != null ? aiResult.getAiMatchScore() : 0,
                    aiResult.getAiMatchedSkills()             != null ? aiResult.getAiMatchedSkills()  : "",
                    aiResult.getAiMissingSkills()             != null ? aiResult.getAiMissingSkills()  : "",
                    aiResult.getAiReasoning()                 != null ? aiResult.getAiReasoning()      : "",
                    aiResult.getAiRecommendedAlternativeJob() != null ? aiResult.getAiRecommendedAlternativeJob() : ""
                );

                // 7. 将结果以 JSON 返回前端
                String score   = String.valueOf(aiResult.getAiMatchScore() != null ? aiResult.getAiMatchScore() : 0);
                String matched = jsonEsc(aiResult.getAiMatchedSkills());
                String missing = jsonEsc(aiResult.getAiMissingSkills());
                String reason  = jsonEsc(aiResult.getAiReasoning());
                String altJob  = jsonEsc(aiResult.getAiRecommendedAlternativeJob());
                out.write("{\"aiMatchScore\":" + score
                    + ",\"aiMatchedSkills\":\"" + matched + "\""
                    + ",\"aiMissingSkills\":\"" + missing + "\""
                    + ",\"aiReasoning\":\"" + reason + "\""
                    + ",\"aiRecommendedAlternativeJob\":\"" + altJob + "\""
                    + ",\"cached\":false}");
            } catch (Exception e) {
                resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                out.write("{\"error\":\"" + jsonEsc(e.getMessage()) + "\"}");
            }

        } else {
            resp.sendRedirect(req.getContextPath() + "/mo/applicants");
        }
    }

    /** JSON 字符串值转义，与 DataStore.esc() 保持一致 */
    private String jsonEsc(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "");
    }
}