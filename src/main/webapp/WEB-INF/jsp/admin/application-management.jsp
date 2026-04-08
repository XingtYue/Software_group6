<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, java.util.Map" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Application Management - Admin Portal</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
<div class="page-wrapper">
<%@ include file="adminheader.jsp" %>
<div class="nav-main-row">
  <a href="${pageContext.request.contextPath}/admin" class="nav-link">User Management</a>
  <a href="${pageContext.request.contextPath}/admin/jobs" class="nav-link">Job Management</a>
  <a href="${pageContext.request.contextPath}/admin/applications" class="nav-link active">Application Management</a>
  <a href="${pageContext.request.contextPath}/admin/workload" class="nav-link">Workload Management</a>
</div>
  <main class="main-content">
    <div class="content-with-sidebar">
      <div class="content-area">
        <div class="content-header">
          <div style="max-width:900px;margin:0 auto;">
            <h2 class="text-2xl mb-2">Application Management</h2>
            <p class="text-gray-600 mb-4">View and manage all TA applications</p>
            <input class="search-input" type="search" id="appSearch"
                   placeholder="Search by TA name, job title, or email..."
                   oninput="filterApps(this.value)">
            <div class="filter-group">
              <button class="btn btn-primary btn-sm" onclick="setFilter('all',this)">All Applications</button>
              <button class="btn btn-outline btn-sm" onclick="setFilter('pending',this)">Pending</button>
              <button class="btn btn-outline btn-sm" onclick="setFilter('accepted',this)">Accepted</button>
              <button class="btn btn-outline btn-sm" onclick="setFilter('rejected',this)">Rejected</button>
            </div>
          </div>
        </div>

        <div class="content-body">
          <div style="max-width:900px;margin:0 auto;">
            <%
              List<Map<String,String>> applications = (List<Map<String,String>>) request.getAttribute("applications");
              if (applications != null && !applications.isEmpty()) {
                for (Map<String,String> app : applications) {
                  String status = app.getOrDefault("status","pending").toLowerCase();
                  String badgeClass = "badge-pending";
                  if ("accepted".equals(status)) badgeClass = "badge-accepted";
                  else if ("rejected".equals(status)) badgeClass = "badge-rejected";
                  String statusLabel = status.substring(0,1).toUpperCase() + status.substring(1);
            %>
            <div class="applicant-card app-row" data-status="<%= status %>"
                 data-name="<%= app.getOrDefault("taName","").toLowerCase() %>"
                 data-job="<%= app.getOrDefault("jobTitle","").toLowerCase() %>"
                 data-email="<%= app.getOrDefault("taEmail","").toLowerCase() %>">
              <div class="applicant-card-inner">
                <div style="flex:1;">
                  <div style="display:flex;align-items:center;gap:12px;margin-bottom:8px;">
                    <h3 class="text-lg"><%= app.getOrDefault("taName","Unknown") %></h3>
                    <span class="badge <%= badgeClass %>"><%= statusLabel %></span>
                  </div>
                  <p class="text-gray-600 mb-1"><%= app.getOrDefault("jobTitle","Unknown Job") %></p>
                  <p class="text-sm text-gray-500">
                    Email: <%= app.getOrDefault("taEmail","") %> &bull;
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
            <div class="empty-state">No applications found.</div>
            <% } %>
          </div>
        </div>
      </div>

      <!-- Sidebar -->
      <div class="sidebar">
        <p class="sidebar-title">OVERVIEW</p>
        <div class="stat-card">
          <p class="stat-label">Total Applications</p>
          <p class="stat-value">${totalApplications != null ? totalApplications : 7}</p>
        </div>
        <div class="stat-card yellow">
          <p class="stat-label">Pending</p>
          <p class="stat-value yellow">${pendingCount != null ? pendingCount : 3}</p>
        </div>
        <div class="stat-card green">
          <p class="stat-label">Accepted</p>
          <p class="stat-value green">${acceptedCount != null ? acceptedCount : 3}</p>
        </div>
        <div class="stat-card red">
          <p class="stat-label">Rejected</p>
          <p class="stat-value red">${rejectedCount != null ? rejectedCount : 1}</p>
        </div>
      </div>
    </div>
  </main>
</div>

<script>
var currentFilter = 'all';
function setFilter(status, btn) {
  currentFilter = status;
  document.querySelectorAll('.filter-group .btn').forEach(function(b){ b.className = 'btn btn-outline btn-sm'; });
  btn.className = 'btn btn-primary btn-sm';
  filterApps(document.getElementById('appSearch').value);
}
function filterApps(query) {
  var q = query.toLowerCase();
  document.querySelectorAll('.app-row').forEach(function(row) {
    var matchStatus = currentFilter === 'all' || row.dataset.status === currentFilter;
    var matchQuery = !q || row.dataset.name.includes(q) || row.dataset.job.includes(q) || row.dataset.email.includes(q);
    row.style.display = (matchStatus && matchQuery) ? '' : 'none';
  });
}
</script>
</body>
</html>
