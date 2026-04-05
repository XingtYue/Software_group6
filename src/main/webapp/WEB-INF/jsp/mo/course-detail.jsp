<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, java.util.Map" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Course Applicants - MO Portal</title>
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
            <a href="${pageContext.request.contextPath}/mo/applicants"
               class="btn btn-outline btn-sm mb-4" style="display:inline-block;">&larr; Back to Courses</a>
            <h2 class="text-2xl mb-1">${courseTitle != null ? courseTitle : 'Course Title'}</h2>
            <p class="text-gray-600">Code: ${courseCode != null ? courseCode : 'EBU6001'}</p>
          </div>
        </div>

        <div class="content-body">
          <div style="max-width:800px;margin:0 auto;">
            <%
              List<Map<String,String>> applicants = (List<Map<String,String>>) request.getAttribute("applicants");
              String courseId = (String) request.getAttribute("courseId");
              if (courseId == null) courseId = "1";
              if (applicants != null && !applicants.isEmpty()) {
                for (Map<String,String> app : applicants) {
                  String status = app.get("status");
                  String badgeClass = "badge-pending";
                  if ("accepted".equals(status)) badgeClass = "badge-accepted";
                  else if ("rejected".equals(status)) badgeClass = "badge-rejected";
                  String statusLabel = status.substring(0,1).toUpperCase() + status.substring(1);
            %>
            <div class="applicant-card">
              <div class="applicant-card-inner">
                <div style="flex:1;">
                  <div style="display:flex;align-items:center;gap:12px;margin-bottom:8px;">
                    <h3 class="text-lg"><%= app.get("name") %></h3>
                    <span class="badge <%= badgeClass %>"><%= statusLabel %></span>
                  </div>
                  <p class="text-sm text-gray-600 mb-1">Email: <%= app.get("email") %></p>
                  <p class="text-sm text-gray-600">Applied: <%= app.get("appliedDate") %></p>
                </div>
                <div class="applicant-actions">
                  <% if ("pending".equals(status)) { %>
                    <form action="${pageContext.request.contextPath}/mo/course/<%= courseId %>/action"
                          method="post" style="display:inline;">
                      <input type="hidden" name="appId" value="<%= app.get("id") %>">
                      <input type="hidden" name="action" value="accept">
                      <button type="submit" class="btn btn-green btn-sm">Accept</button>
                    </form>
                    <form action="${pageContext.request.contextPath}/mo/course/<%= courseId %>/action"
                          method="post" style="display:inline;">
                      <input type="hidden" name="appId" value="<%= app.get("id") %>">
                      <input type="hidden" name="action" value="reject">
                      <button type="submit" class="btn btn-outline-red btn-sm">Reject</button>
                    </form>
                  <% } else if ("accepted".equals(status)) { %>
                    <form action="${pageContext.request.contextPath}/mo/course/<%= courseId %>/action"
                          method="post" style="display:inline;">
                      <input type="hidden" name="appId" value="<%= app.get("id") %>">
                      <input type="hidden" name="action" value="reject">
                      <button type="submit" class="btn btn-outline-red btn-sm">Reject</button>
                    </form>
                  <% } else { %>
                    <form action="${pageContext.request.contextPath}/mo/course/<%= courseId %>/action"
                          method="post" style="display:inline;">
                      <input type="hidden" name="appId" value="<%= app.get("id") %>">
                      <input type="hidden" name="action" value="restore">
                      <button type="submit" class="btn btn-outline-blue btn-sm">Restore</button>
                    </form>
                  <% } %>
                </div>
              </div>
            </div>
            <%
                }
              } else {
            %>
            <div class="empty-state">
              <p>No applicants for this course yet.</p>
            </div>
            <% } %>
          </div>
        </div>
      </div>

      <!-- Sidebar -->
      <div class="sidebar">
        <p class="sidebar-title">COURSE STATS</p>
        <div class="stat-card">
          <p class="stat-label">Total Applicants</p>
          <p class="stat-value">${totalApplicants != null ? totalApplicants : 0}</p>
        </div>
        <div class="stat-card yellow">
          <p class="stat-label">Pending</p>
          <p class="stat-value yellow">${pendingCount != null ? pendingCount : 0}</p>
        </div>
        <div class="stat-card green">
          <p class="stat-label">Accepted</p>
          <p class="stat-value green">${acceptedCount != null ? acceptedCount : 0}</p>
        </div>
        <div class="stat-card red">
          <p class="stat-label">Rejected</p>
          <p class="stat-value red">${rejectedCount != null ? rejectedCount : 0}</p>
        </div>
      </div>
    </div>
  </main>
</div>
</body>
</html>
