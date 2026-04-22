<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, java.util.Map, java.util.HashMap, java.util.ArrayList" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Browse Jobs - TA Portal</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        .course-group-title {
            font-size: 18px;
            font-weight: 600;
            color: #2F80ED;
            margin: 24px 0 12px 0;
            padding-bottom: 8px;
            border-bottom: 2px solid #f0f0f0;
        }
        .course-group-title:first-child {
            margin-top: 0;
        }
        .position-type-tag {
            display: inline-block;
            background: #eef2ff;
            color: #2F80ED;
            padding: 2px 8px;
            border-radius: 4px;
            font-size: 12px;
            margin-left: 8px;
            vertical-align: middle;
        }
        .alert {
            padding: 10px 16px;
            border-radius: 4px;
            margin-bottom: 16px;
            font-size: 14px;
        }
        .alert-error {
            background: #fef2f2;
            color: #DC2626;
            border: 1px solid #fecaca;
        }
        .alert-success {
            background: #f0fdf4;
            color: #16A34A;
            border: 1px solid #bbf7d0;
        }
    </style>
</head>
<body>
<div class="page-wrapper">
<<<<<<< Updated upstream
  <!-- Header -->
  <header class="site-header">
    <div class="header-inner">
      <div class="header-left">
        <span class="site-title">TA Portal</span>
        <nav>
          <a href="${pageContext.request.contextPath}/ta/jobs" class="nav-link active">Browse Jobs</a>
          <a href="${pageContext.request.contextPath}/ta/applications" class="nav-link">My Applications</a>
        </nav>
      </div>
      <div class="header-right">
        <a href="${pageContext.request.contextPath}/ta/profile" class="btn-icon" title="Profile">
          <svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
            <circle cx="12" cy="8" r="4"/><path d="M4 20c0-4 3.6-7 8-7s8 3 8 7"/>
          </svg>
        </a>
        <a href="${pageContext.request.contextPath}/logout" class="btn btn-outline btn-sm">Logout</a>
      </div>
    </div>
  </header>

  <!-- Main -->
  <main class="main-content">
    <div class="content-with-sidebar">
      <!-- Content Area -->
      <div class="content-area">
        <div class="content-header">
          <div style="max-width:800px;margin:0 auto;">
            <h2 class="text-2xl mb-2">Available Positions</h2>
            <p class="text-gray-600 mb-4">Browse and apply for teaching assistant positions</p>
            <form method="get" action="${pageContext.request.contextPath}/ta/jobs">
              <input class="search-input" type="search" name="q"
                     placeholder="Search jobs by title or department..."
                     value="${param.q != null ? param.q : ''}">
            </form>
          </div>
        </div>

        <div class="content-body">
          <div style="max-width:800px;margin:0 auto;">
            <%
              List<Map<String,String>> jobs = (List<Map<String,String>>) request.getAttribute("jobs");
              if (jobs != null && !jobs.isEmpty()) {
                for (Map<String,String> job : jobs) {
            %>
            <div class="job-card">
              <div class="job-card-body">
                <h3 class="job-card-title"><%= job.get("title") %></h3>
                <p class="job-card-desc"><%= job.get("description") %></p>
                <p class="job-card-meta">Department: <%= job.get("department") %></p>
              </div>
              <div style="margin-left:16px;flex-shrink:0;">
                <a href="${pageContext.request.contextPath}/ta/jobs/<%= job.get("id") %>"
                   class="btn btn-primary btn-sm">View Details</a>
              </div>
            </div>
            <%
                }
              } else {
            %>
            <div class="empty-state">
              <p>No jobs available at the moment.</p>
            </div>
            <% } %>
          </div>
        </div>
      </div>

      <!-- Sidebar -->
      <div class="sidebar">
        <p class="sidebar-title">OVERVIEW</p>
        <div class="stat-card">
          <p class="stat-label">Active Applications</p>
          <p class="stat-value">${activeApplications != null ? activeApplications : 3}</p>
        </div>
        <div class="stat-card">
          <p class="stat-label">Available Jobs</p>
          <p class="stat-value">${totalJobs != null ? totalJobs : 8}</p>
        </div>
        <div class="stat-card">
          <p class="stat-label">Accepted Positions</p>
          <p class="stat-value">${acceptedPositions != null ? acceptedPositions : 1}</p>
        </div>

        <div class="sidebar-section">
          <p class="sidebar-section-title">QUICK ACTIONS</p>
          <div style="display:flex;flex-direction:column;gap:8px;">
            <a href="${pageContext.request.contextPath}/ta/applications"
               class="btn btn-outline btn-full" style="justify-content:flex-start;">View Applications</a>
            <a href="${pageContext.request.contextPath}/ta/profile"
               class="btn btn-outline btn-full" style="justify-content:flex-start;">Update Profile</a>
          </div>
        </div>
      </div>
=======
    <%@ include file="taheader.jsp" %>

    <div class="nav-main-row">
        <a href="${pageContext.request.contextPath}/ta/jobs" class="nav-link active">Browse Jobs</a>
        <a href="${pageContext.request.contextPath}/ta/applications" class="nav-link">My Applications</a>
>>>>>>> Stashed changes
    </div>

    <main class="main-content">
        <div class="content-with-sidebar">
            <!-- Content Area -->
            <div class="content-area">
                <div class="content-header">
                    <div style="max-width:800px;margin:0 auto;">
                        <h2 class="text-2xl mb-2">Available Positions</h2>
                        <p class="text-gray-600 mb-4">Browse and apply for teaching assistant positions</p>

                        <!-- Alert Area -->
                        <% if (request.getAttribute("errorMsg") != null) { %>
                        <div class="alert alert-error"><%= request.getAttribute("errorMsg") %></div>
                        <% } %>
                        <% if (request.getAttribute("successMsg") != null) { %>
                        <div class="alert alert-success"><%= request.getAttribute("successMsg") %></div>
                        <% } %>

                        <form method="get" action="${pageContext.request.contextPath}/ta/jobs">
                            <input class="search-input" type="search" name="q"
                                   placeholder="Search jobs by title or department..."
                                   value="${param.q != null ? param.q : ''}">
                        </form>
                    </div>
                </div>

                <div class="content-body">
                    <div style="max-width:800px;margin:0 auto;">
                        <%
                            List<Map<String,String>> jobs = (List<Map<String,String>>) request.getAttribute("jobs");
                            if (jobs != null && !jobs.isEmpty()) {
                                // Tomcat7 compatible grouping logic
                                Map<String, List<Map<String,String>>> jobsByCourse = new HashMap<String, List<Map<String,String>>>();

                                for (Map<String,String> job : jobs) {
                                    String courseName = job.get("courseName");
                                    if (courseName == null || courseName.trim().isEmpty()) {
                                        courseName = "Other Positions";
                                    } else {
                                        courseName = courseName.trim();
                                    }

                                    if (!jobsByCourse.containsKey(courseName)) {
                                        jobsByCourse.put(courseName, new ArrayList<Map<String,String>>());
                                    }
                                    jobsByCourse.get(courseName).add(job);
                                }

                                // Iterate course groups
                                for (Map.Entry<String, List<Map<String,String>>> courseEntry : jobsByCourse.entrySet()) {
                                    String courseName = courseEntry.getKey();
                                    List<Map<String,String>> courseJobs = courseEntry.getValue();
                        %>
                        <!-- Course Group Title -->
                        <div class="course-group-title"><%= courseName %></div>

                        <%-- Iterate positions in this course --%>
                        <% for (Map<String,String> job : courseJobs) { %>
                        <div class="job-card">
                            <div class="job-card-body">
                                <%-- Job Title + Position Type Tag --%>
                                <h3 class="job-card-title">
                                    <%= job.get("title") %>
                                    <%
                                        String positionType = job.get("positionType");
                                        if (positionType != null && !positionType.trim().isEmpty()) {
                                    %>
                                    <span class="position-type-tag"><%= positionType %></span>
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
                        <% } %>
                        <%
                            }
                        } else {
                        %>
                        <div class="empty-state">
                            <p>No jobs available at the moment.</p>
                        </div>
                        <% } %>
                    </div>
                </div>
            </div>

            <!-- Sidebar (Full English, keep original logic) -->
            <div class="sidebar">
                <p class="sidebar-title">OVERVIEW</p>
                <div class="stat-card">
                    <p class="stat-label">Active Applications</p>
                    <p class="stat-value">${activeApplications}</p>
                </div>
                <div class="stat-card">
                    <p class="stat-label">Available Jobs</p>
                    <p class="stat-value">${totalJobs}</p>
                </div>
                <div class="stat-card">
                    <p class="stat-label">Accepted Positions</p>
                    <p class="stat-value">${acceptedPositions}</p>
                </div>

                <div class="sidebar-section">
                    <p class="sidebar-section-title">QUICK ACTIONS</p>
                    <div style="display:flex;flex-direction:column;gap:8px;">
                        <a href="${pageContext.request.contextPath}/ta/applications"
                           class="btn btn-outline btn-full" style="justify-content:flex-start;">View Applications</a>
                        <a href="${pageContext.request.contextPath}/ta/profile"
                           class="btn btn-outline btn-full" style="justify-content:flex-start;">Update Profile</a>
                    </div>
                </div>
            </div>
        </div>
    </main>
</div>
</body>
</html>