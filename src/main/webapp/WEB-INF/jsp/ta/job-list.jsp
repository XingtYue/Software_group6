<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, java.util.Map, java.util.HashMap, java.util.ArrayList" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Browse Jobs - TA Portal</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
<div class="page-wrapper">
    <%@ include file="taheader.jsp" %>

    <div class="nav-main-row">
        <a href="${pageContext.request.contextPath}/ta/jobs" class="nav-link active">Browse Jobs</a>
        <a href="${pageContext.request.contextPath}/ta/applications" class="nav-link">My Applications</a>
    </div>

    <main class="main-content">
        <div class="content-with-sidebar">
            <div class="content-area">

                <div class="content-header">
                    <div style="max-width:900px;margin:0 auto;">
                        <h2 class="text-2xl mb-2">Available Positions</h2>
                        <p class="text-gray-600 mb-4">Browse and apply for teaching assistant positions</p>

                        <% if (request.getAttribute("errorMsg") != null) { %>
                        <div style="background:#fef2f2;border:1px solid #fca5a5;color:#b91c1c;padding:10px 14px;border-radius:6px;margin-bottom:12px;font-size:13px;">
                            <%= request.getAttribute("errorMsg") %>
                        </div>
                        <% } %>
                        <% if (request.getAttribute("successMsg") != null) { %>
                        <div style="background:#f0fdf4;border:1px solid #86efac;color:#15803d;padding:10px 14px;border-radius:6px;margin-bottom:12px;font-size:13px;">
                            <%= request.getAttribute("successMsg") %>
                        </div>
                        <% } %>

                        <form method="get" action="${pageContext.request.contextPath}/ta/jobs">
                            <input class="search-input" type="search" name="q"
                                   placeholder="Search jobs by title or department..."
                                   value="${param.q != null ? param.q : ''}">
                        </form>
                    </div>
                </div>

                <div class="content-body">
                    <div style="max-width:900px;margin:0 auto;">
                        <%
                            List<Map<String,String>> jobs = (List<Map<String,String>>) request.getAttribute("jobs");
                            if (jobs != null && !jobs.isEmpty()) {
                                Map<String, List<Map<String,String>>> jobsByCourse = new HashMap<String, List<Map<String,String>>>();
                                for (Map<String,String> job : jobs) {
                                    String courseName = job.get("courseName");
                                    if (courseName == null || courseName.trim().isEmpty()) { courseName = "Other Positions"; }
                                    else { courseName = courseName.trim(); }
                                    if (!jobsByCourse.containsKey(courseName)) { jobsByCourse.put(courseName, new ArrayList<Map<String,String>>()); }
                                    jobsByCourse.get(courseName).add(job);
                                }
                                for (Map.Entry<String, List<Map<String,String>>> courseEntry : jobsByCourse.entrySet()) {
                                    String courseName = courseEntry.getKey();
                                    List<Map<String,String>> courseJobs = courseEntry.getValue();
                        %>
                        <h3 style="font-size:14px;font-weight:700;color:#374151;text-transform:uppercase;letter-spacing:0.05em;margin:24px 0 12px;padding-bottom:8px;border-bottom:1px solid #e5e7eb;">
                            <%= courseName %>
                        </h3>

                        <% for (Map<String,String> job : courseJobs) { %>
                        <div class="job-card">
                            <div class="job-card-body">
                                <h3 class="job-card-title">
                                    <%= job.get("title") %>
                                    <% String positionType = job.get("positionType"); if (positionType != null && !positionType.trim().isEmpty()) { %>
                                    <span class="badge badge-outline" style="font-size:11px;"><%= positionType %></span>
                                    <% } %>
                                </h3>
                                <p class="job-card-desc"><%= job.get("description") %></p>
                                <p class="job-card-meta">Department: <%= job.get("department") %></p>
                            </div>
                            <div style="margin-left:16px;flex-shrink:0;">
                                <a href="${pageContext.request.contextPath}/ta/jobs/<%= job.get("jobId") %>"
                                   class="btn btn-primary btn-sm">View Details</a>
                            </div>
                        </div>
                        <% } } } else { %>
                        <div class="empty-state">No jobs available at the moment.</div>
                        <% } %>
                    </div>
                </div>
            </div>

            <div class="sidebar">
                <p class="sidebar-title">OVERVIEW</p>
                <div class="stat-card blue">
                    <p class="stat-label">Active Applications</p>
                    <p class="stat-value blue">${activeApplications}</p>
                </div>
                <div class="stat-card">
                    <p class="stat-label">Available Jobs</p>
                    <p class="stat-value">${totalJobs}</p>
                </div>
                <div class="stat-card green">
                    <p class="stat-label">Accepted Positions</p>
                    <p class="stat-value green">${acceptedPositions}</p>
                </div>

                <div class="sidebar-section">
                    <p class="sidebar-section-title">Quick Actions</p>
                    <div class="space-y-3">
                        <a href="${pageContext.request.contextPath}/ta/applications"
                           class="btn btn-outline btn-full">View Applications</a>
                        <a href="${pageContext.request.contextPath}/ta/profile"
                           class="btn btn-outline btn-full">Update Profile</a>
                    </div>
                </div>
            </div>
        </div>
    </main>
</div>
</body>
</html>
