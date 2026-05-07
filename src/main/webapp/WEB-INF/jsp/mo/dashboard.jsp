<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, java.util.Map" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>MO Dashboard - TA Recruitment System</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
<div class="page-wrapper">
  <%@ include file="moheader.jsp" %>

  <div class="nav-main-row">
    <a href="${pageContext.request.contextPath}/mo/dashboard"  class="nav-link active">Dashboard</a>
    <a href="${pageContext.request.contextPath}/mo/applicants" class="nav-link">Review Applicants</a>
    <a href="${pageContext.request.contextPath}/mo/post-job"   class="nav-link">Post New Job</a>
  </div>

  <main class="main-content" style="overflow-y:auto;">

    <!-- Welcome Hero -->
    <div class="welcome-hero">
      <div class="welcome-hero-inner">
        <div class="welcome-title">Welcome back, ${sessionScope.userName}</div>
        <div class="welcome-subtitle">Module Organiser Portal &nbsp;·&nbsp; Manage your TA positions and applicants</div>
      </div>
    </div>

    <!-- Stats -->
    <%
      List<Map<String,String>> myJobsList    = (List<Map<String,String>>) request.getAttribute("myJobsList");
      List<Map<String,String>> otherJobsList = (List<Map<String,String>>) request.getAttribute("otherJobsList");
      int myJobsSize    = (myJobsList    != null) ? myJobsList.size()    : 0;
      int otherJobsSize = (otherJobsList != null) ? otherJobsList.size() : 0;
    %>
    <div class="stats-grid">
      <div class="stat-card">
        <div class="stat-icon">📢</div>
        <div class="stat-value">${myJobs != null ? myJobs : 0}</div>
        <div class="stat-label">My Job Posts</div>
      </div>
      <div class="stat-card yellow">
        <div class="stat-icon">👥</div>
        <div class="stat-value yellow">${totalApplicants != null ? totalApplicants : 0}</div>
        <div class="stat-label">Total Applicants</div>
      </div>
      <div class="stat-card green">
        <div class="stat-icon">✅</div>
        <div class="stat-value green">${acceptedCount != null ? acceptedCount : 0}</div>
        <div class="stat-label">Accepted TAs</div>
      </div>
      <div class="stat-card">
        <div class="stat-icon">⏳</div>
        <div class="stat-value">${pendingCount != null ? pendingCount : 0}</div>
        <div class="stat-label">Pending Review</div>
      </div>
    </div>

    <!-- Quick Actions -->
    <div class="dashboard-actions">
      <a href="${pageContext.request.contextPath}/mo/post-job"   class="btn btn-primary btn-lg">Post New Position</a>
      <a href="${pageContext.request.contextPath}/mo/applicants" class="btn btn-outline btn-lg">Review Applicants</a>
      <a href="${pageContext.request.contextPath}/mo/profile"    class="btn btn-outline btn-lg">Update Profile</a>
    </div>

    <!-- Job Tabs -->
    <div class="page-container" style="padding-top:0;">
      <div class="filter-tabs">
        <button class="filter-tab active" onclick="showJobSection('my', event)">
          My Jobs (<%= myJobsSize %>)
        </button>
        <button class="filter-tab" onclick="showJobSection('all', event)">
          All Jobs (<%= myJobsSize + otherJobsSize %>)
        </button>
      </div>

      <!-- My Jobs -->
      <div id="section-my" class="job-section active">
        <% if (myJobsList != null && !myJobsList.isEmpty()) { %>
        <div class="jobs-grid">
          <% for (Map<String,String> job : myJobsList) {
               String st = job.getOrDefault("status","active"); %>
          <div class="dash-job-card">
            <div class="dash-job-card-header">
              <div>
                <div class="dash-job-title"><%= job.get("title") %></div>
                <div class="dash-job-code"><%= job.getOrDefault("courseCode","N/A") %></div>
              </div>
              <span class="dash-job-status <%= st %>"><%= st %></span>
            </div>
            <div class="dash-job-info">
              <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 9l9-7 9 7v11a2 2 0 01-2 2H5a2 2 0 01-2-2z"/></svg>
              <%= job.getOrDefault("department","N/A") %>
            </div>
            <div class="dash-job-info">
              <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M17 21v-2a4 4 0 00-4-4H5a4 4 0 00-4 4v2"/><circle cx="9" cy="7" r="4"/></svg>
              <%= job.get("applicantCount") %> applicant<%= !"1".equals(job.get("applicantCount")) ? "s" : "" %>
            </div>
            <div class="dash-job-info">
              <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
              <%= job.getOrDefault("postedDate","N/A") %>
            </div>
            <div class="dash-job-actions">
              <a href="${pageContext.request.contextPath}/mo/courses/<%= job.get("jobId") %>" class="btn btn-primary btn-sm">View Details</a>
              <a href="${pageContext.request.contextPath}/mo/edit-job/<%= job.get("jobId") %>"  class="btn btn-outline btn-sm">Edit</a>
            </div>
          </div>
          <% } %>
        </div>
        <% } else { %>
        <div class="no-jobs">You haven't posted any jobs yet. <a href="${pageContext.request.contextPath}/mo/post-job" style="color:#2563eb;">Post one now &rarr;</a></div>
        <% } %>
      </div>

      <!-- All Jobs -->
      <div id="section-all" class="job-section">
        <% boolean hasAny = (myJobsList != null && !myJobsList.isEmpty()) || (otherJobsList != null && !otherJobsList.isEmpty()); %>
        <% if (hasAny) { %>
        <div class="jobs-grid">
          <% if (myJobsList != null) { for (Map<String,String> job : myJobsList) { String st = job.getOrDefault("status","active"); %>
          <div class="dash-job-card">
            <div class="dash-job-card-header">
              <div>
                <div class="dash-job-title"><%= job.get("title") %></div>
                <div class="dash-job-code"><%= job.getOrDefault("courseCode","N/A") %> &nbsp;·&nbsp; You</div>
              </div>
              <span class="dash-job-status <%= st %>"><%= st %></span>
            </div>
            <div class="dash-job-info">
              <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M17 21v-2a4 4 0 00-4-4H5a4 4 0 00-4 4v2"/><circle cx="9" cy="7" r="4"/></svg>
              <%= job.get("applicantCount") %> applicant<%= !"1".equals(job.get("applicantCount")) ? "s" : "" %>
            </div>
            <div class="dash-job-actions">
              <a href="${pageContext.request.contextPath}/mo/courses/<%= job.get("jobId") %>" class="btn btn-primary btn-sm">View Details</a>
              <a href="${pageContext.request.contextPath}/mo/edit-job/<%= job.get("jobId") %>"  class="btn btn-outline btn-sm">Edit</a>
            </div>
          </div>
          <% } } %>
          <% if (otherJobsList != null) { for (Map<String,String> job : otherJobsList) { String st = job.getOrDefault("status","active"); %>
          <div class="dash-job-card">
            <div class="dash-job-card-header">
              <div>
                <div class="dash-job-title"><%= job.get("title") %></div>
                <div class="dash-job-code"><%= job.getOrDefault("courseCode","N/A") %> &nbsp;·&nbsp; <%= job.getOrDefault("postedBy","") %></div>
              </div>
              <span class="dash-job-status <%= st %>"><%= st %></span>
            </div>
            <div class="dash-job-info">
              <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M17 21v-2a4 4 0 00-4-4H5a4 4 0 00-4 4v2"/><circle cx="9" cy="7" r="4"/></svg>
              <%= job.get("applicantCount") %> applicant<%= !"1".equals(job.get("applicantCount")) ? "s" : "" %>
            </div>
            <div class="dash-job-actions">
              <a href="${pageContext.request.contextPath}/mo/courses/<%= job.get("jobId") %>" class="btn btn-outline btn-sm">View Details</a>
            </div>
          </div>
          <% } } %>
        </div>
        <% } else { %>
        <div class="no-jobs">No jobs available yet.</div>
        <% } %>
      </div>
    </div>

  </main>
</div>

<script>
function showJobSection(type, e) {
  document.querySelectorAll('.job-section').forEach(function(el) { el.classList.remove('active'); });
  document.querySelectorAll('.filter-tab').forEach(function(el) { el.classList.remove('active'); });
  document.getElementById('section-' + type).classList.add('active');
  e.target.classList.add('active');
}
</script>
</body>
</html>
