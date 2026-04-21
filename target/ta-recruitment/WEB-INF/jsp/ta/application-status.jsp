<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, java.util.Map" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>My Applications - TA Portal</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
<div class="page-wrapper">
  <%@ include file="taheader.jsp" %>

  <div class="nav-main-row">
    <a href="${pageContext.request.contextPath}/ta/jobs" class="nav-link">Browse Jobs</a>
             <a href="${pageContext.request.contextPath}/ta/applications" class="nav-link active">My Applications</a>
  </div>
  <main class="main-content">
    <div class="content-with-sidebar">
      <div class="content-area">
        <div class="content-header">
          <div style="max-width:800px;margin:0 auto;">
            <h2 class="text-2xl mb-2">My Applications</h2>
            <p class="text-gray-600">Track the status of your job applications</p>
          </div>
        </div>

        <div class="content-body">
          <div style="max-width:800px;margin:0 auto;">
            <%
              List<Map<String,String>> applications =
                (List<Map<String,String>>) request.getAttribute("applications");
              if (applications != null && !applications.isEmpty()) {
                for (Map<String,String> app : applications) {
                  String status = app.get("status");
                  String badgeClass = "badge-pending";
                  if ("accepted".equals(status)) badgeClass = "badge-accepted";
                  else if ("rejected".equals(status)) badgeClass = "badge-rejected";
                  String statusLabel = status.substring(0,1).toUpperCase() + status.substring(1);
            %>
            <div class="applicant-card">
              <div class="applicant-card-inner">
                <div style="flex:1;">
                  <h3 class="text-lg mb-2"><%= app.get("jobTitle") %></h3>
                  <p class="text-sm text-gray-600">Applied: <%= app.get("appliedDate") %></p>
                  <% String cl = app.get("coverLetter"); if (cl != null && !cl.trim().isEmpty()) { %>
                  <p class="text-sm text-gray-600" style="margin-top:6px;">Cover letter: <%= cl.length() > 80 ? cl.substring(0,80) + "..." : cl %></p>
                  <% } %>
                </div>
                <div style="margin-left:16px;">
                  <span class="badge <%= badgeClass %>"><%= statusLabel %></span>
                </div>
              </div>
            </div>
            <%
                }
              } else {
            %>
            <div class="card card-p8 empty-state">
              <p class="text-gray-600 mb-4">No applications yet</p>
              <a href="${pageContext.request.contextPath}/ta/jobs"
                 class="btn btn-primary">Browse Available Jobs</a>
            </div>
            <% } %>
          </div>
        </div>
      </div>

      <!-- Sidebar -->
      <div class="sidebar">
        <p class="sidebar-title">APPLICATION SUMMARY</p>
        <div class="stat-card">
          <p class="stat-label">Pending</p>
          <p class="stat-value">${pendingCount}</p>
        </div>
        <div class="stat-card green">
          <p class="stat-label">Accepted</p>
          <p class="stat-value green">${acceptedCount}</p>
        </div>
        <div class="stat-card">
          <p class="stat-label">Rejected</p>
          <p class="stat-value">${rejectedCount}</p>
        </div>
        <div class="stat-card">
          <p class="stat-label">Total Applications</p>
          <p class="stat-value">${totalCount}</p>
        </div>

        <div class="sidebar-section">
          <p class="sidebar-section-title">QUICK ACTIONS</p>
          <div style="display:flex;flex-direction:column;gap:8px;">
            <a href="${pageContext.request.contextPath}/ta/jobs"
               class="btn btn-outline btn-full" style="justify-content:flex-start;">Browse More Jobs</a>
            <a href="${pageContext.request.contextPath}/ta/profile"
               class="btn btn-outline btn-full" style="justify-content:flex-start;">Update CV</a>
          </div>
        </div>
      </div>
    </div>
  </main>
</div>
</body>
</html>
