<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, java.util.Map, java.util.LinkedHashMap, java.util.ArrayList" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Review Applicants - MO Portal</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
  <style>
    .filter-tabs {
      display: flex;
      gap: 12px;
      margin-bottom: 16px;
      border-bottom: 2px solid #e5e7eb;
    }
    .filter-tab {
      padding: 10px 20px;
      background: none;
      border: none;
      border-bottom: 3px solid transparent;
      cursor: pointer;
      font-size: 15px;
      font-weight: 500;
      color: #6b7280;
      transition: all 0.2s;
      margin-bottom: -2px;
    }
    .filter-tab:hover { color: #374151; }
    .filter-tab.active { color: #2563eb; border-bottom-color: #2563eb; }
    .job-section { display: none; }
    .job-section.active { display: block; }

    /* Course group block */
    .course-group {
      background: #fff;
      border: 1px solid #e5e7eb;
      border-radius: 10px;
      margin-bottom: 20px;
      overflow: hidden;
    }
    .course-group-header {
      background: #f8fafc;
      border-bottom: 1px solid #e5e7eb;
      padding: 14px 20px;
      display: flex;
      align-items: center;
      justify-content: space-between;
    }
    .course-group-title {
      font-size: 16px;
      font-weight: 600;
      color: #1e40af;
    }
    .course-group-code {
      font-size: 13px;
      color: #6b7280;
      margin-top: 2px;
    }
    .course-group-badge {
      background: #dbeafe;
      color: #1d4ed8;
      font-size: 12px;
      font-weight: 500;
      padding: 3px 10px;
      border-radius: 12px;
    }

    /* Position row inside a course */
    .position-row {
      display: flex;
      align-items: center;
      justify-content: space-between;
      padding: 12px 20px;
      border-bottom: 1px solid #f3f4f6;
      transition: background 0.15s;
    }
    .position-row:last-child { border-bottom: none; }
    .position-row:hover { background: #f9fafb; }
    .position-type-badge {
      display: inline-block;
      background: #eef2ff;
      color: #4338ca;
      font-size: 12px;
      font-weight: 500;
      padding: 3px 10px;
      border-radius: 12px;
      margin-right: 10px;
    }
    .position-title {
      font-size: 14px;
      font-weight: 500;
      color: #111827;
    }
    .position-meta {
      font-size: 12px;
      color: #9ca3af;
      margin-top: 2px;
    }
    .position-actions {
      display: flex;
      align-items: center;
      gap: 10px;
      flex-shrink: 0;
    }
    .applicant-count {
      font-size: 13px;
      color: #6b7280;
      white-space: nowrap;
    }
    .status-dot {
      width: 8px; height: 8px;
      border-radius: 50%;
      display: inline-block;
      margin-right: 4px;
    }
    .status-dot.active { background: #22c55e; }
    .status-dot.closed { background: #ef4444; }
  </style>
</head>
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
          <div style="max-width:860px;margin:0 auto;">
            <h2 class="text-2xl mb-2">Review Applicants</h2>
            <p class="text-gray-600">Courses and positions are grouped for easy management</p>
          </div>
        </div>

        <div class="content-body">
          <div style="max-width:860px;margin:0 auto;">

            <%-- My Modules banner — always visible --%>
            <%
              List<Map<String,String>> moModules = (List<Map<String,String>>) request.getAttribute("moModules");
              if (moModules != null && !moModules.isEmpty()) {
            %>
            <div style="background:#f5f3ff;border:1px solid #ddd6fe;border-radius:8px;padding:14px 18px;margin-bottom:20px;">
              <div style="font-size:13px;font-weight:600;color:#6d28d9;margin-bottom:8px;text-transform:uppercase;letter-spacing:0.05em;">My Assigned Modules</div>
              <div style="display:flex;flex-wrap:wrap;gap:8px;">
                <% for (Map<String,String> mod : moModules) { %>
                <span style="background:#ede9fe;color:#5b21b6;font-size:13px;font-weight:500;padding:4px 12px;border-radius:20px;">
                  <strong><%= mod.get("code") %></strong> &nbsp;<%= mod.get("name") %>
                </span>
                <% } %>
              </div>
            </div>
            <% } else { %>
            <div style="background:#fef3c7;border:1px solid #fcd34d;border-radius:8px;padding:12px 16px;margin-bottom:20px;font-size:13px;color:#92400e;">
              No modules assigned to your account yet. Contact an administrator to add your courses.
            </div>
            <% } %>

            <%
              List<Map<String,String>> myJobs   = (List<Map<String,String>>) request.getAttribute("myJobs");
              List<Map<String,String>> otherJobs = (List<Map<String,String>>) request.getAttribute("otherJobs");
              int myJobsSize    = (myJobs   != null) ? myJobs.size()   : 0;
              int otherJobsSize = (otherJobs != null) ? otherJobs.size() : 0;
              int totalJobs     = myJobsSize + otherJobsSize;
            %>

            <!-- Filter Tabs -->
            <div class="filter-tabs">
              <button class="filter-tab active" onclick="showJobSection('my', event)">
                My Courses (<%= myJobsSize %>)
              </button>
              <button class="filter-tab" onclick="showJobSection('all', event)">
                All Courses (<%= totalJobs %>)
              </button>
            </div>

            <!-- My Jobs Section (grouped by course) -->
            <div id="section-my" class="job-section active">
              <%
                if (myJobs != null && !myJobs.isEmpty()) {
                  // Group by courseCode
                  Map<String, List<Map<String,String>>> byCourse = new LinkedHashMap<String, List<Map<String,String>>>();
                  Map<String, String> courseNameMap = new LinkedHashMap<String, String>();
                  for (Map<String,String> job : myJobs) {
                    String cc = job.get("courseCode");
                    if (cc == null || cc.isEmpty()) cc = "Uncategorized";
                    if (!byCourse.containsKey(cc)) {
                      byCourse.put(cc, new ArrayList<Map<String,String>>());
                      String cn = job.get("courseName");
                      courseNameMap.put(cc, (cn != null && !cn.isEmpty()) ? cn : cc);
                    }
                    byCourse.get(cc).add(job);
                  }
                  for (Map.Entry<String, List<Map<String,String>>> entry : byCourse.entrySet()) {
                    String cc = entry.getKey();
                    String cn = courseNameMap.get(cc);
                    List<Map<String,String>> positions = entry.getValue();
              %>
              <div class="course-group">
                <div class="course-group-header">
                  <div>
                    <div class="course-group-title"><%= cn %></div>
                    <div class="course-group-code">Course Code: <%= cc %></div>
                  </div>
                  <span class="course-group-badge"><%= positions.size() %> position<%= positions.size() > 1 ? "s" : "" %></span>
                </div>
                <% for (Map<String,String> pos : positions) {
                     String pt = pos.get("positionType");
                     if (pt == null || pt.isEmpty()) pt = "General";
                     String st = pos.get("status");
                     if (st == null) st = "active";
                %>
                <div class="position-row">
                  <div>
                    <div style="display:flex;align-items:center;flex-wrap:wrap;gap:4px;">
                      <span class="position-type-badge"><%= pt %></span>
                      <span class="position-title"><%= pos.get("title") %></span>
                    </div>
                    <div class="position-meta">
                      <span class="status-dot <%= st %>"></span><%= st %>
                      &nbsp;·&nbsp;<%= pos.get("hours") %> hrs/wk
                      &nbsp;·&nbsp;<%= pos.get("duration") %>
                      &nbsp;·&nbsp;Posted: <%= pos.get("postedDate") %>
                    </div>
                  </div>
                  <div class="position-actions">
                    <span class="applicant-count"><%= pos.get("applicantCount") %> applicant<%= !"1".equals(pos.get("applicantCount")) ? "s" : "" %></span>
                    <a href="${pageContext.request.contextPath}/mo/courses/<%= pos.get("jobId") %>"
                       class="btn btn-primary btn-sm">Manage</a>
                  </div>
                </div>
                <% } %>
              </div>
              <%
                  }
                } else {
              %>
              <div class="empty-state">
                <p>You haven't posted any jobs yet. <a href="${pageContext.request.contextPath}/mo/post-job">Post a job</a> to get started.</p>
              </div>
              <% } %>
            </div>

            <!-- All Jobs Section (grouped by course) -->
            <div id="section-all" class="job-section">
              <%
                if (totalJobs > 0) {
                  // Merge all jobs, mark ownership
                  List<Map<String,String>> allJobs = new ArrayList<Map<String,String>>();
                  if (myJobs != null)    allJobs.addAll(myJobs);
                  if (otherJobs != null) allJobs.addAll(otherJobs);

                  Map<String, List<Map<String,String>>> byCourse2 = new LinkedHashMap<String, List<Map<String,String>>>();
                  Map<String, String> courseNameMap2 = new LinkedHashMap<String, String>();
                  for (Map<String,String> job : allJobs) {
                    String cc = job.get("courseCode");
                    if (cc == null || cc.isEmpty()) cc = "Uncategorized";
                    if (!byCourse2.containsKey(cc)) {
                      byCourse2.put(cc, new ArrayList<Map<String,String>>());
                      String cn = job.get("courseName");
                      courseNameMap2.put(cc, (cn != null && !cn.isEmpty()) ? cn : cc);
                    }
                    byCourse2.get(cc).add(job);
                  }
                  for (Map.Entry<String, List<Map<String,String>>> entry : byCourse2.entrySet()) {
                    String cc = entry.getKey();
                    String cn = courseNameMap2.get(cc);
                    List<Map<String,String>> positions = entry.getValue();
                    String postedByFirst = positions.get(0).get("postedBy");
              %>
              <div class="course-group">
                <div class="course-group-header">
                  <div>
                    <div class="course-group-title"><%= cn %></div>
                    <div class="course-group-code">Course Code: <%= cc %> &nbsp;·&nbsp; MO: <%= postedByFirst %></div>
                  </div>
                  <span class="course-group-badge"><%= positions.size() %> position<%= positions.size() > 1 ? "s" : "" %></span>
                </div>
                <% for (Map<String,String> pos : positions) {
                     String pt = pos.get("positionType");
                     if (pt == null || pt.isEmpty()) pt = "General";
                     String st = pos.get("status");
                     if (st == null) st = "active";
                %>
                <div class="position-row">
                  <div>
                    <div style="display:flex;align-items:center;flex-wrap:wrap;gap:4px;">
                      <span class="position-type-badge"><%= pt %></span>
                      <span class="position-title"><%= pos.get("title") %></span>
                    </div>
                    <div class="position-meta">
                      <span class="status-dot <%= st %>"></span><%= st %>
                      &nbsp;·&nbsp;<%= pos.get("hours") %> hrs/wk
                      &nbsp;·&nbsp;<%= pos.get("duration") %>
                    </div>
                  </div>
                  <div class="position-actions">
                    <span class="applicant-count"><%= pos.get("applicantCount") %> applicant<%= !"1".equals(pos.get("applicantCount")) ? "s" : "" %></span>
                    <a href="${pageContext.request.contextPath}/mo/courses/<%= pos.get("jobId") %>"
                       class="btn btn-outline btn-sm">View</a>
                  </div>
                </div>
                <% } %>
              </div>
              <%
                  }
                } else {
              %>
              <div class="empty-state">
                <p>No jobs available. <a href="${pageContext.request.contextPath}/mo/post-job">Post a job</a> to get started.</p>
              </div>
              <% } %>
            </div>

          </div>
        </div>
      </div>

      <!-- Sidebar -->
      <div class="sidebar">
        <p class="sidebar-title">OVERVIEW</p>
        <div class="stat-card">
          <p class="stat-label">Active Positions</p>
          <p class="stat-value">${activeCourses != null ? activeCourses : 0}</p>
        </div>
        <div class="stat-card yellow">
          <p class="stat-label">Pending Reviews</p>
          <p class="stat-value yellow">${pendingReviews != null ? pendingReviews : 0}</p>
        </div>
        <div class="stat-card green">
          <p class="stat-label">Accepted TAs</p>
          <p class="stat-value green">${acceptedTAs != null ? acceptedTAs : 0}</p>
        </div>

        <div class="sidebar-section">
          <p class="sidebar-section-title">QUICK ACTIONS</p>
          <div style="display:flex;flex-direction:column;gap:8px;">
            <a href="${pageContext.request.contextPath}/mo/post-job"
               class="btn btn-primary btn-full" style="justify-content:flex-start;">Post New Position</a>
          </div>
        </div>
      </div>
    </div>
  </main>
</div>

<script>
function showJobSection(type, e) {
  document.querySelectorAll('.job-section').forEach(function(el) { el.classList.remove('active'); });
  document.querySelectorAll('.filter-tab').forEach(function(el) { el.classList.remove('active'); });
  document.getElementById('section-' + type).classList.add('active');
  e.target.classList.add('active');
}
</script>
</body>
</html>