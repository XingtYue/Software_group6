<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, java.util.Map" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>TA Workload Details - ${ta.name}</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
<div class="page-wrapper">
  <%@ include file="adminheader.jsp" %>
  <div class="nav-main-row">
    <a href="${pageContext.request.contextPath}/admin" class="nav-link">User Management</a>
    <a href="${pageContext.request.contextPath}/admin/jobs" class="nav-link">Job Management</a>
    <a href="${pageContext.request.contextPath}/admin/applications" class="nav-link">Application Management</a>
    <a href="${pageContext.request.contextPath}/admin/workload" class="nav-link active">Workload Management</a>
  </div>

  <main class="main-content">
    <div class="content-with-sidebar">
      <div class="content-area">
        <div class="content-header">
          <div style="max-width:900px;margin:0 auto;">
            <h2 class="text-2xl mb-2">Workload Details: ${ta.name}</h2>
            <p class="text-gray-600 mb-4">View all positions & hourly workload for this TA</p>

            <!-- 返回按钮 -->
            <a href="${pageContext.request.contextPath}/admin/workload" class="btn btn-outline btn-sm mb-4">
              ← Back to Workload List
            </a>
          </div>
        </div>

        <div class="content-body">
          <div style="max-width:900px;margin:0 auto;">
            <%
              List<Map<String,String>> taApplications = (List<Map<String,String>>) request.getAttribute("taApplications");
              if (taApplications != null && !taApplications.isEmpty()) {
                for (Map<String,String> app : taApplications) {
                  String status = app.getOrDefault("status","pending").toLowerCase();
                  String badgeClass = "badge-pending";
                  if ("accepted".equals(status)) badgeClass = "badge-accepted";
                  else if ("rejected".equals(status)) badgeClass = "badge-rejected";
                  String statusLabel = status.substring(0,1).toUpperCase() + status.substring(1);

                  // 职位工作量小时数
                  String jobHours = app.getOrDefault("jobHours", "0");
            %>
            <!-- 卡片样式和 Application Management 完全一致 -->
            <div class="applicant-card app-row">
              <div class="applicant-card-inner">
                <div style="flex:1;">
                  <div style="display:flex;align-items:center;gap:12px;margin-bottom:8px;">
                    <h3 class="text-lg"><%= app.getOrDefault("jobTitle","Unknown Job") %></h3>
                    <span class="badge <%= badgeClass %>"><%= statusLabel %></span>
                    <!-- 职位工作量显示 -->
                    <span class="badge" style="background:#6366f1; color:white;">Workload: <%= jobHours %>h/week</span>
                  </div>
                  <p class="text-gray-600 mb-1">TA: ${ta.name}</p>
                  <p class="text-sm text-gray-500">
                    Submitted: <%= app.getOrDefault("submittedAt","") %>
                  </p>
                </div>

             <div class="applicant-actions">
               <% if ("pending".equals(status)) { %>
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
               <% } else if ("accepted".equals(status)) { %>
                 <form action="${pageContext.request.contextPath}/admin/applications/action" method="post" style="display:inline;">
                   <input type="hidden" name="appId" value="<%= app.get("id") %>">
                   <input type="hidden" name="action" value="reject">
                   <button type="submit" class="btn btn-outline-red btn-sm">Reject</button>
                 </form>
               <% } else { %>
                 <form action="${pageContext.request.contextPath}/admin/applications/action" method="post" style="display:inline;">
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
            <div class="empty-state">This TA has no job applications.</div>
            <% } %>
          </div>
        </div>
      </div>

      <!-- 右侧信息栏 -->
      <div class="sidebar">
        <p class="sidebar-title">TA SUMMARY</p>
        <div class="stat-card">
          <p class="stat-label">TA Name</p>
          <p class="stat-value">${ta.name}</p>
        </div>
        <div class="stat-card">
          <p class="stat-label">Total Applications</p>
          <p class="stat-value">${taApplications != null ? taApplications.size() : 0}</p>
        </div>
        <div class="stat-card green">
          <p class="stat-label">Current Total Hours</p>
          <p class="stat-value green">${ta.workload}h / week</p>
        </div>
      </div>
    </div>
  </main>
</div>
</body>
</html>