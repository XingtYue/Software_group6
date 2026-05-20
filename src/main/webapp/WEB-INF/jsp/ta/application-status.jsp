<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, java.util.Map" %>
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
            <%
              List<Map<String,String>> applications =
                (List<Map<String,String>>) request.getAttribute("applications");
              if (applications != null && !applications.isEmpty()) {
                for (Map<String,String> app : applications) {
                  String status = app.get("status");
                  String badgeClass = "badge-pending";
                  if ("accepted".equals(status)) badgeClass = "badge-accepted";
                  else if ("rejected".equals(status)) badgeClass = "badge-rejected";
                  String statusLabel = status.substring(0,1).toUpperCase() + status.substring(1);

                  // AI 分数徽章
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
            %>
            <div class="applicant-card">
              <div class="applicant-card-inner">
                <div style="flex:1;">
                  <div style="display:flex;align-items:center;gap:10px;margin-bottom:6px;flex-wrap:wrap;">
                    <h3 class="text-lg"><%= app.get("jobTitle") %></h3>
                    <span class="badge <%= badgeClass %>"><%= statusLabel %></span>
                    <span class="ai-score-badge <%= aiBadgeClass %>"><%= aiBadgeLabel %></span>
                  </div>
                  <p class="text-sm text-gray-600">Applied: <%= app.get("appliedDate") %></p>
                  <% String cl = app.get("coverLetter"); if (cl != null && !cl.trim().isEmpty()) { %>
                  <p class="text-sm text-gray-600" style="margin-top:4px;">Cover letter: <%= cl.length() > 80 ? cl.substring(0,80) + "..." : cl %></p>
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

<!-- ===== View Details Modal（岗位信息 + AI 分析合并） ===== -->
<div id="detail-modal-overlay" class="modal-overlay" onclick="if(event.target===this)closeModal()">
  <div class="modal-box">
    <button class="modal-close" onclick="closeModal()">&times;</button>
    <h3 class="modal-title" id="modal-title"></h3>

    <!-- 岗位基本信息 -->
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

    <div class="modal-section">
      <p class="modal-section-title">Description</p>
      <div id="modal-desc-wrap">
        <div class="cover-letter-box" id="modal-description"></div>
      </div>
    </div>

    <!-- AI 分析区 -->
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

<!-- 预加载所有申请数据 -->
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
    status:      "<%= jsEsc(app.getOrDefault("jobStatus","")) %>",
    description: "<%= jsEsc(app.getOrDefault("jobDescription","")) %>",
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

function showDetails(appId) {
  var d = appDetails[appId];
  if (!d) return;
  currentAppId = appId;

  document.getElementById('modal-title').textContent = d.jobTitle || 'Job Details';
  document.getElementById('modal-dept').textContent     = d.dept     || 'N/A';
  document.getElementById('modal-hours').textContent    = d.hours    || 'N/A';
  document.getElementById('modal-duration').textContent = d.duration || 'N/A';
  document.getElementById('modal-status').textContent   = d.status   || 'N/A';

  var descWrap = document.getElementById('modal-desc-wrap');
  if (d.description) {
    descWrap.innerHTML = '<div class="cover-letter-box" id="modal-description"></div>';
    document.getElementById('modal-description').textContent = d.description;
  } else {
    descWrap.innerHTML = '<p class="cover-letter-empty">No description available.</p>';
  }

  // 重置 AI 区
  document.getElementById('ai-loading').style.display      = 'none';
  document.getElementById('ai-result-panel').style.display = 'none';
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
      // 同步更新 appDetails 缓存，刷新前不重复请求
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