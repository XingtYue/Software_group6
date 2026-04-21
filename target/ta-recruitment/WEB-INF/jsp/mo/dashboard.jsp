<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, java.util.Map" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>MO Dashboard - TA Recruitment System</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
  <style>
    .filter-tabs {
      display: flex;
      gap: 12px;
      margin: 24px 0 16px;
      border-bottom: 2px solid #e5e7eb;
    }
    .filter-tab {
      padding: 10px 20px;
      background: none;
      border: none;
      border-bottom: 3px solid transparent;
      cursor: pointer;
      font-size: 15px;
      font-weight: 500;
      color: #6b7280;
      transition: all 0.2s;
      margin-bottom: -2px;
    }
    .filter-tab:hover {
      color: #374151;
    }
    .filter-tab.active {
      color: #2563eb;
      border-bottom-color: #2563eb;
    }
    .jobs-grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
      gap: 20px;
      margin-top: 20px;
    }
    .job-card {
      background: #fff;
      border: 1px solid #e5e7eb;
      border-radius: 8px;
      padding: 20px;
      transition: box-shadow 0.2s;
    }
    .job-card:hover {
      box-shadow: 0 4px 12px rgba(0,0,0,0.1);
    }
    .job-card-header {
      display: flex;
      justify-content: space-between;
      align-items: start;
      margin-bottom: 12px;
    }
    .job-title {
      font-size: 16px;
      font-weight: 600;
      color: #111827;
      margin-bottom: 4px;
    }
    .job-code {
      font-size: 13px;
      color: #6b7280;
    }
    .job-status {
      padding: 4px 10px;
      border-radius: 12px;
      font-size: 12px;
      font-weight: 500;
    }
    .job-status.active {
      background: #dcfce7;
      color: #16a34a;
    }
    .job-status.closed {
      background: #fee2e2;
      color: #dc2626;
    }
    .job-info {
      font-size: 13px;
      color: #6b7280;
      margin-bottom: 8px;
    }
    .job-actions {
      display: flex;
      gap: 8px;
      margin-top: 16px;
    }
    .no-jobs {
      color: #9ca3af;
      font-style: italic;
      padding: 40px;
      text-align: center;
    }
    .job-section {
      display: none;
    }
    .job-section.active {
      display: block;
    }
  </style>
</head>
<body>
<nav class="navbar">
  <div class="navbar-brand">
    <span class="brand-icon">🎓</span>
    <span>TA Recruitment</span>
  </div>
  <div class="navbar-links">
    <a href="${pageContext.request.contextPath}/mo/dashboard" class="nav-link active">Dashboard</a>
    <a href="${pageContext.request.contextPath}/mo/applicants" class="nav-link">Applicants</a>
    <a href="${pageContext.request.contextPath}/mo/post-job" class="nav-link">Post Job</a>
    <a href="${pageContext.request.contextPath}/mo/profile" class="nav-link">Profile</a>
    <a href="${pageContext.request.contextPath}/logout" class="nav-link logout-link">Logout</a>
  </div>
</nav>

<div class="page-container">
  <div class="page-header">
    <h1 class="page-title">Welcome, ${sessionScope.userName}!</h1>
    <p class="page-subtitle">Module Organiser Portal</p>
  </div>

  <div class="stats-grid">
    <div class="stat-card">
      <div class="stat-icon">📢</div>
      <div class="stat-value">${myJobs != null ? myJobs : 0}</div>
      <div class="stat-label">My Job Posts</div>
    </div>
    <div class="stat-card">
      <div class="stat-icon">👥</div>
      <div class="stat-value">${totalApplicants != null ? totalApplicants : 0}</div>
      <div class="stat-label">Total Applicants</div>
    </div>
    <div class="stat-card">
      <div class="stat-icon">✅</div>
      <div class="stat-value">${acceptedCount != null ? acceptedCount : 0}</div>
      <div class="stat-label">Accepted TAs</div>
    </div>
    <div class="stat-card">
      <div class="stat-icon">⏳</div>
      <div class="stat-value">${pendingCount != null ? pendingCount : 0}</div>
      <div class="stat-label">Pending Review</div>
    </div>
  </div>

  <div class="dashboard-actions">
    <a href="${pageContext.request.contextPath}/mo/post-job" class="btn btn-primary btn-lg">
      ➕ Post New Job
    </a>
    <a href="${pageContext.request.contextPath}/mo/applicants" class="btn btn-secondary btn-lg">
      👥 View Applicants
    </a>
    <a href="${pageContext.request.contextPath}/mo/profile" class="btn btn-outline btn-lg">
      👤 Update Profile
    </a>
  </div>

  <%
    List<Map<String,String>> myJobsList = (List<Map<String,String>>) request.getAttribute("myJobsList");
    List<Map<String,String>> otherJobsList = (List<Map<String,String>>) request.getAttribute("otherJobsList");
    int myJobsSize = (myJobsList != null) ? myJobsList.size() : 0;
    int otherJobsSize = (otherJobsList != null) ? otherJobsList.size() : 0;
  %>

  <!-- Filter Tabs -->
  <div class="filter-tabs">
    <button class="filter-tab active" onclick="showJobSection('my')">
      My Jobs (<%= myJobsSize %>)
    </button>
    <button class="filter-tab" onclick="showJobSection('all')">
      All Jobs (<%= myJobsSize + otherJobsSize %>)
    </button>
  </div>

  <!-- My Jobs Section -->
  <div id="section-my" class="job-section active">
    <% if (myJobsList != null && !myJobsList.isEmpty()) { %>
      <div class="jobs-grid">
        <% for (Map<String,String> job : myJobsList) { %>
          <div class="job-card">
            <div class="job-card-header">
              <div>
                <div class="job-title"><%= job.get("title") %></div>
                <div class="job-code"><%= job.get("courseCode") != null && !job.get("courseCode").isEmpty() ? job.get("courseCode") : "N/A" %></div>
              </div>
              <span class="job-status <%= job.get("status") %>"><%= job.get("status") %></span>
            </div>
            <div class="job-info">Department: <%= job.get("department") != null && !job.get("department").isEmpty() ? job.get("department") : "N/A" %></div>
            <div class="job-info">Applicants: <%= job.get("applicantCount") %></div>
            <div class="job-info">Posted: <%= job.get("postedDate") != null && !job.get("postedDate").isEmpty() ? job.get("postedDate") : "N/A" %></div>
            <div class="job-actions">
              <a href="${pageContext.request.contextPath}/mo/courses/<%= job.get("jobId") %>" class="btn btn-primary btn-sm">View Details</a>
              <a href="${pageContext.request.contextPath}/mo/edit-job/<%= job.get("jobId") %>" class="btn btn-outline btn-sm">Edit</a>
            </div>
          </div>
        <% } %>
      </div>
    <% } else { %>
      <div class="no-jobs">You haven't posted any jobs yet.</div>
    <% } %>
  </div>

  <!-- All Jobs Section -->
  <div id="section-all" class="job-section">
    <% if ((myJobsList != null && !myJobsList.isEmpty()) || (otherJobsList != null && !otherJobsList.isEmpty())) { %>
      <div class="jobs-grid">
        <!-- My Jobs -->
        <% if (myJobsList != null) {
          for (Map<String,String> job : myJobsList) { %>
          <div class="job-card">
            <div class="job-card-header">
              <div>
                <div class="job-title"><%= job.get("title") %></div>
                <div class="job-code"><%= job.get("courseCode") != null && !job.get("courseCode").isEmpty() ? job.get("courseCode") : "N/A" %></div>
              </div>
              <span class="job-status <%= job.get("status") %>"><%= job.get("status") %></span>
            </div>
            <div class="job-info">Department: <%= job.get("department") != null && !job.get("department").isEmpty() ? job.get("department") : "N/A" %></div>
            <div class="job-info">Posted by: You</div>
            <div class="job-info">Applicants: <%= job.get("applicantCount") %></div>
            <div class="job-info">Posted: <%= job.get("postedDate") != null && !job.get("postedDate").isEmpty() ? job.get("postedDate") : "N/A" %></div>
            <div class="job-actions">
              <a href="${pageContext.request.contextPath}/mo/courses/<%= job.get("jobId") %>" class="btn btn-primary btn-sm">View Details</a>
              <a href="${pageContext.request.contextPath}/mo/edit-job/<%= job.get("jobId") %>" class="btn btn-outline btn-sm">Edit</a>
            </div>
          </div>
        <% }
        } %>

        <!-- Other Jobs -->
        <% if (otherJobsList != null) {
          for (Map<String,String> job : otherJobsList) { %>
          <div class="job-card">
            <div class="job-card-header">
              <div>
                <div class="job-title"><%= job.get("title") %></div>
                <div class="job-code"><%= job.get("courseCode") != null && !job.get("courseCode").isEmpty() ? job.get("courseCode") : "N/A" %></div>
              </div>
              <span class="job-status <%= job.get("status") %>"><%= job.get("status") %></span>
            </div>
            <div class="job-info">Department: <%= job.get("department") != null && !job.get("department").isEmpty() ? job.get("department") : "N/A" %></div>
            <div class="job-info">Posted by: <%= job.get("postedBy") %></div>
            <div class="job-info">Applicants: <%= job.get("applicantCount") %></div>
            <div class="job-info">Posted: <%= job.get("postedDate") != null && !job.get("postedDate").isEmpty() ? job.get("postedDate") : "N/A" %></div>
            <div class="job-actions">
              <a href="${pageContext.request.contextPath}/mo/courses/<%= job.get("jobId") %>" class="btn btn-outline btn-sm">View Details</a>
            </div>
          </div>
        <% }
        } %>
      </div>
    <% } else { %>
      <div class="no-jobs">No jobs available.</div>
    <% } %>
  </div>
</div>

<script>
function showJobSection(type) {
  // Hide all sections
  document.querySelectorAll('.job-section').forEach(function(el) {
    el.classList.remove('active');
  });

  // Remove active from all tabs
  document.querySelectorAll('.filter-tab').forEach(function(el) {
    el.classList.remove('active');
  });

  // Show selected section
  document.getElementById('section-' + type).classList.add('active');

  // Activate clicked tab
  event.target.classList.add('active');
}
</script>
</body>
</html>
