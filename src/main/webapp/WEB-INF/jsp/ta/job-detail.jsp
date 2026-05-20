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
        /* position-type-tag and alert classes are in style.css */
    </style>
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
                Boolean isFull = (Boolean) request.getAttribute("isFull");
                if (isFull == null) isFull = Boolean.FALSE;
                Integer openings     = (Integer) request.getAttribute("openings");
                Integer applicantCnt = (Integer) request.getAttribute("applicantCount");
                Integer acceptedCnt  = (Integer) request.getAttribute("acceptedCount");
                if (openings     == null) openings     = 1;
                if (applicantCnt == null) applicantCnt = 0;
                if (acceptedCnt  == null) acceptedCnt  = 0;
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

                <!-- 招募信息卡片 -->
                <div style="display:grid;grid-template-columns:repeat(3,1fr);gap:12px;margin-bottom:20px;">
                  <div style="text-align:center;padding:12px 8px;background:#f0fdf4;border:1px solid #86efac;border-radius:8px;">
                    <p style="font-size:22px;font-weight:700;color:#15803d;margin:0;"><%= openings %></p>
                    <p style="font-size:12px;color:#166534;margin:4px 0 0 0;font-weight:500;">Openings</p>
                  </div>
                  <div style="text-align:center;padding:12px 8px;background:#eff6ff;border:1px solid #93c5fd;border-radius:8px;">
                    <p style="font-size:22px;font-weight:700;color:#1d4ed8;margin:0;"><%= acceptedCnt %></p>
                    <p style="font-size:12px;color:#1e40af;margin:4px 0 0 0;font-weight:500;">Accepted</p>
                  </div>
                  <div style="text-align:center;padding:12px 8px;background:#f9fafb;border:1px solid #e5e7eb;border-radius:8px;">
                    <p style="font-size:22px;font-weight:700;color:#374151;margin:0;"><%= applicantCnt %></p>
                    <p style="font-size:12px;color:#6b7280;margin:4px 0 0 0;font-weight:500;">Applicants</p>
                  </div>
                </div>

                <% if (isFull) { %>
                <div style="padding:12px 16px;background:#fef2f2;border:1px solid #fca5a5;border-radius:8px;margin-bottom:16px;">
                  <p style="margin:0;font-size:14px;font-weight:600;color:#b91c1c;">🚫 This position is full</p>
                  <p style="margin:4px 0 0 0;font-size:13px;color:#7f1d1d;">All <%= openings %> openings have been filled. This position is no longer accepting applications.</p>
                </div>
                <% } %>

                <div class="detail-section">
                    <h3>Department</h3>
                    <p><%= job.getOrDefault("department","—") %></p>
                </div>

                <div class="pt-4" style="border-top:1px solid #e5e7eb;margin-top:8px;">
                    <% if (isFull) { %>
                    <button class="btn btn-primary" disabled
                            style="opacity:0.5;cursor:not-allowed;">Position Full — Applications Closed</button>
                    <% } else { %>
                    <button class="btn btn-primary" onclick="handleApply()">Apply for This Position</button>
                    <% } %>
                </div>
            </div>
        </div>
    </main>
</div>

<!-- Already-applied modal -->
<div id="alreadyAppliedModal" class="modal-overlay" style="display:none;">
    <div class="modal-box" style="max-width:380px;text-align:center;">
        <div style="font-size:40px;margin-bottom:14px;line-height:1;">&#9888;</div>
        <h3 class="modal-title" style="text-align:center;">Already Applied</h3>
        <p style="font-size:14px;color:#64748b;margin-bottom:24px;line-height:1.6;">You have already submitted an application for this position. You cannot apply again.</p>
        <div style="display:flex;gap:10px;justify-content:center;">
            <a href="${pageContext.request.contextPath}/ta/applications" class="btn btn-primary btn-sm">View My Applications</a>
            <button onclick="document.getElementById('alreadyAppliedModal').style.display='none'" class="btn btn-outline btn-sm">Close</button>
        </div>
    </div>
</div>

<script>
    var alreadyApplied = <%= hasApplied %>;
    var positionFull   = <%= isFull %>;
    var applyUrl = '${pageContext.request.contextPath}/ta/apply/<%= jobId %>';
    function handleApply() {
        if (positionFull) { return; } // 按钮已 disabled，防御性检查
        if (alreadyApplied) {
            var m = document.getElementById('alreadyAppliedModal');
            m.style.display = 'flex';
            m.classList.add('active');
        } else {
            window.location.href = applyUrl;
        }
    }
</script>
</body>
</html>