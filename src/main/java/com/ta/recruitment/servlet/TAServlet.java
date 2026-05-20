package com.ta.recruitment.servlet;

import com.ta.recruitment.model.*;
import com.ta.recruitment.service.GeminiService;
import org.apache.poi.xwpf.usermodel.XWPFDocument;
import org.apache.poi.xwpf.usermodel.XWPFParagraph;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.*;
import java.nio.file.Files;
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
            List<Application> jobApps = ds.getApplicationsByJob(jobId);
            int acceptedCount = 0;
            for (Application a : jobApps) if ("accepted".equals(a.getStatus())) acceptedCount++;
            boolean isFull = acceptedCount >= job.getOpenings();
            req.setAttribute("job",            job.toMap());
            req.setAttribute("jobId",          jobId);
            req.setAttribute("hasApplied",     ds.hasApplied(userId, jobId));
            req.setAttribute("requirements",   job.getRequirements());
            req.setAttribute("openings",       job.getOpenings());
            req.setAttribute("applicantCount", jobApps.size());
            req.setAttribute("acceptedCount",  acceptedCount);
            req.setAttribute("isFull",         isFull);
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
                {// 找到这个申请对应的 Job
                    Job job = ds.findJobByJobId(a.getJobId());

                    // 构建包含 Job 信息的 Map
                    Map<String,String> app = new HashMap<>();
                    app.put("id", a.getId());
                    app.put("jobId", a.getJobId());
                    app.put("jobTitle", a.getJobTitle()); // 或者 job.getTitle()
                    app.put("appliedDate", a.getAppliedDate());
                    app.put("status", a.getStatus());
                    app.put("coverLetter", a.getCoverLetter());

                    // 补充 Job 相关字段（关键！）
                    if (job != null) {
                        app.put("jobDepartment", job.getDepartment());
                        app.put("jobHours", job.getHours());
                        app.put("jobDuration", job.getDuration());
                        app.put("jobStatus", job.getStatus());
                        app.put("jobDescription", job.getDescription());
                    } else {
                        // 找不到 Job 时给默认值，防止前端报错
                        app.put("jobDepartment", "N/A");
                        app.put("jobHours", "N/A");
                        app.put("jobDuration", "N/A");
                        app.put("jobStatus", "N/A");
                        app.put("jobDescription", "N/A");
                    }

                    // AI 分析字段
                    app.put("aiMatchScore",                a.getAiMatchScore() != null ? String.valueOf(a.getAiMatchScore()) : "");
                    app.put("aiMatchedSkills",             a.getAiMatchedSkills()             != null ? a.getAiMatchedSkills()             : "");
                    app.put("aiMissingSkills",             a.getAiMissingSkills()             != null ? a.getAiMissingSkills()             : "");
                    app.put("aiReasoning",                 a.getAiReasoning()                 != null ? a.getAiReasoning()                 : "");
                    app.put("aiRecommendedAlternativeJob", a.getAiRecommendedAlternativeJob() != null ? a.getAiRecommendedAlternativeJob() : "");

                    appMaps.add(app); // 把构建好的 Map 加进去

                    // 原来的状态统计代码不动
                    if ("accepted".equals(a.getStatus()))      accepted++;
                    else if ("rejected".equals(a.getStatus())) rejected++;
                    else                                       pending++;
                }
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

            // ========== 校验2b：岗位是否已满员 ==========
            {
                List<Application> jobAppsCheck = ds.getApplicationsByJob(jobId);
                int acceptedCheck = 0;
                for (Application a : jobAppsCheck) if ("accepted".equals(a.getStatus())) acceptedCheck++;
                if (acceptedCheck >= job.getOpenings()) {
                    int acceptedCount2 = acceptedCheck;
                    List<Application> jobApps2 = jobAppsCheck;
                    req.setAttribute("errorMsg", "This position is now full (" + acceptedCount2 + "/" + job.getOpenings() + " accepted). Applications are no longer accepted.");
                    req.setAttribute("job", job.toMap());
                    req.setAttribute("jobId", jobId);
                    req.setAttribute("hasApplied", false);
                    req.setAttribute("isFull", true);
                    req.setAttribute("openings", job.getOpenings());
                    req.setAttribute("acceptedCount", acceptedCount2);
                    req.setAttribute("applicantCount", jobApps2.size());
                    req.setAttribute("requirements", job.getRequirements());
                    req.getRequestDispatcher("/WEB-INF/jsp/ta/job-detail.jsp").forward(req, resp);
                    return;
                }
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

            // 保存CV：优先使用本次上传的CV；如果没上传，则使用profile中已有的CV
            String savedCv = saveCvPart(req.getPart("cv"), userId,
                    getServletContext().getRealPath("/WEB-INF/uploads/cv/"));

            String finalCvFileName = null;

            if (savedCv != null) {
                finalCvFileName = savedCv;

                // 如果本次上传了新CV，同时更新用户profile中的CV
                if (ta != null) {
                    ta.setCvFileName(savedCv);
                    ds.updateUser(ta);
                }

            } else if (ta != null && ta.getCvFileName() != null && !ta.getCvFileName().isEmpty()) {
                // 如果本次没上传，但profile里已有CV，则使用已有CV
                finalCvFileName = ta.getCvFileName();
            }

// ========== 校验4：申请岗位时必须附带CV ==========
            if (finalCvFileName == null || finalCvFileName.trim().isEmpty()) {
                req.setAttribute("errorMsg", "Please attach a CV before submitting your application.");
                req.setAttribute("job", job.toMap());
                req.setAttribute("jobId", jobId);
                req.setAttribute("requirements", job.getRequirements());
                req.setAttribute("userCvFileName", "");
                req.getRequestDispatcher("/WEB-INF/jsp/ta/apply-job.jsp").forward(req, resp);
                return;
            }

// 设置申请使用的CV
            app.setCvFileName(finalCvFileName);

// 建议顺手设置默认申请状态
            app.setStatus("pending");

// 保存申请
            ds.addApplication(app);

            // 后台异步 AI 分析（不阻塞 TA 跳转）
            final String  fAppId       = app.getId();
            final String  fCvFileName  = finalCvFileName;
            final String  fCoverLetter = app.getCoverLetter();
            final String  fUploadsDir  = getServletContext().getRealPath("/WEB-INF/uploads/cv/");
            final User    fTa          = ta;
            final Job     fJob         = job;
            final String  fUserId      = userId;
            Thread aiThread = new Thread(() -> {
                try {
                    runGeminiAnalysis(fAppId, fCvFileName, fCoverLetter,
                                      fUploadsDir, fTa, fJob, fUserId, ds);
                } catch (Exception ignored) {}
            });
            aiThread.setDaemon(true);
            aiThread.start();

            resp.sendRedirect(req.getContextPath() + "/ta/applications");
        } else if (path.equals("/analyze-application") || path.equals("/analyze-application/")) {
            // ── TA 手动触发/重新分析（AJAX POST，返回纯 JSON）─────────────────
            resp.setContentType("application/json");
            resp.setCharacterEncoding("UTF-8");
            PrintWriter out = resp.getWriter();

            String appId = req.getParameter("applicationId");
            if (appId == null || appId.trim().isEmpty()) {
                resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.write("{\"error\":\"Missing applicationId\"}");
                return;
            }
            Application app = ds.findApplicationById(appId);
            if (app == null || !userId.equals(app.getTaId())) {
                resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
                out.write("{\"error\":\"Application not found or permission denied\"}");
                return;
            }
            Job job = ds.findJobByJobId(app.getJobId());
            if (job == null) {
                resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
                out.write("{\"error\":\"Job not found\"}");
                return;
            }

            User ta = ds.findUserById(userId);
            String uploadsDir = getServletContext().getRealPath("/WEB-INF/uploads/cv/");
            try {
                Application aiResult = runGeminiAnalysis(
                        appId, app.getCvFileName(), app.getCoverLetter(),
                        uploadsDir, ta, job, userId, ds);
                String score = String.valueOf(aiResult.getAiMatchScore() != null ? aiResult.getAiMatchScore() : 0);
                out.write("{\"aiMatchScore\":" + score
                    + ",\"aiMatchedSkills\":\""  + jsonEsc(aiResult.getAiMatchedSkills())             + "\""
                    + ",\"aiMissingSkills\":\""   + jsonEsc(aiResult.getAiMissingSkills())             + "\""
                    + ",\"aiReasoning\":\""       + jsonEsc(aiResult.getAiReasoning())                 + "\""
                    + ",\"aiRecommendedAlternativeJob\":\"" + jsonEsc(aiResult.getAiRecommendedAlternativeJob()) + "\""
                    + ",\"cached\":false}");
            } catch (Exception e) {
                resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                out.write("{\"error\":\"" + jsonEsc(e.getMessage()) + "\"}");
            }

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

    /**
     * Builds CV context, reads CV file, collects competition/workload params,
     * calls GeminiService, persists the result, and returns the populated Application.
     * Safe to call from both background threads and the AJAX endpoint.
     */
    private Application runGeminiAnalysis(String appId, String cvFileName, String coverLetter,
                                          String uploadsDir, User ta, Job job,
                                          String taId, DataStore ds) throws Exception {
        // 1. CV 文本上下文
        StringBuilder cvBuilder = new StringBuilder();
        if (ta != null) {
            cvBuilder.append("Name: ").append(ta.getName()).append("\n");
            if (ta.getDepartment() != null && !ta.getDepartment().isEmpty())
                cvBuilder.append("Department: ").append(ta.getDepartment()).append("\n");
            if (ta.getPhone() != null && !ta.getPhone().isEmpty())
                cvBuilder.append("Phone: ").append(ta.getPhone()).append("\n");
        }
        if (coverLetter != null && !coverLetter.trim().isEmpty())
            cvBuilder.append("Cover Letter:\n").append(coverLetter.trim()).append("\n");

        // 2. 读取 CV 文件
        byte[] cvPdfBytes = null;
        String fname = cvFileName;
        if ((fname == null || fname.isEmpty()) && ta != null) fname = ta.getCvFileName();
        if (fname != null && !fname.isEmpty()) {
            File cvFile = new File(uploadsDir, fname);
            if (cvFile.exists() && cvFile.length() > 0) {
                String lower = fname.toLowerCase();
                if (lower.endsWith(".pdf")) {
                    byte[] bytes = Files.readAllBytes(cvFile.toPath());
                    if (bytes.length > 4 && bytes[0] == '%' && bytes[1] == 'P'
                            && bytes[2] == 'D' && bytes[3] == 'F') {
                        cvPdfBytes = bytes;
                    }
                } else if (lower.endsWith(".docx")) {
                    try (XWPFDocument doc = new XWPFDocument(new FileInputStream(cvFile))) {
                        StringBuilder wordText = new StringBuilder();
                        for (XWPFParagraph p : doc.getParagraphs()) {
                            String t = p.getText().trim();
                            if (!t.isEmpty()) wordText.append(t).append("\n");
                        }
                        if (wordText.length() > 0)
                            cvBuilder.append("\nCV Content (from Word document):\n").append(wordText);
                    } catch (Exception ignored) {}
                }
            }
        }

        // 3. 岗位要求文本
        StringBuilder reqBuilder = new StringBuilder();
        reqBuilder.append("Job Title: ").append(job.getTitle()).append("\n");
        reqBuilder.append("Course: ").append(job.getCourseName())
                  .append(" (").append(job.getCourseCode()).append(")\n");
        reqBuilder.append("Position Type: ").append(job.getPositionType()).append("\n");
        if (job.getDescription() != null && !job.getDescription().isEmpty())
            reqBuilder.append("Description: ").append(job.getDescription()).append("\n");
        if (job.getRequirements() != null && !job.getRequirements().isEmpty()) {
            reqBuilder.append("Requirements:\n");
            for (String r : job.getRequirements()) reqBuilder.append("- ").append(r).append("\n");
        }
        reqBuilder.append("Openings (total positions needed): ").append(job.getOpenings()).append("\n");

        // 4. 竞争参数
        List<Application> jobApps = ds.getApplicationsByJob(job.getJobId());
        int applicantCount = jobApps.size();
        int acceptedCount  = 0;
        for (Application a2 : jobApps) if ("accepted".equals(a2.getStatus())) acceptedCount++;

        // 5. TA 当前工作量
        int currentWorkload = ds.calculateTaWorkload(taId);

        // 6. 同课程其他活跃岗位（TA 尚未申请的）
        StringBuilder otherJobsSb = new StringBuilder();
        for (Job j2 : ds.getAllJobs()) {
            if (!j2.getJobId().equals(job.getJobId())
                    && job.getCourseCode() != null
                    && job.getCourseCode().equals(j2.getCourseCode())
                    && "active".equals(j2.getStatus())
                    && !ds.hasApplied(taId, j2.getJobId())) {
                List<Application> j2Apps = ds.getApplicationsByJob(j2.getJobId());
                int j2Accepted = 0;
                for (Application a2 : j2Apps) if ("accepted".equals(a2.getStatus())) j2Accepted++;
                otherJobsSb.append("- ").append(j2.getTitle())
                           .append(" (").append(j2.getPositionType()).append(")")
                           .append(", openings: ").append(j2.getOpenings())
                           .append(", accepted: ").append(j2Accepted)
                           .append(", applicants: ").append(j2Apps.size());
                if (j2.getRequirements() != null && !j2.getRequirements().isEmpty())
                    otherJobsSb.append(", requirements: ")
                               .append(String.join(", ", j2.getRequirements()));
                otherJobsSb.append("\n");
            }
        }

        // 7. 调用 Gemini
        GeminiService gemini = new GeminiService();
        Application aiResult = gemini.analyzeMatch(
                cvBuilder.toString(), reqBuilder.toString(), cvPdfBytes,
                currentWorkload, applicantCount, acceptedCount, job.getOpenings(), false, otherJobsSb.toString());

        // 8. 持久化
        ds.updateApplicationAiResult(
                appId,
                aiResult.getAiMatchScore()                != null ? aiResult.getAiMatchScore() : 0,
                aiResult.getAiMatchedSkills()             != null ? aiResult.getAiMatchedSkills()             : "",
                aiResult.getAiMissingSkills()             != null ? aiResult.getAiMissingSkills()             : "",
                aiResult.getAiReasoning()                 != null ? aiResult.getAiReasoning()                 : "",
                aiResult.getAiRecommendedAlternativeJob() != null ? aiResult.getAiRecommendedAlternativeJob() : "");
        return aiResult;
    }

    private String jsonEsc(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"")
                .replace("\n", "\\n").replace("\r", "");
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