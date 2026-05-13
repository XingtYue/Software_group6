package com.ta.recruitment.servlet;

import com.ta.recruitment.model.*;
import com.ta.recruitment.service.GeminiService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
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

            // 2. 组装输入文本
            // 简历内容：优先用 coverLetter，拼上 TA 基础信息补充上下文
            StringBuilder cvBuilder = new StringBuilder();
            if (ta != null) {
                cvBuilder.append("Name: ").append(ta.getName()).append("\n");
                cvBuilder.append("Department: ").append(ta.getDepartment() != null ? ta.getDepartment() : "N/A").append("\n");
            }
            String cover = app.getCoverLetter();
            if (cover != null && !cover.trim().isEmpty()) {
                cvBuilder.append("Cover Letter:\n").append(cover);
            } else {
                cvBuilder.append("Cover Letter: (not provided)");
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

            // 3. 调用 Gemini
            GeminiService gemini = new GeminiService();
            Application aiResult = gemini.analyzeMatch(cvBuilder.toString(), reqBuilder.toString());

            // 4. 持久化 AI 结果
            ds.updateApplicationAiResult(
                appId,
                aiResult.getAiMatchScore()     != null ? aiResult.getAiMatchScore() : 0,
                aiResult.getAiMatchedSkills()  != null ? aiResult.getAiMatchedSkills()  : "",
                aiResult.getAiMissingSkills()  != null ? aiResult.getAiMissingSkills()  : "",
                aiResult.getAiReasoning()      != null ? aiResult.getAiReasoning()      : ""
            );

            // 5. 将结果以 JSON 返回前端（手拼，与项目风格一致）
            String score   = String.valueOf(aiResult.getAiMatchScore() != null ? aiResult.getAiMatchScore() : 0);
            String matched = jsonEsc(aiResult.getAiMatchedSkills());
            String missing = jsonEsc(aiResult.getAiMissingSkills());
            String reason  = jsonEsc(aiResult.getAiReasoning());
            out.write("{\"aiMatchScore\":" + score
                + ",\"aiMatchedSkills\":\"" + matched + "\""
                + ",\"aiMissingSkills\":\"" + missing + "\""
                + ",\"aiReasoning\":\"" + reason + "\"}");

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