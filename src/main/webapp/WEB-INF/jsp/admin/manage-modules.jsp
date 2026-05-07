<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, java.util.Map" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Manage Modules - Admin Portal</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
  <style>
    .module-table { width: 100%; border-collapse: collapse; }
    .module-table th, .module-table td { padding: 10px 14px; text-align: left; border-bottom: 1px solid #f3f4f6; font-size: 14px; }
    .module-table th { background: #f8fafc; font-weight: 600; color: #374151; font-size: 13px; }
    .module-table tr:last-child td { border-bottom: none; }
    .module-table tr:hover td { background: #f9fafb; }
    .code-badge { background: #ede9fe; color: #6d28d9; font-size: 12px; font-weight: 600; padding: 2px 8px; border-radius: 4px; }
  </style>
</head>
<body>
<div class="page-wrapper">
  <%@ include file="adminheader.jsp" %>
  <div class="nav-main-row">
    <a href="${pageContext.request.contextPath}/admin" class="nav-link active">User Management</a>
    <a href="${pageContext.request.contextPath}/admin/jobs" class="nav-link">Job Management</a>
    <a href="${pageContext.request.contextPath}/admin/applications" class="nav-link">Application Management</a>
    <a href="${pageContext.request.contextPath}/admin/workload" class="nav-link">Workload Management</a>
  </div>

  <main class="main-content" style="overflow-y:auto;">
    <div style="max-width:760px;margin:0 auto;padding:24px;">

      <%
        com.ta.recruitment.model.User mo = (com.ta.recruitment.model.User) request.getAttribute("mo");
        List<Map<String,String>> moModules = (List<Map<String,String>>) request.getAttribute("moModules");
        String moId = mo != null ? mo.getId() : "";
        String moName = mo != null ? mo.getName() : "";
      %>

      <div style="display:flex;align-items:center;gap:12px;margin-bottom:20px;">
        <a href="${pageContext.request.contextPath}/admin" class="btn btn-outline btn-sm">&larr; Back</a>
        <h2 class="text-2xl" style="margin:0;">Manage Modules — <%= moName %></h2>
      </div>

      <!-- Current modules -->
      <div class="card" style="padding:0;overflow:hidden;margin-bottom:24px;">
        <div style="padding:16px 20px;border-bottom:1px solid #e5e7eb;display:flex;justify-content:space-between;align-items:center;">
          <span style="font-weight:600;font-size:15px;">Assigned Modules</span>
          <span style="font-size:13px;color:#6b7280;"><%= moModules != null ? moModules.size() : 0 %> module(s)</span>
        </div>
        <% if (moModules == null || moModules.isEmpty()) { %>
        <div style="padding:32px;text-align:center;color:#9ca3af;font-style:italic;">No modules assigned yet.</div>
        <% } else { %>
        <table class="module-table">
          <thead><tr><th>Course Code</th><th>Course Name</th><th style="width:80px;"></th></tr></thead>
          <tbody>
          <% for (Map<String,String> mod : moModules) { %>
          <tr>
            <td><span class="code-badge"><%= mod.get("code") %></span></td>
            <td><%= mod.get("name") %></td>
            <td>
              <form action="${pageContext.request.contextPath}/admin/users/<%= moId %>/modules" method="post" style="display:inline;">
                <input type="hidden" name="action" value="remove">
                <input type="hidden" name="courseCode" value="<%= mod.get("code") %>">
                <button type="submit" class="btn btn-outline-red btn-sm"
                        onclick="return confirm('Remove <%= mod.get("code") %> from <%= moName %>?')">Remove</button>
              </form>
            </td>
          </tr>
          <% } %>
          </tbody>
        </table>
        <% } %>
      </div>

      <!-- Add new module -->
      <div class="card card-p8">
        <h3 style="font-size:15px;font-weight:600;margin-bottom:16px;">Add New Module</h3>
        <form action="${pageContext.request.contextPath}/admin/users/<%= moId %>/modules" method="post">
          <input type="hidden" name="action" value="add">
          <div class="form-grid-2">
            <div class="form-group">
              <label class="form-label" for="courseCode">Course Code <span style="color:#b91c1c;">*</span></label>
              <input class="form-input" id="courseCode" name="courseCode" type="text"
                     placeholder="e.g. EBU6304" required>
            </div>
            <div class="form-group">
              <label class="form-label" for="courseName">Course Name</label>
              <input class="form-input" id="courseName" name="courseName" type="text"
                     placeholder="e.g. Software Engineering EBU6304">
            </div>
          </div>
          <button type="submit" class="btn btn-primary">Add Module</button>
        </form>
      </div>

    </div>
  </main>
</div>
</body>
</html>
