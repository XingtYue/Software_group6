<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, java.util.Map" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Review Applicants - MO Portal</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
  <style>
    .filter-tabs {
      display: flex;
      gap: 12px;
      margin-bottom: 16px;
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
    .job-section {
      display: none;
    }
    .job-section.active {
      display: block;
    }
    .course-card {
      background: #fff;
      border: 1px solid #e5e7eb;
      border-radius: 8px;
      padding: 20px;
      margin-bottom: 12px;
      display: flex;
      justify-content: space-between;
      align-items: center;
      transition: all 0.2s;
    }
    .course-card:hover {
      box-shadow: 0 2px 8px rgba(0,0,0,0.1);
      border-color: #d1d5db;
    }
    .course-meta {
      font-size: 12px;
      color: #9ca3af;
      margin-top: 4px;
    }
  </style>
</head>
<body>
<div class="page-wrapper">
   <%@ include file="moheader.jsp" %>

   <div class="nav-main-row">
          <a href="${pageContext.request.contextPath}/mo/applicants" class="nav-link active">Review Applicants</a>
          <a href="${pageContext.request.contextPath}/mo/post-job" class="nav-link">Post New Job</a>
   </div>
  <main class="main-content">
    <div class="content-with-sidebar">
      <div class="content-area">
        <div class="content-header">
          <div style="max-width:800px;margin:0 auto;">
            <h2 class="text-2xl mb-2">Review Applicants</h2>
            <p class="text-gray-600">Select a course to review applicants</p>
          </div>
        </div>

        <div class="content-body">
          <div style="max-width:800px;margin:0 auto;">
            <%
              List<Map<String,String>> myJobs = (List<Map<String,String>>) request.getAttribute("myJobs");
              List<Map<String,String>> otherJobs = (List<Map<String,String>>) request.getAttribute("otherJobs");
              int myJobsSize = (myJobs != null) ? myJobs.size() : 0;
              int otherJobsSize = (otherJobs != null) ? otherJobs.size() : 0;
              int totalJobs = myJobsSize + otherJobsSize;
            %>

            <!-- Filter Tabs -->
            <div class="filter-tabs">
              <button class="filter-tab active" onclick="showJobSection('my')">
                My Jobs (<%= myJobsSize %>)
              </button>
              <button class="filter-tab" onclick="showJobSection('all')">
                All Jobs (<%= totalJobs %>)
              </button>
            </div>

            <!-- My Jobs Section -->
            <div id="section-my" class="job-section active">
              <% if (myJobs != null && !myJobs.isEmpty()) {
                for (Map<String,String> course : myJobs) {
              %>
              <a href="${pageContext.request.contextPath}/mo/courses/<%= course.get("id") %>"
                 style="text-decoration:none;color:inherit;">
                <div class="course-card">
                  <div>
                    <h3 style="font-size:16px;font-weight:500;margin-bottom:4px;"><%= course.get("title") %></h3>
                    <p class="text-sm text-gray-600">Code: <%= course.get("code") %></p>
                    <p class="course-meta">Department: <%= course.get("department") %> | Posted: <%= course.get("postedDate") %></p>
                  </div>
                  <div style="text-align:right;">
                    <p style="font-size:22px;font-weight:500;"><%= course.get("applicantCount") %></p>
                    <p class="text-sm text-gray-600">applicants</p>
                  </div>
                </div>
              </a>
              <%
                }
              } else {
              %>
              <div class="empty-state">
                <p>You haven't posted any jobs yet. <a href="${pageContext.request.contextPath}/mo/post-job">Post a job</a> to get started.</p>
              </div>
              <% } %>
            </div>

            <!-- All Jobs Section -->
            <div id="section-all" class="job-section">
              <% if (totalJobs > 0) {
                // Display my jobs first
                if (myJobs != null) {
                  for (Map<String,String> course : myJobs) {
              %>
              <a href="${pageContext.request.contextPath}/mo/courses/<%= course.get("id") %>"
                 style="text-decoration:none;color:inherit;">
                <div class="course-card">
                  <div>
                    <h3 style="font-size:16px;font-weight:500;margin-bottom:4px;"><%= course.get("title") %></h3>
                    <p class="text-sm text-gray-600">Code: <%= course.get("code") %></p>
                    <p class="course-meta">Posted by: You | Department: <%= course.get("department") %> | <%= course.get("postedDate") %></p>
                  </div>
                  <div style="text-align:right;">
                    <p style="font-size:22px;font-weight:500;"><%= course.get("applicantCount") %></p>
                    <p class="text-sm text-gray-600">applicants</p>
                  </div>
                </div>
              </a>
              <%
                  }
                }
                // Display other jobs
                if (otherJobs != null) {
                  for (Map<String,String> course : otherJobs) {
              %>
              <a href="${pageContext.request.contextPath}/mo/courses/<%= course.get("id") %>"
                 style="text-decoration:none;color:inherit;">
                <div class="course-card">
                  <div>
                    <h3 style="font-size:16px;font-weight:500;margin-bottom:4px;"><%= course.get("title") %></h3>
                    <p class="text-sm text-gray-600">Code: <%= course.get("code") %></p>
                    <p class="course-meta">Posted by: <%= course.get("postedBy") %> | Department: <%= course.get("department") %> | <%= course.get("postedDate") %></p>
                  </div>
                  <div style="text-align:right;">
                    <p style="font-size:22px;font-weight:500;"><%= course.get("applicantCount") %></p>
                    <p class="text-sm text-gray-600">applicants</p>
                  </div>
                </div>
              </a>
              <%
                  }
                }
              } else {
              %>
              <div class="empty-state">
                <p>No jobs available. <a href="${pageContext.request.contextPath}/mo/post-job">Post a job</a> to get started.</p>
              </div>
              <% } %>
            </div>

          </div>
        </div>
      </div>

      <!-- Sidebar -->
      <div class="sidebar">
        <p class="sidebar-title">OVERVIEW</p>
        <div class="stat-card">
          <p class="stat-label">Active Courses</p>
          <p class="stat-value">${activeCourses != null ? activeCourses : 0}</p>
        </div>
        <div class="stat-card yellow">
          <p class="stat-label">Pending Reviews</p>
          <p class="stat-value yellow">${pendingReviews != null ? pendingReviews : 0}</p>
        </div>
        <div class="stat-card green">
          <p class="stat-label">Accepted TAs</p>
          <p class="stat-value green">${acceptedTAs != null ? acceptedTAs : 0}</p>
        </div>

        <div class="sidebar-section">
          <p class="sidebar-section-title">QUICK ACTIONS</p>
          <div style="display:flex;flex-direction:column;gap:8px;">
            <a href="${pageContext.request.contextPath}/mo/post-job"
               class="btn btn-primary btn-full" style="justify-content:flex-start;">Post New Job</a>
          </div>
        </div>
      </div>
    </div>
  </main>
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
