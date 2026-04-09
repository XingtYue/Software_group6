<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, java.util.Map" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Job Management - Admin Portal</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
<div class="page-wrapper">
  <%@ include file="adminheader.jsp" %>
  <div class="nav-main-row">
    <a href="${pageContext.request.contextPath}/admin" class="nav-link">User Management</a>
    <a href="${pageContext.request.contextPath}/admin/jobs" class="nav-link active">Job Management</a>
    <a href="${pageContext.request.contextPath}/admin/applications" class="nav-link">Application Management</a>
    <a href="${pageContext.request.contextPath}/admin/workload" class="nav-link">Workload Management</a>
  </div>
  <main class="main-content">
    <div class="content-with-sidebar">
      <div class="content-area">
        <div class="content-header">
          <div style="max-width:900px;margin:0 auto;">
            <h2 class="text-2xl mb-2">Job Management</h2>
            <p class="text-gray-600 mb-4">View and manage all job postings</p>
            <input class="search-input" type="search" id="jobSearch"
                   placeholder="Search jobs by title, MO, or department..."
                   oninput="filterJobs(this.value)">
            <div class="filter-group">
              <button class="btn btn-primary btn-sm" onclick="setFilter('all',this)">All Jobs</button>
              <button class="btn btn-outline btn-sm" onclick="setFilter('active',this)">Active</button>
              <button class="btn btn-outline btn-sm" onclick="setFilter('closed',this)">Closed</button>
            </div>
          </div>
        </div>

        <div class="content-body">
          <div style="max-width:900px;margin:0 auto;">
            <%
              List<Map<String,String>> jobs = (List<Map<String,String>>) request.getAttribute("jobs");
              if (jobs != null && !jobs.isEmpty()) {
                for (Map<String,String> job : jobs) {
                  String status = job.getOrDefault("status","active").toLowerCase();
            %>
            <div class="applicant-card job-row" data-status="<%= status %>"
                 data-title="<%= job.get("title").toLowerCase() %>"
                 data-postedby="<%= job.getOrDefault("postedBy","").toLowerCase() %>"
                 data-dept="<%= job.getOrDefault("department","").toLowerCase() %>"
                 style="<%= "closed".equals(status) ? "background:#f3f4f6;" : "" %>">
              <div class="applicant-card-inner">
                <div style="flex:1;">
                  <div style="display:flex;align-items:center;gap:12px;margin-bottom:8px;">
                    <h3 class="text-lg"><%= job.get("title") %></h3>
                    <span class="badge <%= "active".equals(status) ? "badge-active" : "badge-closed" %>">
                      <%= status.substring(0,1).toUpperCase() + status.substring(1) %>
                    </span>
                  </div>
                  <p class="text-gray-600 mb-1">Posted by: <%= job.getOrDefault("postedBy","Unknown") %></p>
                  <p class="text-sm text-gray-500">
                    Department: <%= job.getOrDefault("department","N/A") %> &bull;
                    <%= job.getOrDefault("applicantCount","0") %> applicant(s)
                  </p>
                </div>
                <div class="applicant-actions">
                  <a href="${pageContext.request.contextPath}/admin/jobs/<%= job.get("jobId") %>"
                     class="btn btn-outline btn-sm">View Details</a>
                  <% if ("active".equals(status)) { %>
                    <form action="${pageContext.request.contextPath}/admin/jobs/action" method="post" style="display:inline;">
                      <input type="hidden" name="jobId" value="<%= job.get("jobId") %>">
                      <input type="hidden" name="action" value="close">
                      <button type="submit" class="btn btn-outline-red btn-sm"
                              onclick="return confirm('Close this job posting?')">Close Job</button>
                    </form>
                  <% } %>
                  <% if ("closed".equals(status)) { %>
                  <form action="${pageContext.request.contextPath}/admin/jobs/action" method="post" style="display:inline;">
                    <input type="hidden" name="jobId" value="<%= job.get("jobId") %>">
                    <input type="hidden" name="action" value="activate">
                    <button type="submit" class="btn btn-outline-green btn-sm"
                            onclick="return confirm('Activate this job posting?')">Activate</button>
                  </form>
                  <% } %>
                </div>
              </div>
            </div>
            <%
                }
              } else {
            %>
            <div class="empty-state">No jobs found.</div>
            <% } %>
          </div>
        </div>
      </div>

      <!-- Sidebar -->
      <div class="sidebar">
        <p class="sidebar-title">OVERVIEW</p>
        <div class="stat-card">
          <p class="stat-label">Total Jobs</p>
          <p class="stat-value">${totalJobs != null ? totalJobs : 7}</p>
        </div>
        <div class="stat-card green">
          <p class="stat-label">Active Jobs</p>
          <p class="stat-value green">${activeJobs != null ? activeJobs : 5}</p>
        </div>
        <div class="stat-card">
          <p class="stat-label">Closed Jobs</p>
          <p class="stat-value">${closedJobs != null ? closedJobs : 2}</p>
        </div>
        <div class="stat-card">
          <p class="stat-label">Total Applicants</p>
          <p class="stat-value">${totalApplicants != null ? totalApplicants : 35}</p>
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
  filterJobs(document.getElementById('jobSearch').value);
}
function filterJobs(query) {
  var q = query.toLowerCase();
  document.querySelectorAll('.job-row').forEach(function(row) {
    var matchStatus = currentFilter === 'all' || row.dataset.status === currentFilter;
    var matchQuery = !q || row.dataset.title.includes(q) || row.dataset.postedby.includes(q) || row.dataset.dept.includes(q);
    row.style.display = (matchStatus && matchQuery) ? '' : 'none';
  });
}
</script>
</body>
</html>
