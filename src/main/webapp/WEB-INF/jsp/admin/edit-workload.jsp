<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.ta.recruitment.model.User" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Edit Workload</title>
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

  <main style="padding:30px; max-width:700px; margin:0 auto;">
    <h2 class="text-2xl mb-4">Edit Workload for ${ta.name}</h2>
    <div class="card" style="padding:24px;">
      <form method="post" action="${pageContext.request.contextPath}/admin/workload/save">
        <input type="hidden" name="taId" value="${ta.id}">

        <div class="form-group">
          <label class="form-label">Total Weekly Hours</label>
          <input type="number"
                          name="hours"
                          class="form-input"
                          value="${ta.workload != 0 ? ta.workload : 0}"
                          min="0" max="40" required>
        </div>
        <div style="margin-top:20px; display:flex; gap:12px;">
          <button type="submit" class="btn btn-primary">Save</button>
          <a href="${pageContext.request.contextPath}/admin/workload" class="btn btn-outline">Cancel</a>
        </div>
      </form>
    </div>
  </main>
</div>
</body>
</html>