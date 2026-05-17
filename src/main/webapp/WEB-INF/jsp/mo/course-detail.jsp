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
    /* All modal, lock-notice, section-header, filter-btn, decided-section classes are in style.css */
   .modal-overlay {
     display: none;
     position: fixed;
     top: 0;
     left: 0;
     width: 100%;
     height: 100%;
     background: rgba(0,0,0,0.5);
     z-index: 1000;
     align-items: center;
     justify-content: center;
     padding: 10px;
     box-sizing: border-box;
   }
   .modal-overlay.active { display: flex; }
   .modal-box {
     background: #fff;
     border-radius: 6px;
     padding: 16px;
     max-width: 400px;
     width: 100%;
     position: relative;
     max-height: 180;
     overflow: visible;
     box-shadow: 0 8px 24px rgba(0,0,0,0.2);
   }
   .modal-close {
     position: absolute;
     top: 8px;
     left: 10px;
     font-size: 28px;
     cursor: pointer;
     color: #6b7280;
     border: none;
     background: none;
     line-height: 1;
   }
   .modal-title {
     font-size: 22px;
     font-weight: 600;
     margin: 10px 0 12px 0;
     color: #111827;
   }
   .modal-section {
     margin-top: 10px;
     padding-top: 8px;
     border-top: 1px solid #e5e7eb;
   }
   .modal-section-title {
     font-size: 11px;
     font-weight: 600;
     color: #374151;
     margin-bottom: 4px;
     text-transform: uppercase;
     letter-spacing: 0.03em;
   }
   .info-grid {
     display: grid;
     grid-template-columns: 80px 1fr;
     gap: 6px 8px;
   }
   .info-label {
     font-size: 12px;
     color: #9ca3af;
     font-weight: 500;
     text-transform: uppercase;
   }
   .info-value {
     font-size: 12px;
     color: #111827;
     word-break: break-word;
   }
   .cover-letter-box {
     background: #f9fafb;
     border: 1px solid #e5e7eb;
     border-radius: 4px;
     padding: 8px;
     font-size: 11px;
     color: #374151;
     white-space: pre-wrap;
     max-height: 100px;
     line-height: 1.4;
     overflow: hidden;
   }
   .cover-letter-empty {
     font-size: 11px;
     color: #9ca3af;
     font-style: italic;
   }
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
<!-- ===== VIEW DETAILS MODAL ===== -->
<div id="modal-overlay" class="modal-overlay" onclick="if(event.target===this)closeModal()">
  <div class="modal-box">
    <button class="modal-close" onclick="closeModal()">&times;</button>
    <h3 class="modal-title" id="modal-name"></h3>

    <div class="info-grid">
      <span class="info-label">EMAIL</span>
      <span class="info-value" id="modal-email"></span>

      <span class="info-label">PHONE</span>
      <span class="info-value" id="modal-phone"></span>

      <span class="info-label">DEPARTMENT</span>
      <span class="info-value" id="modal-dept"></span>
    </div>

    <div class="modal-section">
      <p class="modal-section-title">COVER LETTER</p>
      <div id="modal-cover-wrap">
        <div class="cover-letter-box" id="modal-cover"></div>
      </div>
    </div>

    <div class="modal-section" id="modal-cv-section">
      <p class="modal-section-title">CV / RESUME</p>
      <a id="modal-cv-link" href="#" target="_blank" class="btn btn-outline btn-sm">
        View / Download CV
      </a>
    </div>
    <div class="modal-section" id="modal-no-cv-section" style="display:none;">
      <p class="modal-section-title">CV / RESUME</p>
      <p class="cover-letter-empty">No CV uploaded for this user.</p>
    </div>

    <!-- ===== AI 匹配分析 Section ===== -->
    <div class="modal-section" id="modal-ai-section">
      <p class="modal-section-title">AI MATCHING ANALYSIS</p>

      <% if (isOwner) { %>
      <button id="ai-analyze-btn" type="button" class="btn btn-primary btn-sm" style="margin-bottom:12px;">
        🤖 Get AI Analysis Report
      </button>
      <% } else { %>
      <p class="cover-letter-empty">Only course owner can trigger AI analysis.</p>
      <% } %>

      <div id="ai-loading" style="display:none; padding:12px; background:#fef3c7; border:1px solid #fbbf24; border-radius:6px; color:#92400e; font-size:13px;">
        ⏳ Analyzing with Gemini AI... Please wait.
      </div>

      <div id="ai-result-panel" style="display:none; padding:16px; background:#f0f9ff; border:1px solid #0ea5e9; border-radius:8px;">
        <div style="margin-bottom:12px;">
          <span style="font-size:14px; font-weight:600; color:#0c4a6e;">MATCH SCORE:</span>
          <span id="ai-score" style="font-size:20px; font-weight:700; color:#0284c7; margin-left:8px;"></span>
          <span style="font-size:14px; color:#475569;">/100</span>
        </div>

        <!-- 匹配技能 -->
        <div style="margin-bottom:10px;">
          <p style="font-size:13px; font-weight:600; color:#0c4a6e; margin:0 0 4px 0;">✅ Matched Skills:</p>
          <p id="ai-matched" style="margin:0; font-size:13px; color:#334155; line-height:1.6;"></p>
        </div>

        <!-- 缺失技能 -->
        <div style="margin-bottom:10px;">
          <p style="font-size:13px; font-weight:600; color:#0c4a6e; margin:0 0 4px 0;">⚠️ Missing Skills:</p>
          <p id="ai-missing" style="margin:0; font-size:13px; color:#334155; line-height:1.6;"></p>
        </div>

        <!-- 理由 -->
        <div>
          <p style="font-size:13px; font-weight:600; color:#0c4a6e; margin:0 0 4px 0;">💡 Reasoning:</p>
          <p id="ai-reasoning" style="margin:0; font-size:13px; color:#334155; line-height:1.6; white-space:pre-wrap;"></p>
        </div>
      </div>
    </div>

  </div>
</div>

<!-- Application data for JavaScript -->
<script>
var ctxPath = "${pageContext.request.contextPath}";
var currentAppId = null;  // 当前 modal 打开的 appId
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

  // 记录当前打开的申请 ID（AI 分析按钮需要用到）
  currentAppId = appId;

  // 重置 AI 面板为初始状态
  document.getElementById('ai-result-panel').style.display = 'none';
  document.getElementById('ai-loading').style.display      = 'none';
  var btn = document.getElementById('ai-analyze-btn');
  if (btn) { btn.disabled = false; btn.textContent = '🤖 Get AI Analysis Report'; }

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

// ─── AI 匹配分析交互逻辑 ─────────────────────────────────────────────────
(function () {
  // 等 DOM 就绪后挂载事件（modal 是静态 HTML，按钮始终存在）
  document.addEventListener('DOMContentLoaded', function () {
    var btn = document.getElementById('ai-analyze-btn');
    if (!btn) return; // 非 owner 页面不渲染此按钮

    btn.addEventListener('click', function () {
      if (!currentAppId) return;

      // 1. 禁用按钮 + 显示 Loading
      btn.disabled = true;
      btn.textContent = '⏳ Analyzing...';
      document.getElementById('ai-loading').style.display      = 'block';
      document.getElementById('ai-result-panel').style.display = 'none';

      // 2. 构造 POST body（application/x-www-form-urlencoded）
      var body = 'applicationId=' + encodeURIComponent(currentAppId);

      // 3. 发送 AJAX 请求
      fetch(ctxPath + '/mo/analyze-application', {
        method:  'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body:    body
      })
      .then(function (response) {
        if (!response.ok) {
          return response.text().then(function (text) {
            var msg;
            try { msg = JSON.parse(text).error; } catch (e) { msg = null; }
            throw new Error(msg || 'Server error: ' + response.status);
          });
        }
        return response.json();
      })
      .then(function (data) {
        // 4. 渲染结果到面板
        var scoreEl   = document.getElementById('ai-score');
        var matchedEl = document.getElementById('ai-matched');
        var missingEl = document.getElementById('ai-missing');
        var reasonEl  = document.getElementById('ai-reasoning');

        scoreEl.textContent   = data.aiMatchScore;
        matchedEl.textContent = data.aiMatchedSkills || '(none)';
        missingEl.textContent = data.aiMissingSkills || 'None';
        reasonEl.textContent  = data.aiReasoning     || '';

        // 根据分数动态着色
        var score = parseInt(data.aiMatchScore, 10);
        scoreEl.style.color = score >= 70 ? '#16a34a' : score >= 50 ? '#d97706' : '#dc2626';

        // 5. 隐藏 Loading，显示结果
        document.getElementById('ai-loading').style.display      = 'none';
        document.getElementById('ai-result-panel').style.display = 'block';
        btn.textContent = '🔄 Re-analyse';
        btn.disabled    = false;
      })
      .catch(function (err) {
        // 6. 错误处理：恢复按钮，隐藏 loading，提示用户
        document.getElementById('ai-loading').style.display = 'none';
        btn.disabled    = false;
        btn.textContent = '🤖 Get AI Analysis Report';
        alert('AI analysis failed: ' + err.message + '\nPlease check your API key and network.');
      });
    });
  });
})();
</script>
</body>
</html>