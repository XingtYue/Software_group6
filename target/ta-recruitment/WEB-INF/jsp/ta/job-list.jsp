<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, java.util.Map" %>
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
                <a href="${pageContext.request.contextPath}/ta/jobs/<%= job.get("jobId") %>"
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
