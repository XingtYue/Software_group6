<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, java.util.Map, java.util.ArrayList" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Application Management - Admin Portal</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
  <style>
    .modal-overlay {
      display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%;
      background: rgba(0,0,0,0.5); z-index: 1000;
      align-items: flex-start; justify-content: center;
      padding: 40px 16px; box-sizing: border-box; overflow-y: auto;
    }
    .modal-overlay.active { display: flex; }
    .modal-box {
      background: #fff; border-radius: 8px; padding: 28px;
      max-width: 640px; width: 100%; position: relative;
      max-height: 80vh; overflow-y: auto; box-shadow: 0 20px 60px rgba(0,0,0,0.3);
    }
    .modal-close {
      position: absolute; top: 12px; right: 16px; font-size: 24px;
      cursor: pointer; color: #6b7280; border: none; background: none; line-height: 1;
    }
    .modal-title { font-size: 18px; font-weight: 600; margin-bottom: 16px; color: #111827; }
    .modal-section { margin-top: 16px; padding-top: 16px; border-top: 1px solid #e5e7eb; }
    .modal-section-title { font-size: 13px; font-weight: 600; color: #374151; margin-bottom: 8px; text-transform: uppercase; letter-spacing: 0.05em; }
    .info-grid { display: grid; grid-template-columns: 110px 1fr; gap: 5px 12px; }
    .info-label { font-size: 13px; color: #9ca3af; }
    .info-value { font-size: 13px; color: #111827; word-break: break-word; }
    .cover-letter-box {
      background: #f9fafb; border: 1px solid #e5e7eb; border-radius: 6px;
      padding: 12px; font-size: 13px; color: #374151; white-space: pre-wrap;
      max-height: 220px; overflow-y: auto; line-height: 1.6;
    }
    .cover-letter-empty { font-size: 13px; color: #9ca3af; font-style: italic; }
  </style>
</head>
<%!
  private String jsEsc(String s) {
    if (s == null) return "";
    return s.replace("\\", "\\\\")
            .replace("\"", "\\\"")
            .replace("\n", "\\n")
            .replace("\r", "")
            .replace("<", "\\u003C")
            .replace(">", "\\u003E");
  }
%>
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
                  <button type="button" class="btn btn-outline btn-sm"
                          onclick="showDetails('<%= app.get("id") %>')">View Details</button>
                  <% if ("pending".equals(status)) { %>
                    <form action="${pageContext.request.contextPath}/admin/applications/action" method="post" style="display:inline;">
                      <input type="hidden" name="appId" value="<%= app.get("id") %>">
                      <input type="hidden" name="action" value="accept">
                      <input type="hidden" name="returnTo" value="/admin/applications">
                      <button type="submit" class="btn btn-green btn-sm">Accept</button>
                    </form>
                    <form action="${pageContext.request.contextPath}/admin/applications/action" method="post" style="display:inline;">
                      <input type="hidden" name="appId" value="<%= app.get("id") %>">
                      <input type="hidden" name="action" value="reject">
                      <input type="hidden" name="returnTo" value="/admin/applications">
                      <button type="submit" class="btn btn-outline-red btn-sm">Reject</button>
                    </form>
                  <% } else if ("accepted".equals(status)) { %>
                    <form action="${pageContext.request.contextPath}/admin/applications/action" method="post" style="display:inline;">
                      <input type="hidden" name="appId" value="<%= app.get("id") %>">
                      <input type="hidden" name="action" value="reject">
                      <input type="hidden" name="returnTo" value="/admin/applications">
                      <button type="submit" class="btn btn-outline-red btn-sm">Reject</button>
                    </form>
                  <% } else { %>
                    <form action="${pageContext.request.contextPath}/admin/applications/action" method="post" style="display:inline;">
                      <input type="hidden" name="appId" value="<%= app.get("id") %>">
                      <input type="hidden" name="action" value="restore">
                      <input type="hidden" name="returnTo" value="/admin/applications">
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

<div id="modal-overlay" class="modal-overlay" onclick="if(event.target===this)closeModal()">
  <div class="modal-box">
    <button class="modal-close" onclick="closeModal()">&times;</button>
    <h3 class="modal-title" id="modal-name"></h3>

    <div class="info-grid">
      <span class="info-label">Email</span>      <span class="info-value" id="modal-email"></span>
      <span class="info-label">Phone</span>      <span class="info-value" id="modal-phone"></span>
      <span class="info-label">Department</span> <span class="info-value" id="modal-dept"></span>
      <span class="info-label">Job</span>        <span class="info-value" id="modal-job"></span>
      <span class="info-label">Status</span>     <span class="info-value" id="modal-status"></span>
      <span class="info-label">Submitted</span>  <span class="info-value" id="modal-submitted"></span>
    </div>

    <div class="modal-section">
      <p class="modal-section-title">Cover Letter</p>
      <div id="modal-cover-wrap">
        <div class="cover-letter-box" id="modal-cover"></div>
      </div>
    </div>

    <div class="modal-section" id="modal-cv-section">
      <p class="modal-section-title">CV / Resume</p>
      <a id="modal-cv-link" href="#" target="_blank" class="btn btn-outline btn-sm">
        View / Download CV
      </a>
    </div>
    <div class="modal-section" id="modal-no-cv-section" style="display:none;">
      <p class="modal-section-title">CV / Resume</p>
      <p class="cover-letter-empty">No CV uploaded for this application.</p>
    </div>
  </div>
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

var ctxPath = "${pageContext.request.contextPath}";
var appDetails = {
<%
  if (applications != null) {
    for (int i = 0; i < applications.size(); i++) {
      Map<String,String> a = applications.get(i);
      String appId = a.get("id");
      if (appId == null) appId = "";
%>
  "<%= appId %>": {
    name: "<%= jsEsc(a.getOrDefault("taName", "")) %>",
    email: "<%= jsEsc(a.getOrDefault("taEmail", "")) %>",
    phone: "<%= jsEsc(a.getOrDefault("taPhone", "")) %>",
    dept: "<%= jsEsc(a.getOrDefault("taDepartment", "")) %>",
    jobTitle: "<%= jsEsc(a.getOrDefault("jobTitle", "")) %>",
    status: "<%= jsEsc(a.getOrDefault("status", "")) %>",
    submittedAt: "<%= jsEsc(a.getOrDefault("submittedAt", "")) %>",
    cover: "<%= jsEsc(a.getOrDefault("coverLetter", "")) %>",
    cvFileName: "<%= jsEsc(a.getOrDefault("cvFileName", "")) %>"
  }<%= i < applications.size() - 1 ? "," : "" %>
<%
    }
  }
%>
};

function capitalize(value) {
  if (!value) return 'N/A';
  return value.charAt(0).toUpperCase() + value.slice(1);
}

function showDetails(appId) {
  var d = appDetails[appId];
  if (!d) return;
  document.getElementById('modal-name').textContent = d.name || '(No name)';
  document.getElementById('modal-email').textContent = d.email || 'N/A';
  document.getElementById('modal-phone').textContent = d.phone || 'N/A';
  document.getElementById('modal-dept').textContent = d.dept || 'N/A';
  document.getElementById('modal-job').textContent = d.jobTitle || 'N/A';
  document.getElementById('modal-status').textContent = capitalize(d.status);
  document.getElementById('modal-submitted').textContent = d.submittedAt || 'N/A';

  var coverWrap = document.getElementById('modal-cover-wrap');
  if (d.cover) {
    coverWrap.innerHTML = '<div class="cover-letter-box" id="modal-cover"></div>';
    document.getElementById('modal-cover').textContent = d.cover;
  } else {
    coverWrap.innerHTML = '<p class="cover-letter-empty">No cover letter provided.</p>';
  }

  if (d.cvFileName) {
    document.getElementById('modal-cv-section').style.display = '';
    document.getElementById('modal-no-cv-section').style.display = 'none';
    document.getElementById('modal-cv-link').href = ctxPath + '/admin/cv/download?appId=' + encodeURIComponent(appId);
  } else {
    document.getElementById('modal-cv-section').style.display = 'none';
    document.getElementById('modal-no-cv-section').style.display = '';
  }

  document.getElementById('modal-overlay').classList.add('active');
}

function closeModal() {
  document.getElementById('modal-overlay').classList.remove('active');
}
</script>
</body>
</html>
