<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, java.util.Map" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Job Detail - TA Portal</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
<div class="page-wrapper">
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

  <main class="main-content" style="overflow-y:auto;">
    <div style="max-width:800px;margin:0 auto;padding:24px;">
      <a href="${pageContext.request.contextPath}/ta/jobs" class="btn btn-outline btn-sm mb-6">
        &larr; Back to Jobs
      </a>

      <%
        Map<String,Object> job = (Map<String,Object>) request.getAttribute("job");
        if (job == null) { job = new java.util.HashMap<String, Object>(); }
        String jobId = (String) request.getAttribute("jobId");
        if (jobId == null) jobId = "1";
        List<String> requirements = (List<String>) job.get("requirements");
      %>

      <div class="card card-p8" style="margin-top:16px;">
        <h2 class="text-2xl mb-4"><%= job.getOrDefault("title","TA Position") %></h2>

        <div class="detail-section">
          <h3>Description</h3>
          <p><%= job.getOrDefault("description","No description available.") %></p>
        </div>

        <div class="detail-section">
          <h3>Requirements</h3>
          <ul class="list-disc list-inside" style="color:#4b5563;">
            <% if (requirements != null) {
                for (String req : requirements) { %>
            <li style="margin-bottom:4px;"><%= req %></li>
            <% } } %>
          </ul>
        </div>

        <div class="detail-grid mb-4">
          <div>
            <h3 style="font-size:15px;font-weight:600;margin-bottom:4px;">Hours</h3>
            <p class="text-gray-600"><%= job.getOrDefault("hours","10 hours per week") %></p>
          </div>
          <div>
            <h3 style="font-size:15px;font-weight:600;margin-bottom:4px;">Duration</h3>
            <p class="text-gray-600"><%= job.getOrDefault("duration","Full academic year") %></p>
          </div>
        </div>

        <div class="detail-section">
          <h3>Department</h3>
          <p><%= job.getOrDefault("department","Computer Science") %></p>
        </div>

        <div class="pt-4" style="border-top:1px solid #e5e7eb;margin-top:8px;">
          <a href="${pageContext.request.contextPath}/ta/jobs/<%= jobId %>/apply"
             class="btn btn-primary">Apply for This Position</a>
        </div>
      </div>
    </div>
  </main>
</div>
</body>
</html>
