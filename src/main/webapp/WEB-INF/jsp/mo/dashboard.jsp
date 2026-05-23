<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, java.util.Map" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>MO Dashboard - TA Recruitment System</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
  <style>
    /* ── Hero banner ─────────────────────────────────────────────────── */
    .dash-hero {
      background: linear-gradient(135deg, #1e3a8a 0%, #2563eb 60%, #3b82f6 100%);
      border-radius: 12px;
      padding: 28px 32px;
      color: #fff;
      margin-bottom: 24px;
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: 20px;
      box-shadow: 0 4px 18px rgba(37, 99, 235, 0.22);
    }
    .dash-hero-greeting {
      font-size: 22px;
      font-weight: 700;
      margin: 0 0 6px 0;
      line-height: 1.2;
    }
    .dash-hero-sub {
      font-size: 14px;
      opacity: 0.85;
      margin: 0;
    }
    .dash-hero-badge {
      background: rgba(255, 255, 255, 0.18);
      border: 1.5px solid rgba(255, 255, 255, 0.35);
      border-radius: 10px;
      padding: 12px 22px;
      text-align: center;
      flex-shrink: 0;
    }
    .dash-hero-badge-label {
      font-size: 10px;
      font-weight: 600;
      text-transform: uppercase;
      letter-spacing: 0.08em;
      opacity: 0.78;
      margin-bottom: 3px;
    }
    .dash-hero-badge-value {
      font-size: 24px;
      font-weight: 700;
      line-height: 1;
    }
    .dash-hero-badge-unit {
      font-size: 11px;
      opacity: 0.72;
      margin-top: 3px;
    }

    /* ── Inline stat cards ───────────────────────────────────────────── */
    .dash-stats-row {
      display: grid;
      grid-template-columns: repeat(4, 1fr);
      gap: 14px;
      margin-bottom: 24px;
    }
    @media (max-width: 860px) {
      .dash-stats-row { grid-template-columns: repeat(2, 1fr); }
    }
    .dash-stat-card {
      background: #fff;
      border: 1px solid #e5e7eb;
      border-radius: 10px;
      padding: 16px 18px;
      display: flex;
      align-items: center;
      gap: 14px;
      transition: box-shadow 0.2s, transform 0.15s;
    }
    .dash-stat-card:hover {
      box-shadow: 0 4px 14px rgba(0, 0, 0, 0.08);
      transform: translateY(-1px);
    }
    .dash-stat-icon {
      width: 44px;
      height: 44px;
      border-radius: 10px;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 22px;
      flex-shrink: 0;
    }
    .dash-stat-icon.blue   { background: #dbeafe; }
    .dash-stat-icon.green  { background: #dcfce7; }
    .dash-stat-icon.yellow { background: #fef9c3; }
    .dash-stat-icon.gray   { background: #f3f4f6; }
    .dash-stat-info { flex: 1; min-width: 0; }
    .dash-stat-num {
      font-size: 26px;
      font-weight: 700;
      color: #111827;
      line-height: 1;
      margin-bottom: 3px;
    }
    .dash-stat-num.blue   { color: #1d4ed8; }
    .dash-stat-num.green  { color: #16a34a; }
    .dash-stat-num.yellow { color: #b45309; }
    .dash-stat-label {
      font-size: 12px;
      color: #6b7280;
      font-weight: 500;
      white-space: nowrap;
      overflow: hidden;
      text-overflow: ellipsis;
    }

    /* ── Section title separator ─────────────────────────────────────── */
    .dash-section-title {
      font-size: 12px;
      font-weight: 700;
      color: #374151;
      text-transform: uppercase;
      letter-spacing: 0.07em;
      margin: 0 0 14px 0;
      padding-bottom: 8px;
      border-bottom: 1px solid #e5e7eb;
    }

    /* ── Quick action cards ──────────────────────────────────────────── */
    .quick-actions-grid {
      display: grid;
      grid-template-columns: repeat(3, 1fr);
      gap: 14px;
      margin-bottom: 28px;
    }
    @media (max-width: 720px) {
      .quick-actions-grid { grid-template-columns: 1fr; }
    }
    .quick-action-card {
      background: #fff;
      border: 1px solid #e5e7eb;
      border-radius: 10px;
      padding: 20px;
      text-decoration: none;
      color: inherit;
      display: flex;
      flex-direction: column;
      gap: 10px;
      transition: box-shadow 0.2s, border-color 0.2s, transform 0.15s;
    }
    .quick-action-card:hover {
      box-shadow: 0 6px 18px rgba(0, 0, 0, 0.09);
      border-color: #93c5fd;
      transform: translateY(-2px);
    }
    .quick-action-card:hover .qa-title { color: #1d4ed8; }
    .qa-icon  { font-size: 28px; line-height: 1; }
    .qa-title {
      font-size: 14px;
      font-weight: 600;
      color: #111827;
      transition: color 0.2s;
    }
    .qa-desc {
      font-size: 12px;
      color: #9ca3af;
      line-height: 1.5;
      flex: 1;
    }
    .qa-arrow {
      font-size: 14px;
      color: #93c5fd;
      font-weight: 700;
      align-self: flex-end;
    }

    /* ── Filter tabs (underline style, same as applicant-list) ──────── */
    .filter-tabs {
      display: flex;
      gap: 12px;
      margin: 0 0 16px 0;
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

    /* ── Tab content sections ────────────────────────────────────────── */
    .job-section { display: none; }
    .job-section.active { display: block; }

    /* ── Job card grid ───────────────────────────────────────────────── */
    .jobs-grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
      gap: 16px;
      margin-top: 4px;
    }

    /* ── Inline alert (sidebar) ──────────────────────────────────────── */
    .inline-alert {
      padding: 10px 12px;
      border-radius: 8px;
      margin-bottom: 10px;
    }
    .inline-alert-title {
      font-size: 12px;
      font-weight: 600;
      margin: 0 0 3px 0;
    }
    .inline-alert-body {
      font-size: 11px;
      margin: 0;
      line-height: 1.5;
    }
    .inline-alert.info    { background:#eff6ff; border:1px solid #bfdbfe; }
    .inline-alert.info    .inline-alert-title { color:#1d4ed8; }
    .inline-alert.info    .inline-alert-body  { color:#1e40af; }
    .inline-alert.warning { background:#fefce8; border:1px solid #fde047; }
    .inline-alert.warning .inline-alert-title { color:#854d0e; }
    .inline-alert.warning .inline-alert-body  { color:#713f12; }
  </style>
</head>
<body>
<div class="page-wrapper">
  <%@ include file="moheader.jsp" %>

  <div class="nav-main-row">
    <a href="${pageContext.request.contextPath}/mo/dashboard"  class="nav-link active">Dashboard</a>
    <a href="${pageContext.request.contextPath}/mo/applicants" class="nav-link">Review Applicants</a>
    <a href="${pageContext.request.contextPath}/mo/post-job"   class="nav-link">Post New Job</a>
  </div>

  <main class="main-content">
    <div class="content-with-sidebar">
      <div class="content-area">

        <!-- ─── Page heading ──────────────────────────────────────────── -->
        <div class="content-header">
          <div style="max-width:860px; margin:0 auto;">
            <h2 class="text-2xl mb-1">Dashboard</h2>
            <p class="text-gray-600">Module Organiser Portal &nbsp;&mdash;&nbsp; manage your TA positions and applicants</p>
          </div>
        </div>

        <div class="content-body">
          <%
            List<Map<String,String>> myJobsList    = (List<Map<String,String>>) request.getAttribute("myJobsList");
            List<Map<String,String>> otherJobsList = (List<Map<String,String>>) request.getAttribute("otherJobsList");
            int myJobsSize    = (myJobsList    != null) ? myJobsList.size()    : 0;
            int otherJobsSize = (otherJobsList != null) ? otherJobsList.size() : 0;
            int totalJobsAll  = myJobsSize + otherJobsSize;

            int totalApplicants = 0;
            int acceptedTA      = 0;
            int pendingTA       = 0;
            try {
              Object tA = request.getAttribute("totalApplicants");
              Object nA = request.getAttribute("acceptedCount");
              Object nP = request.getAttribute("pendingCount");
              if (tA != null) totalApplicants = Integer.parseInt(tA.toString());
              if (nA != null) acceptedTA      = Integer.parseInt(nA.toString());
              if (nP != null) pendingTA       = Integer.parseInt(nP.toString());
            } catch (NumberFormatException ignored) {}

            int denom   = totalApplicants > 0 ? totalApplicants : 1;
            int pctAcc  = (int) Math.round(acceptedTA * 100.0 / denom);
          %>
          <div style="max-width:860px; margin:0 auto;">

            <!-- ─── Hero banner ────────────────────────────────────────── -->
            <div class="dash-hero">
              <div>
                <p class="dash-hero-greeting">Welcome back, ${sessionScope.userName}!</p>
                <p class="dash-hero-sub">Module Organiser Portal &nbsp;·&nbsp; Manage your TA positions and review applicants</p>
              </div>
              <div class="dash-hero-badge">
                <div class="dash-hero-badge-label">My Jobs</div>
                <div class="dash-hero-badge-value"><%= myJobsSize %></div>
                <div class="dash-hero-badge-unit">active post<%= myJobsSize != 1 ? "s" : "" %></div>
              </div>
            </div>

            <!-- All Jobs section -->
            <div id="section-all" class="job-section">
              <%
                boolean hasAny = (myJobsList != null && !myJobsList.isEmpty())
                              || (otherJobsList != null && !otherJobsList.isEmpty());
              %>
              <% if (hasAny) { %>
              <div class="jobs-grid">
                <!-- My jobs (with "You" label) -->
                <% if (myJobsList != null) {
                     for (Map<String,String> job : myJobsList) {
                       String st = job.getOrDefault("status","active"); %>
                <div class="dash-job-card">
                  <div class="dash-job-card-header">
                    <div>
                      <div class="dash-job-title"><%= job.get("title") %></div>
                      <div class="dash-job-code"><%= job.getOrDefault("courseCode","N/A") %> &nbsp;·&nbsp; You</div>
                    </div>
                    <span class="dash-job-status <%= st %>"><%= st %></span>
                  </div>
                  <div class="dash-job-info">
                    <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                      <path d="M3 9l9-7 9 7v11a2 2 0 01-2 2H5a2 2 0 01-2-2z"/>
                    </svg>
                    <%= job.getOrDefault("department","N/A") %>
                  </div>
                  <div>
                    <span class="applicant-pill">
                      <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M17 21v-2a4 4 0 00-4-4H5a4 4 0 00-4 4v2"/><circle cx="9" cy="7" r="4"/>
                      </svg>
                      <%= job.get("applicantCount") %> applicant<%= !"1".equals(job.get("applicantCount")) ? "s" : "" %>
                    </span>
                  </div>
                  <div class="dash-job-actions">
                    <a href="${pageContext.request.contextPath}/mo/courses/<%= job.get("jobId") %>"
                       class="btn btn-primary btn-sm">View Details</a>
                    <a href="${pageContext.request.contextPath}/mo/applicants"
                       class="btn btn-outline btn-sm">Applicants</a>
                  </div>
                </div>
                <% } } %>
              </div>
              <% } else { %>
              <div class="no-jobs-state">No jobs available yet.</div>
              <% } %>
            </div><!-- /section-all -->

          </div><!-- /inner max-width -->
        </div><!-- /content-body -->
      </div><!-- /content-area -->

      <!-- ─── Sidebar ────────────────────────────────────────────────── -->
      <div class="sidebar">
        <p class="sidebar-title">OVERVIEW</p>
        <div class="stat-card blue">
          <p class="stat-label">My Job Posts</p>
          <p class="stat-value blue">${myJobs != null ? myJobs : 0}</p>
        </div>
        <div class="stat-card yellow">
          <p class="stat-label">Pending Review</p>
          <p class="stat-value yellow">${pendingCount != null ? pendingCount : 0}</p>
        </div>
        <div class="stat-card green">
          <p class="stat-label">Accepted TAs</p>
          <p class="stat-value green">${acceptedCount != null ? acceptedCount : 0}</p>
        </div>
        <div class="stat-card">
          <p class="stat-label">Total Applicants</p>
          <p class="stat-value">${totalApplicants != null ? totalApplicants : 0}</p>
        </div>

        <p class="sidebar-title" style="margin-top:20px;">ACCEPTANCE RATE</p>
        <div class="rate-bar-wrap">
          <div class="rate-bar-lbl">Accepted / Total</div>
          <div class="rate-bar-track">
            <div class="rate-bar-fill" style="width:<%= pctAcc %>%;"></div>
          </div>
          <div class="rate-bar-nums">
            <span class="rate-big"><%= pctAcc %>%</span>
            <span><%= acceptedTA %> / <%= totalApplicants %></span>
          </div>
        </div>
        <% if (pendingTA > 0) { %>
        <div class="inline-alert warning">
          <p class="inline-alert-title">⏳ <%= pendingTA %> pending review<%= pendingTA != 1 ? "s" : "" %></p>
          <p class="inline-alert-body">There are applicants waiting for your decision. Review them soon to keep candidates informed.</p>
        </div>
        <% } else { %>
        <div class="inline-alert info">
          <p class="inline-alert-title">All caught up!</p>
          <p class="inline-alert-body">No pending applications need your attention right now.</p>
        </div>
        <% } %>
      </div><!-- /sidebar -->
    </div><!-- /content-with-sidebar -->
  </main>
</div>

<script>
  function showJobSection(type, e) {
    document.querySelectorAll('.job-section').forEach(function(el) { el.classList.remove('active'); });
    document.querySelectorAll('.filter-tab').forEach(function(el)  { el.classList.remove('active'); });
    document.getElementById('section-' + type).classList.add('active');
    e.target.classList.add('active');
  }
</script>
</body>
</html>
