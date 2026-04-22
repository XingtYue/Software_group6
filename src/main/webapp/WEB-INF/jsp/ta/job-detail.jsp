<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, java.util.Map" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Job Detail - TA Portal</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        /* 新增：岗位类型标签样式 */
        .position-type-tag {
            display: inline-block;
            background: #eef2ff;
            color: #2F80ED;
            padding: 4px 10px;
            border-radius: 4px;
            font-size: 13px;
            margin-left: 12px;
            vertical-align: middle;
            font-weight: normal;
        }
        /* 新增：错误提示样式 */
        .alert {
            padding: 12px 16px;
            border-radius: 6px;
            margin-bottom: 20px;
            font-size: 14px;
        }
        .alert-error {
            background: #fef2f2;
            color: #DC2626;
            border: 1px solid #fecaca;
        }
    </style>
</head>
<body>
<div class="page-wrapper">
<<<<<<< Updated upstream
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
=======
    <%@ include file="taheader.jsp" %>
    <div class="nav-main-row">
        <a href="${pageContext.request.contextPath}/ta/jobs" class="nav-link active">Browse Jobs</a>
        <a href="${pageContext.request.contextPath}/ta/applications" class="nav-link">My Applications</a>
>>>>>>> Stashed changes
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

            <!-- ========== 新增：错误提示区域 ========== -->
            <% if (request.getAttribute("errorMsg") != null) { %>
            <div class="alert alert-error"><%= request.getAttribute("errorMsg") %></div>
            <% } %>

            <div class="card card-p8" style="margin-top:16px;">
                <%-- ========== 修改：岗位标题旁新增岗位类型标签 ========== --%>
                <h2 class="text-2xl mb-4">
                    <%= job.getOrDefault("title","TA Position") %>
                    <%
                        String positionType = job.get("positionType");
                        if (positionType != null && !positionType.trim().isEmpty()) {
                    %>
                    <span class="position-type-tag"><%= positionType %></span>
                    <% } %>
                </h2>

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
<<<<<<< Updated upstream
=======

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
>>>>>>> Stashed changes
</body>
</html>
