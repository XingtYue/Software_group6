<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, java.util.Map, java.util.ArrayList" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Course Applicants - MO Portal</title>
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
    .lock-notice {
      display: flex; align-items: center; gap: 5px;
      color: #9ca3af; font-size: 12px; font-style: italic;
      white-space: nowrap;
    }
    .section-header {
      display: flex; align-items: center; gap: 10px;
      margin: 28px 0 14px; padding-bottom: 8px;
      border-bottom: 2px solid #e5e7eb;
    }
    .section-header:first-of-type { margin-top: 0; }
    .section-title { font-size: 15px; font-weight: 600; color: #374151; }
    .section-count {
      background: #f3f4f6; color: #6b7280;
      border-radius: 12px; padding: 1px 10px; font-size: 12px;
    }
    .decided-filter { display: flex; gap: 8px; margin-bottom: 14px; }
    .filter-btn {
      padding: 6px 18px; border-radius: 6px; border: 1px solid #d1d5db;
      background: #fff; cursor: pointer; font-size: 13px; color: #6b7280;
      transition: all 0.15s;
    }
    .filter-btn:hover { background: #f9fafb; }
    .filter-btn.active-green { background: #16a34a; color: #fff; border-color: #16a34a; }
    .filter-btn.active-red   { background: #dc2626; color: #fff; border-color: #dc2626; }
    .decided-section { display: none; }
    .decided-section.active { display: block; }
    .no-applicants { color: #9ca3af; font-size: 14px; font-style: italic; padding: 8px 0; }
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
  <%@ include file="moheader.jsp" %>

  <div class="nav-main-row">
    <a href="${pageContext.request.contextPath}/mo/applicants" class="nav-link active">Review Applicants</a>
    <a href="${pageContext.request.contextPath}/mo/post-job" class="nav-link">Post New Job</a>
  </div>

  <main class="main-content">
    <div class="content-with-sidebar">
      <div class="content-area">
        <div class="content-header">
          <div style="max-width:800px;margin:0 auto;">
            <a href="${pageContext.request.contextPath}/mo/applicants"
               class="btn btn-outline btn-sm mb-4" style="display:inline-block;">&larr; Back to Courses</a>
            <h2 class="text-2xl mb-1">${courseTitle != null ? courseTitle : 'Course Title'}</h2>
            <p class="text-gray-600">Code: ${courseCode != null ? courseCode : ''}</p>

            <%
              java.util.Map<String,String> job = (java.util.Map<String,String>) request.getAttribute("job");
              if (job != null) {
            %>
            <div style="margin-top:20px;padding:16px;background:#f9fafb;border:1px solid #e5e7eb;border-radius:8px;">
              <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:12px;">
                <h3 style="font-size:15px;font-weight:600;color:#374151;margin:0;">Job Details</h3>
                <button id="toggleJobDetails" onclick="toggleJobDetails()"
                        style="background:none;border:1px solid #d1d5db;border-radius:6px;padding:4px 12px;cursor:pointer;font-size:13px;color:#6b7280;transition:all 0.2s;">
                  <span id="toggleIcon">▼</span> <span id="toggleText">Collapse</span>
                </button>
              </div>
              <div id="jobDetailsContent" style="display:block;">
                <div style="display:grid;grid-template-columns:120px 1fr;gap:8px;font-size:14px;">
                  <span style="color:#6b7280;font-weight:500;">Department:</span>
                  <span style="color:#111827;"><%= job.get("department") != null && !job.get("department").isEmpty() ? job.get("department") : "N/A" %></span>

                  <span style="color:#6b7280;font-weight:500;">Hours:</span>
                  <span style="color:#111827;"><%= job.get("hours") != null && !job.get("hours").isEmpty() ? job.get("hours") : "N/A" %></span>

                  <span style="color:#6b7280;font-weight:500;">Duration:</span>
                  <span style="color:#111827;"><%= job.get("duration") != null && !job.get("duration").isEmpty() ? job.get("duration") : "N/A" %></span>

                  <span style="color:#6b7280;font-weight:500;">Posted By:</span>
                  <span style="color:#111827;"><%= job.get("postedBy") != null && !job.get("postedBy").isEmpty() ? job.get("postedBy") : "N/A" %></span>

                  <span style="color:#6b7280;font-weight:500;">Posted Date:</span>
                  <span style="color:#111827;"><%= job.get("postedDate") != null && !job.get("postedDate").isEmpty() ? job.get("postedDate") : "N/A" %></span>

                  <span style="color:#6b7280;font-weight:500;">Status:</span>
                  <span style="color:#111827;"><%= job.get("status") != null && !job.get("status").isEmpty() ? job.get("status") : "active" %></span>
                </div>

                <% if (job.get("description") != null && !job.get("description").isEmpty()) { %>
                <div style="margin-top:12px;">
                  <span style="color:#6b7280;font-weight:500;font-size:14px;">Description:</span>
                  <p style="margin-top:4px;color:#374151;font-size:14px;line-height:1.6;white-space:pre-wrap;"><%= job.get("description") %></p>
                </div>
                <% } %>
              </div>
            </div>
            <% } %>
          </div>
        </div>

        <div class="content-body">
          <div style="max-width:800px;margin:0 auto;">
            <%
              List<Map<String,String>> pendingApplicants  = (List<Map<String,String>>) request.getAttribute("pendingApplicants");
              List<Map<String,String>> acceptedApplicants = (List<Map<String,String>>) request.getAttribute("acceptedApplicants");
              List<Map<String,String>> rejectedApplicants = (List<Map<String,String>>) request.getAttribute("rejectedApplicants");
              String courseId = (String) request.getAttribute("courseId");
              if (courseId == null) courseId = "1";
              if (pendingApplicants  == null) pendingApplicants  = new ArrayList<Map<String,String>>();
              if (acceptedApplicants == null) acceptedApplicants = new ArrayList<Map<String,String>>();
              if (rejectedApplicants == null) rejectedApplicants = new ArrayList<Map<String,String>>();
              Boolean isOwner = (Boolean) request.getAttribute("isOwner");
              if (isOwner == null) isOwner = false;
            %>

            <!-- ===== PENDING SECTION ===== -->
            <div class="section-header">
              <span class="section-title">Pending Review</span>
              <span class="section-count"><%= pendingApplicants.size() %></span>
            </div>

            <% if (pendingApplicants.isEmpty()) { %>
              <p class="no-applicants">No pending applicants.</p>
            <% } %>

            <% for (Map<String,String> app : pendingApplicants) { %>
            <div class="applicant-card">
              <div class="applicant-card-inner">
                <div style="flex:1;">
                  <div style="display:flex;align-items:center;gap:12px;margin-bottom:8px;">
                    <h3 class="text-lg"><%= app.get("name") %></h3>
                    <span class="badge badge-pending">Pending</span>
                  </div>
                  <p class="text-sm text-gray-600 mb-1">Email: <%= app.get("email") %></p>
                  <p class="text-sm text-gray-600">Applied: <%= app.get("appliedDate") %></p>
                </div>
                <div class="applicant-actions">
                  <button type="button" class="btn btn-outline btn-sm"
                          onclick="showDetails('<%= app.get("id") %>')">View Details</button>
                  <% if (isOwner) { %>
                  <form action="${pageContext.request.contextPath}/mo/select/action"
                        method="post" style="display:inline;">
                    <input type="hidden" name="appId"  value="<%= app.get("id") %>">
                    <input type="hidden" name="jobId"  value="<%= courseId %>">
                    <input type="hidden" name="action" value="accept">
                    <button type="submit" class="btn btn-green btn-sm">Accept</button>
                  </form>
                  <form action="${pageContext.request.contextPath}/mo/select/action"
                        method="post" style="display:inline;">
                    <input type="hidden" name="appId"  value="<%= app.get("id") %>">
                    <input type="hidden" name="jobId"  value="<%= courseId %>">
                    <input type="hidden" name="action" value="reject">
                    <button type="submit" class="btn btn-outline-red btn-sm">Reject</button>
                  </form>
                  <% } else { %>
                  <span class="lock-notice">
                    <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                      <rect x="3" y="11" width="18" height="11" rx="2"/>
                      <path d="M7 11V7a5 5 0 0 1 10 0v4"/>
                    </svg>
                    View only
                  </span>
                  <% } %>
                </div>
              </div>
            </div>
            <% } %>

            <!-- ===== DECIDED SECTION (Accepted + Rejected) ===== -->
            <% if (!acceptedApplicants.isEmpty() || !rejectedApplicants.isEmpty()) { %>
            <div class="section-header" style="margin-top:36px;">
              <span class="section-title">Decided Applicants</span>
              <span class="section-count"><%= acceptedApplicants.size() + rejectedApplicants.size() %></span>
            </div>

            <div class="decided-filter">
              <% if (!acceptedApplicants.isEmpty()) { %>
              <button class="filter-btn active-green" data-type="accepted" onclick="showDecided('accepted')">
                Accepted (<%= acceptedApplicants.size() %>)
              </button>
              <% } %>
              <% if (!rejectedApplicants.isEmpty()) { %>
              <button class="filter-btn<%= acceptedApplicants.isEmpty() ? " active-red" : "" %>"
                      data-type="rejected" onclick="showDecided('rejected')">
                Rejected (<%= rejectedApplicants.size() %>)
              </button>
              <% } %>
            </div>

            <!-- Accepted sub-section (shown by default) -->
            <div id="section-accepted" class="decided-section<%= !acceptedApplicants.isEmpty() ? " active" : "" %>">
              <% for (Map<String,String> app : acceptedApplicants) { %>
              <div class="applicant-card">
                <div class="applicant-card-inner">
                  <div style="flex:1;">
                    <div style="display:flex;align-items:center;gap:12px;margin-bottom:8px;">
                      <h3 class="text-lg"><%= app.get("name") %></h3>
                      <span class="badge badge-accepted">Accepted</span>
                    </div>
                    <p class="text-sm text-gray-600 mb-1">Email: <%= app.get("email") %></p>
                    <p class="text-sm text-gray-600">Applied: <%= app.get("appliedDate") %></p>
                  </div>
                  <div class="applicant-actions">
                    <button type="button" class="btn btn-outline btn-sm"
                            onclick="showDetails('<%= app.get("id") %>')">View Details</button>
                    <span class="lock-notice">
                      <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <rect x="3" y="11" width="18" height="11" rx="2"/>
                        <path d="M7 11V7a5 5 0 0 1 10 0v4"/>
                      </svg>
                      Contact admin to modify
                    </span>
                  </div>
                </div>
              </div>
              <% } %>
            </div>

            <!-- Rejected sub-section -->
            <div id="section-rejected" class="decided-section<%= acceptedApplicants.isEmpty() ? " active" : "" %>">
              <% for (Map<String,String> app : rejectedApplicants) { %>
              <div class="applicant-card">
                <div class="applicant-card-inner">
                  <div style="flex:1;">
                    <div style="display:flex;align-items:center;gap:12px;margin-bottom:8px;">
                      <h3 class="text-lg"><%= app.get("name") %></h3>
                      <span class="badge badge-rejected">Rejected</span>
                    </div>
                    <p class="text-sm text-gray-600 mb-1">Email: <%= app.get("email") %></p>
                    <p class="text-sm text-gray-600">Applied: <%= app.get("appliedDate") %></p>
                  </div>
                  <div class="applicant-actions">
                    <button type="button" class="btn btn-outline btn-sm"
                            onclick="showDetails('<%= app.get("id") %>')">View Details</button>
                    <span class="lock-notice">
                      <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <rect x="3" y="11" width="18" height="11" rx="2"/>
                        <path d="M7 11V7a5 5 0 0 1 10 0v4"/>
                      </svg>
                      Contact admin to modify
                    </span>
                  </div>
                </div>
              </div>
              <% } %>
            </div>
            <% } /* end decided section */ %>

          </div><!-- /max-width -->
        </div><!-- /content-body -->
      </div><!-- /content-area -->

      <!-- Sidebar -->
      <div class="sidebar">
        <p class="sidebar-title">COURSE STATS</p>
        <div class="stat-card">
          <p class="stat-label">Total Applicants</p>
          <p class="stat-value">${totalApplicants != null ? totalApplicants : 0}</p>
        </div>
        <div class="stat-card yellow">
          <p class="stat-label">Pending</p>
          <p class="stat-value yellow">${pendingCount != null ? pendingCount : 0}</p>
        </div>
        <div class="stat-card green">
          <p class="stat-label">Accepted</p>
          <p class="stat-value green">${acceptedCount != null ? acceptedCount : 0}</p>
        </div>
        <div class="stat-card red">
          <p class="stat-label">Rejected</p>
          <p class="stat-value red">${rejectedCount != null ? rejectedCount : 0}</p>
        </div>
      </div>
    </div>
  </main>
</div>

<!-- ===== VIEW DETAILS MODAL ===== -->
<div id="modal-overlay" class="modal-overlay" onclick="if(event.target===this)closeModal()">
  <div class="modal-box">
    <button class="modal-close" onclick="closeModal()">&times;</button>
    <h3 class="modal-title" id="modal-name"></h3>

    <div class="info-grid">
      <span class="info-label">Email</span>      <span class="info-value" id="modal-email"></span>
      <span class="info-label">Phone</span>      <span class="info-value" id="modal-phone"></span>
      <span class="info-label">Department</span> <span class="info-value" id="modal-dept"></span>
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

<!-- Application data for JavaScript -->
<script>
var ctxPath = "${pageContext.request.contextPath}";
var appDetails = {
<%
  List<Map<String,String>> allApps = new ArrayList<Map<String,String>>();
  allApps.addAll(pendingApplicants);
  allApps.addAll(acceptedApplicants);
  allApps.addAll(rejectedApplicants);
  for (int i = 0; i < allApps.size(); i++) {
    Map<String,String> a = allApps.get(i);
    String appId = a.get("id");
    if (appId == null) appId = "";
%>
  "<%= appId %>": {
    name:       "<%= jsEsc(a.get("name")) %>",
    email:      "<%= jsEsc(a.get("email")) %>",
    phone:      "<%= jsEsc(a.get("taPhone") != null ? a.get("taPhone") : "") %>",
    dept:       "<%= jsEsc(a.get("taDepartment") != null ? a.get("taDepartment") : "") %>",
    cover:      "<%= jsEsc(a.get("coverLetter") != null ? a.get("coverLetter") : "") %>",
    cvFileName: "<%= jsEsc(a.get("cvFileName") != null ? a.get("cvFileName") : "") %>"
  }<%= i < allApps.size() - 1 ? "," : "" %>
<% } %>
};
</script>

<script>
function showDetails(appId) {
  var d = appDetails[appId];
  if (!d) return;
  document.getElementById('modal-name').textContent  = d.name  || '(No name)';
  document.getElementById('modal-email').textContent = d.email || 'N/A';
  document.getElementById('modal-phone').textContent = d.phone || 'N/A';
  document.getElementById('modal-dept').textContent  = d.dept  || 'N/A';

  var coverEl = document.getElementById('modal-cover');
  var coverWrap = document.getElementById('modal-cover-wrap');
  if (d.cover) {
    coverEl.textContent = d.cover;
    coverWrap.style.display = '';
  } else {
    coverWrap.innerHTML = '<p class="cover-letter-empty">No cover letter provided.</p>';
  }

  if (d.cvFileName) {
    document.getElementById('modal-cv-section').style.display    = '';
    document.getElementById('modal-no-cv-section').style.display = 'none';
    document.getElementById('modal-cv-link').href = ctxPath + '/mo/cv/download?appId=' + appId;
  } else {
    document.getElementById('modal-cv-section').style.display    = 'none';
    document.getElementById('modal-no-cv-section').style.display = '';
  }

  document.getElementById('modal-overlay').classList.add('active');
}

function closeModal() {
  document.getElementById('modal-overlay').classList.remove('active');
}

function showDecided(type) {
  document.querySelectorAll('.decided-section').forEach(function(el) {
    el.classList.remove('active');
  });
  document.querySelectorAll('.filter-btn').forEach(function(el) {
    el.classList.remove('active-green', 'active-red');
  });
  var section = document.getElementById('section-' + type);
  if (section) section.classList.add('active');
  var btn = document.querySelector('.filter-btn[data-type="' + type + '"]');
  if (btn) btn.classList.add(type === 'accepted' ? 'active-green' : 'active-red');
}

function toggleJobDetails() {
  var content = document.getElementById('jobDetailsContent');
  var icon = document.getElementById('toggleIcon');
  var text = document.getElementById('toggleText');

  if (content.style.display === 'none') {
    content.style.display = 'block';
    icon.textContent = '▼';
    text.textContent = 'Collapse';
  } else {
    content.style.display = 'none';
    icon.textContent = '▶';
    text.textContent = 'Expand';
  }
}
</script>
</body>
</html>