<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, java.util.Map" %>
<%@ page import="java.time.LocalDate" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>My Applications - TA Portal</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
  <style>
    .modal-overlay {
      display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%;
      background: rgba(0,0,0,0.5); z-index: 1000;
      align-items: center; justify-content: center; padding: 15px; box-sizing: border-box;
    }
    .modal-overlay.active { display: flex; }
    .modal-box {
      background: #fff; border-radius: 8px; padding: 24px;
      max-width: 560px; width: 100%; position: relative;
      box-shadow: 0 10px 30px rgba(0,0,0,0.25);
      max-height: 90vh; overflow-y: auto;
    }
    .modal-close {
      position: absolute; top: 12px; left: 16px; font-size: 20px;
      cursor: pointer; color: #6b7280; border: none; background: none; line-height: 1;
    }
    .modal-title { font-size: 20px; font-weight: 600; margin: 12px 0 18px 0; color: #111827; }
    .info-grid { display: grid; grid-template-columns: 100px 1fr; gap: 10px 12px; }
    .info-label { font-size: 14px; color: #9ca3af; font-weight: 500; text-transform: uppercase; }
    .info-value { font-size: 14px; color: #111827; word-break: break-word; }
    .modal-section { margin-top: 16px; padding-top: 12px; border-top: 1px solid #e5e7eb; }
    .modal-section-title { font-size: 13px; font-weight: 600; color: #374151; margin-bottom: 8px; text-transform: uppercase; letter-spacing: 0.03em; }
    .cover-letter-box {
      background: #f9fafb; border: 1px solid #e5e7eb; border-radius: 6px;
      padding: 12px; font-size: 14px; color: #374151;
      white-space: pre-wrap; max-height: 120px; line-height: 1.5; overflow-y: auto;
    }
    .cover-letter-empty { font-size: 14px; color: #9ca3af; font-style: italic; }
    .ai-score-badge {
      display: inline-flex; align-items: center; gap: 4px;
      font-size: 12px; font-weight: 600; padding: 3px 10px;
      border-radius: 99px; cursor: default;
    }
    .ai-score-badge.high   { background:#dcfce7; color:#15803d; }
    .ai-score-badge.mid    { background:#fef9c3; color:#a16207; }
    .ai-score-badge.low    { background:#fee2e2; color:#b91c1c; }
    .ai-score-badge.pending { background:#f3f4f6; color:#6b7280; }
    /* Filter tabs */
    .filter-tabs { display:flex; gap:8px; margin-bottom:16px; flex-wrap:wrap; }
    .filter-tab {
      padding:6px 16px; border-radius:99px; font-size:13px; font-weight:500;
      cursor:pointer; border:1px solid #e5e7eb; background:#f9fafb; color:#6b7280;
      transition: all 0.15s;
    }
    .filter-tab.active { background:#1e40af; color:#fff; border-color:#1e40af; }
    .filter-tab:hover:not(.active) { background:#f3f4f6; color:#374151; }
    /* New today badge */
    .badge-new-today {
      display:inline-flex; align-items:center; gap:3px;
      font-size:11px; font-weight:700; padding:2px 8px;
      border-radius:99px; background:#fef3c7; color:#92400e;
      border:1px solid #fbbf24; animation: pulse-badge 2s infinite;
    }
    @keyframes pulse-badge {
      0%,100% { opacity:1; } 50% { opacity:0.6; }
    }
    /* MO contact box */
    .mo-contact-box {
      margin-top:10px; padding:10px 14px;
      background:#f0fdf4; border:1px solid #86efac; border-radius:6px;
      font-size:13px; color:#166534;
    }
    .mo-contact-box a { color:#15803d; font-weight:600; }
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
  <%@ include file="taheader.jsp" %>

  <div class="nav-main-row">
    <a href="${pageContext.request.contextPath}/ta/jobs" class="nav-link">Browse Jobs</a>
    <a href="${pageContext.request.contextPath}/ta/applications" class="nav-link active">My Applications</a>
  </div>
  <main class="main-content">
    <div class="content-with-sidebar">
      <div class="content-area">
        <div class="content-header">
          <div style="max-width:800px;margin:0 auto;">
            <h2 class="text-2xl mb-2">My Applications</h2>
            <p class="text-gray-600">Track the status of your job applications</p>
          </div>
        </div>

        <div class="content-body">
          <div style="max-width:800px;margin:0 auto;">
            <!-- Filter tabs -->
            <div class="filter-tabs">
              <span class="filter-tab active" onclick="filterApps('all', this)">All</span>
              <span class="filter-tab" onclick="filterApps('pending', this)">⏳ Pending</span>
              <span class="filter-tab" onclick="filterApps('accepted', this)">✅ Accepted</span>
              <span class="filter-tab" onclick="filterApps('rejected', this)">❌ Rejected</span>
            </div>

            <%
              String today = LocalDate.now().toString(); // yyyy-MM-dd
              List<Map<String,String>> applications =
                (List<Map<String,String>>) request.getAttribute("applications");
              if (applications != null && !applications.isEmpty()) {
                for (Map<String,String> app : applications) {
                  String status = app.get("status");
                  String jobStatus = app.getOrDefault("jobStatus", "active");
                  boolean jobDeactivated = "deactive".equals(jobStatus);

                  String badgeClass = "badge-pending";
                  if ("accepted".equals(status)) badgeClass = "badge-accepted";
                  else if ("rejected".equals(status)) badgeClass = "badge-rejected";
                  String statusLabel = status.substring(0,1).toUpperCase() + status.substring(1);

                  // AI score badge
                  String aiScore = app.getOrDefault("aiMatchScore", "");
                  String aiBadgeClass = "pending";
                  String aiBadgeLabel = "⏳ AI analyzing...";
                  if (!aiScore.isEmpty()) {
                    try {
                      int s = Integer.parseInt(aiScore);
                      aiBadgeClass = s >= 70 ? "high" : s >= 50 ? "mid" : "low";
                      aiBadgeLabel = "🤖 AI Score: " + s + "/100";
                    } catch (NumberFormatException ignored) {}
                  }

                  boolean isNewToday = today.equals(app.getOrDefault("appliedDate",""))
                                       && "accepted".equals(status);

                  // card style: greyed out if accepted & job deactivated
                  String cardStyle = jobDeactivated && "accepted".equals(status)
                      ? "opacity:0.55;filter:grayscale(40%);background:#f3f4f6;" : "";
            %>
            <div class="applicant-card app-status-card" data-status="<%= status %>" style="<%= cardStyle %>">
              <div class="applicant-card-inner">
                <div style="flex:1;">
                  <div style="display:flex;align-items:center;gap:10px;margin-bottom:6px;flex-wrap:wrap;">
                    <h3 class="text-lg"><%= app.get("jobTitle") %></h3>
                    <span class="badge <%= badgeClass %>"><%= statusLabel %></span>
                    <% if (jobDeactivated) { %>
                    <span style="font-size:11px;font-weight:600;padding:2px 8px;border-radius:99px;background:#e5e7eb;color:#6b7280;border:1px solid #d1d5db;">Job Deactivated</span>
                    <% } %>
                    <% if (isNewToday) { %><span class="badge-new-today">🎉 Accepted Today!</span><% } %>
                    <span class="ai-score-badge <%= aiBadgeClass %>"><%= aiBadgeLabel %></span>
                  </div>
                  <p class="text-sm text-gray-600">Applied: <%= app.get("appliedDate") %></p>
                  <% String cl = app.get("coverLetter"); if (cl != null && !cl.trim().isEmpty()) { %>
                  <p class="text-sm text-gray-600" style="margin-top:4px;">Cover letter: <%= cl.length() > 80 ? cl.substring(0,80) + "..." : cl %></p>
                  <% } %>
                  <% if ("accepted".equals(status) && jobDeactivated) { %>
                  <div style="margin-top:8px;padding:10px 14px;background:#fef2f2;border:1px solid #fca5a5;border-radius:6px;font-size:13px;color:#b91c1c;">
                    This job has been deactivated. Please contact the Module Organiser for further information.
                    <%
                      String moEmail = app.getOrDefault("moEmail","");
                      String moName  = app.getOrDefault("moName","");
                      if (!moEmail.isEmpty()) {
                    %>
                    — <strong><%= moName.isEmpty() ? "MO" : moName %></strong>
                    &lt;<a href="mailto:<%= moEmail %>" style="color:#b91c1c;"><%= moEmail %></a>&gt;
                    <% } %>
                  </div>
                  <% } else if ("accepted".equals(status)) {
                       String moEmail = app.getOrDefault("moEmail","");
                       String moName  = app.getOrDefault("moName","");
                  %>
                  <div class="mo-contact-box">
                    🎓 Congratulations! Please contact your Module Organiser to confirm your start:
                    <% if (!moEmail.isEmpty()) { %>
                    <strong><%= moName.isEmpty() ? "MO" : moName %></strong>
                    — <a href="mailto:<%= moEmail %>"><%= moEmail %></a>
                    <% } else { %>
                    (contact information unavailable)
                    <% } %>
                  </div>
                  <% } %>
                </div>
                <div class="applicant-actions">
                  <button type="button" class="btn btn-outline btn-sm"
                          onclick="showDetails('<%= app.get("id") %>')">View Details</button>
                </div>
              </div>
            </div>
            <%
                }
              } else {
            %>
            <div class="card card-p8 empty-state">
              <p class="text-gray-600 mb-4">No applications yet</p>
              <a href="${pageContext.request.contextPath}/ta/jobs"
                 class="btn btn-primary">Browse Available Jobs</a>
            </div>
            <% } %>
          </div>
        </div>
      </div>

     <!-- Sidebar -->
     <div class="sidebar">
       <p class="sidebar-title">APPLICATION SUMMARY</p>
       <div class="stat-card yellow">
         <p class="stat-label">Pending</p>
         <p class="stat-value yellow">${pendingCount}</p>
       </div>
       <div class="stat-card green">
         <p class="stat-label">Accepted</p>
         <p class="stat-value green">${acceptedCount}</p>
       </div>
       <div class="stat-card red">
         <p class="stat-label">Rejected</p>
         <p class="stat-value red">${rejectedCount}</p>
       </div>
       <div class="stat-card">
         <p class="stat-label">Total Applications</p>
         <p class="stat-value">${totalCount}</p>
       </div>

       <p class="sidebar-title" style="margin-top:20px;">WORKLOAD</p>
       <div class="stat-card ${taWorkload > 80 ? 'red' : taWorkload > 40 ? 'yellow' : 'green'}">
         <p class="stat-label">Total Committed Hours</p>
         <p class="stat-value ${taWorkload > 80 ? 'red' : taWorkload > 40 ? 'yellow' : 'green'}">${taWorkload} h</p>
       </div>
       <p style="font-size:11px; color:#94a3b8; margin:4px 0 0 0; padding:0 4px;">
         Based on accepted positions (hours/week × weeks)
       </p>

       <div class="sidebar-section">
         <p class="sidebar-section-title">QUICK ACTIONS</p>
         <div style="display:flex;flex-direction:column;gap:8px;">
           <a href="${pageContext.request.contextPath}/ta/jobs"
              class="btn btn-outline btn-full" style="justify-content:flex-start;">Browse More Jobs</a>
           <a href="${pageContext.request.contextPath}/ta/profile"
              class="btn btn-outline btn-full" style="justify-content:flex-start;">Update CV</a>
         </div>
       </div>
     </div>
    </div>
  </main>
</div>

<!-- ===== View Details Modal ===== -->
<div id="detail-modal-overlay" class="modal-overlay" onclick="if(event.target===this)closeModal()">
  <div class="modal-box">
    <button class="modal-close" onclick="closeModal()">&times;</button>
    <h3 class="modal-title" id="modal-title"></h3>

    <div class="info-grid">
      <span class="info-label">Department</span>
      <span class="info-value" id="modal-dept"></span>
      <span class="info-label">Hours</span>
      <span class="info-value" id="modal-hours"></span>
      <span class="info-label">Duration</span>
      <span class="info-value" id="modal-duration"></span>
      <span class="info-label">Status</span>
      <span class="info-value" id="modal-status"></span>
    </div>

    <div id="modal-mo-contact" style="display:none;" class="modal-section">
      <div class="mo-contact-box" id="modal-mo-contact-inner"></div>
    </div>

    <div class="modal-section">
      <p class="modal-section-title">Description</p>
      <div id="modal-desc-wrap">
        <div class="cover-letter-box" id="modal-description"></div>
      </div>
    </div>

    <!-- AI analysis section -->
    <div class="modal-section">
      <p class="modal-section-title">AI MATCHING ANALYSIS</p>
      <button id="ai-analyze-btn" type="button" class="btn btn-primary btn-sm"
              style="margin-bottom:12px;">🤖 Get AI Analysis</button>
      <div id="ai-loading" style="display:none; padding:10px; background:#fef3c7;
           border:1px solid #fbbf24; border-radius:6px; color:#92400e; font-size:13px;">
        ⏳ Analyzing with Gemini AI... Please wait (up to 30s).
      </div>
      <div id="ai-result-panel" style="display:none; padding:16px; background:#f0f9ff;
           border:1px solid #0ea5e9; border-radius:8px;">
        <div style="margin-bottom:12px; display:flex; align-items:center; gap:8px;">
          <span style="font-size:14px; font-weight:600; color:#0c4a6e;">MATCH SCORE:</span>
          <span id="ai-score" style="font-size:20px; font-weight:700;"></span>
          <span style="font-size:14px; color:#475569;">/100</span>
          <span id="ai-cached-badge" style="display:none; font-size:11px; background:#e0f2fe;
                color:#0369a1; padding:2px 8px; border-radius:99px; font-weight:600;">Cached</span>
        </div>
        <div style="margin-bottom:10px;">
          <p style="font-size:13px; font-weight:600; color:#0c4a6e; margin:0 0 4px 0;">✅ Matched Skills:</p>
          <p id="ai-matched" style="margin:0; font-size:13px; color:#334155; line-height:1.6;"></p>
        </div>
        <div style="margin-bottom:10px;">
          <p style="font-size:13px; font-weight:600; color:#0c4a6e; margin:0 0 4px 0;">⚠️ Missing Skills:</p>
          <p id="ai-missing" style="margin:0; font-size:13px; color:#334155; line-height:1.6;"></p>
        </div>
        <div style="margin-bottom:10px;">
          <p style="font-size:13px; font-weight:600; color:#0c4a6e; margin:0 0 4px 0;">💡 Reasoning:</p>
          <p id="ai-reasoning" style="margin:0; font-size:13px; color:#334155; line-height:1.6; white-space:pre-wrap;"></p>
        </div>
        <div id="ai-altjob-section" style="display:none; margin-top:10px; padding:10px;
             background:#fefce8; border:1px solid #fde047; border-radius:6px;">
          <p style="font-size:13px; font-weight:600; color:#854d0e; margin:0 0 4px 0;">🔀 Consider Applying To:</p>
          <p id="ai-altjob" style="margin:0; font-size:13px; color:#713f12; font-weight:500;"></p>
        </div>
      </div>
    </div>
  </div>
</div>

<script>
var ctxPath = "${pageContext.request.contextPath}";
var currentAppId = null;
var appDetails = {
<%
  if (applications != null) {
    for (int i = 0; i < applications.size(); i++) {
      Map<String,String> app = applications.get(i);
      String appId = app.getOrDefault("id", "");
%>
  "<%= appId %>": {
    jobTitle:    "<%= jsEsc(app.getOrDefault("jobTitle","")) %>",
    dept:        "<%= jsEsc(app.getOrDefault("jobDepartment","")) %>",
    hours:       "<%= jsEsc(app.getOrDefault("jobHours","")) %>",
    duration:    "<%= jsEsc(app.getOrDefault("jobDuration","")) %>",
    appStatus:   "<%= jsEsc(app.getOrDefault("status","")) %>",
    description: "<%= jsEsc(app.getOrDefault("jobDescription","")) %>",
    moEmail:     "<%= jsEsc(app.getOrDefault("moEmail","")) %>",
    moName:      "<%= jsEsc(app.getOrDefault("moName","")) %>",
    aiScore:     "<%= jsEsc(app.getOrDefault("aiMatchScore","")) %>",
    aiMatched:   "<%= jsEsc(app.getOrDefault("aiMatchedSkills","")) %>",
    aiMissing:   "<%= jsEsc(app.getOrDefault("aiMissingSkills","")) %>",
    aiReason:    "<%= jsEsc(app.getOrDefault("aiReasoning","")) %>",
    aiAltJob:    "<%= jsEsc(app.getOrDefault("aiRecommendedAlternativeJob","")) %>"
  }<%= i < applications.size() - 1 ? "," : "" %>
<%
    }
  }
%>
};

function filterApps(status, el) {
  document.querySelectorAll('.filter-tab').forEach(function(t){ t.classList.remove('active'); });
  el.classList.add('active');
  document.querySelectorAll('.app-status-card').forEach(function(card) {
    card.style.display = (status === 'all' || card.dataset.status === status) ? '' : 'none';
  });
}

function showDetails(appId) {
  var d = appDetails[appId];
  if (!d) return;
  currentAppId = appId;

  document.getElementById('modal-title').textContent = d.jobTitle || 'Job Details';
  document.getElementById('modal-dept').textContent     = d.dept     || 'N/A';
  document.getElementById('modal-hours').textContent    = d.hours    || 'N/A';
  document.getElementById('modal-duration').textContent = d.duration || 'N/A';
  document.getElementById('modal-status').textContent   = d.appStatus
    ? (d.appStatus.charAt(0).toUpperCase() + d.appStatus.slice(1)) : 'N/A';

  // MO contact section
  var moSec   = document.getElementById('modal-mo-contact');
  var moInner = document.getElementById('modal-mo-contact-inner');
  if (d.appStatus === 'accepted' && d.moEmail) {
    moInner.innerHTML = '🎓 Please contact your Module Organiser: <strong>' +
      (d.moName || 'MO') + '</strong> — <a href="mailto:' + d.moEmail + '">' + d.moEmail + '</a>';
    moSec.style.display = 'block';
  } else {
    moSec.style.display = 'none';
  }

  var descWrap = document.getElementById('modal-desc-wrap');
  if (d.description) {
    descWrap.innerHTML = '<div class="cover-letter-box" id="modal-description"></div>';
    document.getElementById('modal-description').textContent = d.description;
  } else {
    descWrap.innerHTML = '<p class="cover-letter-empty">No description available.</p>';
  }

  document.getElementById('ai-loading').style.display        = 'none';
  document.getElementById('ai-result-panel').style.display   = 'none';
  document.getElementById('ai-altjob-section').style.display = 'none';
  var btn = document.getElementById('ai-analyze-btn');

  if (d.aiScore !== '') {
    renderAiResult({ aiMatchScore: d.aiScore, aiMatchedSkills: d.aiMatched,
                     aiMissingSkills: d.aiMissing, aiReasoning: d.aiReason,
                     aiRecommendedAlternativeJob: d.aiAltJob, cached: true });
    btn.textContent = '🔄 Re-analyse';
    btn.disabled = false;
  } else {
    btn.textContent = '🤖 Get AI Analysis';
    btn.disabled = false;
  }

  document.getElementById('detail-modal-overlay').classList.add('active');
}

function closeModal() {
  document.getElementById('detail-modal-overlay').classList.remove('active');
}

function renderAiResult(data) {
  var scoreEl     = document.getElementById('ai-score');
  var matchedEl   = document.getElementById('ai-matched');
  var missingEl   = document.getElementById('ai-missing');
  var reasonEl    = document.getElementById('ai-reasoning');
  var altJobSec   = document.getElementById('ai-altjob-section');
  var altJobEl    = document.getElementById('ai-altjob');
  var cachedBadge = document.getElementById('ai-cached-badge');

  var score = parseInt(data.aiMatchScore, 10);
  scoreEl.textContent   = isNaN(score) ? data.aiMatchScore : score;
  matchedEl.textContent = data.aiMatchedSkills || '(none)';
  missingEl.textContent = data.aiMissingSkills  || 'None';
  reasonEl.textContent  = data.aiReasoning      || '';
  scoreEl.style.color   = score >= 70 ? '#16a34a' : score >= 50 ? '#d97706' : '#dc2626';

  if (data.aiRecommendedAlternativeJob && data.aiRecommendedAlternativeJob.trim() !== '') {
    altJobEl.textContent = data.aiRecommendedAlternativeJob;
    altJobSec.style.display = 'block';
  } else {
    altJobSec.style.display = 'none';
  }
  if (cachedBadge) cachedBadge.style.display = data.cached ? 'inline' : 'none';

  document.getElementById('ai-loading').style.display      = 'none';
  document.getElementById('ai-result-panel').style.display = 'block';
}

document.addEventListener('DOMContentLoaded', function () {
  var btn = document.getElementById('ai-analyze-btn');
  if (!btn) return;
  btn.addEventListener('click', function () {
    if (!currentAppId) return;
    btn.disabled    = true;
    btn.textContent = '⏳ Analyzing...';
    document.getElementById('ai-loading').style.display      = 'block';
    document.getElementById('ai-result-panel').style.display = 'none';

    fetch(ctxPath + '/ta/analyze-application', {
      method:  'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body:    'applicationId=' + encodeURIComponent(currentAppId)
    })
    .then(function (r) {
      if (!r.ok) return r.text().then(function (t) {
        var msg; try { msg = JSON.parse(t).error; } catch (e) { msg = null; }
        throw new Error(msg || 'Server error ' + r.status);
      });
      return r.json();
    })
    .then(function (data) {
      renderAiResult(data);
      btn.textContent = '🔄 Re-analyse';
      btn.disabled    = false;
      if (appDetails[currentAppId]) {
        appDetails[currentAppId].aiScore   = String(data.aiMatchScore);
        appDetails[currentAppId].aiMatched = data.aiMatchedSkills || '';
        appDetails[currentAppId].aiMissing = data.aiMissingSkills || '';
        appDetails[currentAppId].aiReason  = data.aiReasoning     || '';
        appDetails[currentAppId].aiAltJob  = data.aiRecommendedAlternativeJob || '';
      }
    })
    .catch(function (err) {
      document.getElementById('ai-loading').style.display = 'none';
      btn.disabled    = false;
      btn.textContent = '🤖 Get AI Analysis';
      alert('AI analysis failed: ' + err.message);
    });
  });
});
</script>
</body>
</html>
