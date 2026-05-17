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
      max-width: 520px; width: 100%; position: relative;
      box-shadow: 0 10px 30px rgba(0,0,0,0.25);
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
      white-space: pre-wrap; max-height: 180px; line-height: 1.5;
      overflow-y: auto;
    }
    .cover-letter-empty { font-size: 14px; color: #9ca3af; font-style: italic; }
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
            %>
            <div class="applicant-card">
              <div class="applicant-card-inner">
                <div style="flex:1;">
                  <h3 class="text-lg mb-2"><%= app.get("jobTitle") %></h3>
                  <p class="text-sm text-gray-600">Applied: <%= app.get("appliedDate") %></p>
                  <% String cl = app.get("coverLetter"); if (cl != null && !cl.trim().isEmpty()) { %>
                  <p class="text-sm text-gray-600" style="margin-top:6px;">Cover letter: <%= cl.length() > 80 ? cl.substring(0,80) + "..." : cl %></p>
                  <% } %>
                </div>
                <div class="applicant-actions">
                  <!-- 新增：和View Details样式一样的按钮，用于查看Job详情 -->
                  <button type="button" class="btn btn-outline btn-sm" onclick="showJobDetails('<%= app.get("jobId") %>')">View Job Details</button>
                  <span class="badge <%= badgeClass %>"><%= statusLabel %></span>
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

<!-- ===== Job Detail Modal（和截图格式一致） ===== -->
<div id="job-modal-overlay" class="modal-overlay" onclick="if(event.target===this)closeJobModal()">
  <div class="modal-box">
    <button class="modal-close" onclick="closeJobModal()">&times;</button>
    <h3 class="modal-title" id="job-modal-title"></h3>

    <div class="info-grid">
      <span class="info-label">Department</span>
      <span class="info-value" id="job-modal-dept"></span>

      <span class="info-label">Hours</span>
      <span class="info-value" id="job-modal-hours"></span>

      <span class="info-label">Duration</span>
      <span class="info-value" id="job-modal-duration"></span>

      <span class="info-label">Status</span>
      <span class="info-value" id="job-modal-status"></span>
    </div>

    <div class="modal-section">
      <p class="modal-section-title">Description</p>
      <div id="job-modal-desc-wrap">
        <div class="cover-letter-box" id="job-modal-description"></div>
      </div>
    </div>
  </div>
</div>

<script>
var ctxPath = "${pageContext.request.contextPath}";
// 预加载所有Job数据（后端直接输出到前端，和View Details逻辑一致）
var jobDetails = {
<%
  if (applications != null) {
    for (int i = 0; i < applications.size(); i++) {
      Map<String,String> app = applications.get(i);
      String jobId = app.get("jobId");
      if (jobId == null) jobId = "";
%>
  "<%= jobId %>": {
    title: "<%= jsEsc(app.getOrDefault("jobTitle", "")) %>",
    department: "<%= jsEsc(app.getOrDefault("jobDepartment", "")) %>",
    hours: "<%= jsEsc(app.getOrDefault("jobHours", "")) %>",
    duration: "<%= jsEsc(app.getOrDefault("jobDuration", "")) %>",
    status: "<%= jsEsc(app.getOrDefault("jobStatus", "")) %>",
    description: "<%= jsEsc(app.getOrDefault("jobDescription", "")) %>"
  }<%= i < applications.size() - 1 ? "," : "" %>
<%
    }
  }
%>
};

// 打开Job详情弹窗
function showJobDetails(jobId) {
  var job = jobDetails[jobId];
  if (!job) return;

  // 填充数据到弹窗
  document.getElementById('job-modal-title').textContent = job.title || 'Job Details';
  document.getElementById('job-modal-dept').textContent = job.department || 'N/A';
  document.getElementById('job-modal-hours').textContent = job.hours || 'N/A';
  document.getElementById('job-modal-duration').textContent = job.duration || 'N/A';
  document.getElementById('job-modal-status').textContent = job.status || 'N/A';

  // 处理描述
  var descWrap = document.getElementById('job-modal-desc-wrap');
  if (job.description) {
    descWrap.innerHTML = '<div class="cover-letter-box" id="job-modal-description"></div>';
    document.getElementById('job-modal-description').textContent = job.description;
  } else {
    descWrap.innerHTML = '<p class="cover-letter-empty">No description available.</p>';
  }

  // 显示弹窗
  document.getElementById('job-modal-overlay').classList.add('active');
}

// 关闭Job详情弹窗
function closeJobModal() {
  document.getElementById('job-modal-overlay').classList.remove('active');
}
</script>
</body>
</html>