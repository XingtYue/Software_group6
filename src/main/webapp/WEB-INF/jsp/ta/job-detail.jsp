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
  <%@ include file="taheader.jsp" %>
  <div class="nav-main-row">
    <a href="${pageContext.request.contextPath}/ta/jobs" class="nav-link active">Browse Jobs</a>
    <a href="${pageContext.request.contextPath}/ta/applications" class="nav-link">My Applications</a>
  </div>

  <main class="main-content" style="overflow-y:auto;">
    <div style="max-width:800px;margin:0 auto;padding:24px;">
      <a href="${pageContext.request.contextPath}/ta/jobs" class="btn btn-outline btn-sm mb-6">
        &larr; Back to Jobs
      </a>

      <%
        @SuppressWarnings("unchecked")
        Map<String,String> job = (Map<String,String>) request.getAttribute("job");
        if (job == null) { job = new java.util.HashMap<String,String>(); }
        String jobId = (String) request.getAttribute("jobId");
        if (jobId == null) jobId = "";
        Boolean hasApplied = (Boolean) request.getAttribute("hasApplied");
        if (hasApplied == null) hasApplied = Boolean.FALSE;
        @SuppressWarnings("unchecked")
        List<String> requirements = (List<String>) request.getAttribute("requirements");
      %>

      <div class="card card-p8" style="margin-top:16px;">
        <h2 class="text-2xl mb-4"><%= job.getOrDefault("title","TA Position") %></h2>

        <div class="detail-section">
          <h3>Description</h3>
          <p><%= job.getOrDefault("description","No description available.") %></p>
        </div>

        <% if (requirements != null && !requirements.isEmpty()) { %>
        <div class="detail-section">
          <h3>Requirements</h3>
          <ul class="list-disc list-inside" style="color:#4b5563;">
            <% for (String r : requirements) { %>
            <li style="margin-bottom:4px;"><%= r %></li>
            <% } %>
          </ul>
        </div>
        <% } %>

        <div class="detail-grid mb-4">
          <div>
            <h3 style="font-size:15px;font-weight:600;margin-bottom:4px;">Hours</h3>
            <p class="text-gray-600"><%= job.getOrDefault("hours","—") %></p>
          </div>
          <div>
            <h3 style="font-size:15px;font-weight:600;margin-bottom:4px;">Duration</h3>
            <p class="text-gray-600"><%= job.getOrDefault("duration","—") %></p>
          </div>
        </div>

        <div class="detail-section">
          <h3>Department</h3>
          <p><%= job.getOrDefault("department","—") %></p>
        </div>

        <div class="pt-4" style="border-top:1px solid #e5e7eb;margin-top:8px;">
          <button class="btn btn-primary" onclick="handleApply()">Apply for This Position</button>
        </div>
      </div>
    </div>
  </main>
</div>

<!-- Already-applied modal -->
<div id="alreadyAppliedModal" style="display:none;position:fixed;inset:0;background:rgba(0,0,0,0.4);z-index:1000;align-items:center;justify-content:center;">
  <div style="background:#fff;border-radius:10px;padding:28px 32px;max-width:380px;width:90%;box-shadow:0 8px 30px rgba(0,0,0,0.15);text-align:center;">
    <div style="font-size:36px;margin-bottom:12px;">&#9888;</div>
    <h3 style="font-size:17px;font-weight:600;margin-bottom:8px;">Already Applied</h3>
    <p style="font-size:14px;color:#6b7280;margin-bottom:20px;">You have already submitted an application for this position. You cannot apply again.</p>
    <div style="display:flex;gap:10px;justify-content:center;">
      <a href="${pageContext.request.contextPath}/ta/applications" class="btn btn-primary btn-sm">View My Applications</a>
      <button onclick="document.getElementById('alreadyAppliedModal').style.display='none'" class="btn btn-outline btn-sm">Close</button>
    </div>
  </div>
</div>

<script>
var alreadyApplied = <%= hasApplied %>;
var applyUrl = '${pageContext.request.contextPath}/ta/apply/<%= jobId %>';
function handleApply() {
  if (alreadyApplied) {
    document.getElementById('alreadyAppliedModal').style.display = 'flex';
  } else {
    window.location.href = applyUrl;
  }
}
</script>
</body>
</html>