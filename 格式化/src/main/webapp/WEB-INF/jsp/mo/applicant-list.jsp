<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, java.util.Map" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Review Applicants - MO Portal</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
<div class="page-wrapper">
  <header class="site-header">
    <div class="header-inner">
      <div class="header-left">
        <span class="site-title">MO Portal</span>
        <nav>
          <a href="${pageContext.request.contextPath}/mo/applicants" class="nav-link active">Review Applicants</a>
          <a href="${pageContext.request.contextPath}/mo/post-job" class="nav-link">Post New Job</a>
        </nav>
      </div>
      <div class="header-right">
        <a href="${pageContext.request.contextPath}/mo/profile" class="btn-icon" title="Profile">
          <svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
            <circle cx="12" cy="8" r="4"/><path d="M4 20c0-4 3.6-7 8-7s8 3 8 7"/>
          </svg>
        </a>
        <a href="${pageContext.request.contextPath}/logout" class="btn btn-outline btn-sm">Logout</a>
      </div>
    </div>
  </header>

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
              List<Map<String,String>> courses = (List<Map<String,String>>) request.getAttribute("courses");
              if (courses != null && !courses.isEmpty()) {
                for (Map<String,String> course : courses) {
            %>
            <a href="${pageContext.request.contextPath}/mo/course/<%= course.get("id") %>"
               style="text-decoration:none;color:inherit;">
              <div class="course-card">
                <div>
                  <h3 style="font-size:16px;font-weight:500;margin-bottom:4px;"><%= course.get("title") %></h3>
                  <p class="text-sm text-gray-600">Code: <%= course.get("code") %></p>
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
              <p>No courses found. <a href="${pageContext.request.contextPath}/mo/post-job">Post a job</a> to get started.</p>
            </div>
            <% } %>
          </div>
        </div>
      </div>

      <!-- Sidebar -->
      <div class="sidebar">
        <p class="sidebar-title">OVERVIEW</p>
        <div class="stat-card">
          <p class="stat-label">Active Courses</p>
          <p class="stat-value">${activeCourses != null ? activeCourses : 3}</p>
        </div>
        <div class="stat-card yellow">
          <p class="stat-label">Pending Reviews</p>
          <p class="stat-value yellow">${pendingReviews != null ? pendingReviews : 5}</p>
        </div>
        <div class="stat-card green">
          <p class="stat-label">Accepted TAs</p>
          <p class="stat-value green">${acceptedTAs != null ? acceptedTAs : 3}</p>
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
</body>
</html>
