package com.ta.recruitment.servlet;

import com.ta.recruitment.model.*;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
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

        } else {
            resp.sendRedirect(req.getContextPath() + "/mo/applicants");
        }
    }
}