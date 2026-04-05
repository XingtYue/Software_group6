<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, java.util.Map" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Job Detail - Admin Portal</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
<div class="page-wrapper">
  <header class="site-header">
    <div class="header-inner">
      <div class="header-left">
        <span class="site-title">Admin Portal</span>
        <nav>
          <a href="${pageContext.request.contextPath}/admin" class="nav-link">User Management</a>
          <a href="${pageContext.request.contextPath}/admin/jobs" class="nav-link active">Job Management</a>
          <a href="${pageContext.request.contextPath}/admin/applications" class="nav-link">Application Management</a>
          <a href="${pageContext.request.contextPath}/admin/workload" class="nav-link">Workload Management</a>
        </nav>
      </div>
      <div class="header-right">
        <a href="${pageContext.request.contextPath}/logout" class="btn btn-outline btn-sm">Logout</a>
      </div>
    </div>
  </header>

  <main class="main-content" style="overflow-y:auto;">
    <div style="max-width:900px;margin:0 auto;padding:24px;">
      <a href="${pageContext.request.contextPath}/admin/jobs"
         class="btn btn-outline btn-sm mb-6">&larr; Back to Job Management</a>

      <%
        Map<String,Object> job = (Map<String,Object>) request.getAttribute("job");
        if (job == null) job = new java.util.HashMap<String, Object>();
        String jobId = (String) request.getAttribute("jobId");
        if (jobId == null) jobId = "1";
        List<Map<String,String>> applicants = (List<Map<String,String>>) request.getAttribute("applicants");
      %>

      <div class="card card-p8" style="margin-top:16px;margin-bottom:24px;">
        <div style="display:flex;justify-content:space-between;align-items:flex-start;margin-bottom:16px;">
          <div>
            <h2 class="text-2xl mb-2"><%= job.getOrDefault("title","Job Title") %></h2>
            <p class="text-gray-600">Posted by: <%= job.getOrDefault("postedBy","Unknown") %></p>
          </div>
          <% String status = (String) job.getOrDefault("status","active"); %>
          <span class="badge <%= "active".equals(status) ? "badge-active" : "badge-closed" %>">
            <%= status.substring(0,1).toUpperCase() + status.substring(1) %>
          </span>
        </div>

        <div class="detail-section">
          <h3>Description</h3>
          <p><%= job.getOrDefault("description","No description.") %></p>
        </div>

        <div class="detail-grid mb-4">
          <div>
            <h3 style="font-size:14px;font-weight:600;margin-bottom:4px;">Department</h3>
            <p class="text-gray-600"><%= job.getOrDefault("department","N/A") %></p>
          </div>
          <div>
            <h3 style="font-size:14px;font-weight:600;margin-bottom:4px;">Hours</h3>
            <p class="text-gray-600"><%= job.getOrDefault("hours","N/A") %></p>
          </div>
        </div>

        <% if ("active".equals(status)) { %>
          <form action="${pageContext.request.contextPath}/admin/jobs/action" method="post" style="display:inline;">
            <input type="hidden" name="jobId" value="<%= jobId %>">
            <input type="hidden" name="action" value="close">
            <button type="submit" class="btn btn-outline-red btn-sm"
                    onclick="return confirm('Close this job posting?')">Close Job</button>
          </form>
        <% } %>
      </div>

      <h3 class="text-lg mb-4">Applicants (<%= applicants != null ? applicants.size() : 0 %>)</h3>

      <% if (applicants != null && !applicants.isEmpty()) {
           for (Map<String,String> app : applicants) {
             String appStatus = app.getOrDefault("status","pending");
             String badgeClass = "badge-pending";
             if ("accepted".equals(appStatus)) badgeClass = "badge-accepted";
             else if ("rejected".equals(appStatus)) badgeClass = "badge-rejected";
             String statusLabel = appStatus.substring(0,1).toUpperCase() + appStatus.substring(1);
      %>
      <div class="applicant-card">
        <div class="applicant-card-inner">
          <div style="flex:1;">
            <div style="display:flex;align-items:center;gap:12px;margin-bottom:8px;">
              <h4 class="text-lg"><%= app.getOrDefault("name","Unknown") %></h4>
              <span class="badge <%= badgeClass %>"><%= statusLabel %></span>
            </div>
            <p class="text-sm text-gray-600">Email: <%= app.getOrDefault("email","") %></p>
          </div>
          <div class="applicant-actions">
            <% if ("pending".equals(appStatus)) { %>
              <form action="${pageContext.request.contextPath}/admin/applications/action" method="post" style="display:inline;">
                <input type="hidden" name="appId" value="<%= app.get("id") %>">
                <input type="hidden" name="action" value="accept">
                <button type="submit" class="btn btn-green btn-sm">Accept</button>
              </form>
              <form action="${pageContext.request.contextPath}/admin/applications/action" method="post" style="display:inline;">
                <input type="hidden" name="appId" value="<%= app.get("id") %>">
                <input type="hidden" name="action" value="reject">
                <button type="submit" class="btn btn-outline-red btn-sm">Reject</button>
              </form>
            <% } %>
          </div>
        </div>
      </div>
      <% } } else { %>
      <div class="empty-state">No applicants for this job yet.</div>
      <% } %>
    </div>
  </main>
</div>
</body>
</html>
