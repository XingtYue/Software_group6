<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Apply for Job - TA Portal</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
<div class="page-wrapper">
  <header class="site-header">
    <div class="header-inner">
      <div class="header-left">
        <span class="site-title">TA Portal</span>
        <nav>
          <a href="${pageContext.request.contextPath}/ta/jobs" class="nav-link active">Browse Jobs</a>
          <a href="${pageContext.request.contextPath}/ta/applications" class="nav-link">My Applications</a>
        </nav>
      </div>
      <div class="header-right">
        <a href="${pageContext.request.contextPath}/ta/profile" class="btn-icon" title="Profile">
          <svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
            <circle cx="12" cy="8" r="4"/><path d="M4 20c0-4 3.6-7 8-7s8 3 8 7"/>
          </svg>
        </a>
        <a href="${pageContext.request.contextPath}/logout" class="btn btn-outline btn-sm">Logout</a>
      </div>
    </div>
  </header>

  <main class="main-content" style="overflow-y:auto;">
    <div style="max-width:800px;margin:0 auto;padding:24px;">
      <% String jobId = (String) request.getAttribute("jobId"); if (jobId == null) jobId = "1"; %>
      <a href="${pageContext.request.contextPath}/ta/jobs/<%= jobId %>"
         class="btn btn-outline btn-sm mb-6">&larr; Back to Job Details</a>

      <% String success = (String) request.getAttribute("success"); %>
      <% if (success != null) { %>
        <div style="background:#f0fdf4;border:1px solid #86efac;color:#15803d;padding:12px 16px;border-radius:6px;margin-bottom:16px;">
          <%= success %>
        </div>
      <% } %>

      <div class="card card-p8" style="margin-top:16px;">
        <h2 class="text-2xl mb-6">Application Form</h2>

        <form action="${pageContext.request.contextPath}/ta/jobs/<%= jobId %>/apply"
              method="post" enctype="multipart/form-data">

          <div class="form-group">
            <label class="form-label" for="cv">Upload CV (PDF)</label>
            <div class="upload-area" style="margin-top:8px;">
              <div class="upload-icon">&#128196;</div>
              <input id="cv" name="cv" type="file" accept=".pdf,.doc,.docx"
                     style="display:block;width:100%;font-size:13px;color:#4b5563;margin-top:8px;">
              <p style="font-size:12px;color:#9ca3af;margin-top:8px;">PDF, DOC or DOCX accepted</p>
            </div>
          </div>

          <div class="form-group">
            <label class="form-label" for="coverLetter">Cover Letter (Optional)</label>
            <textarea class="form-textarea" id="coverLetter" name="coverLetter"
                      rows="6" placeholder="Why are you interested in this position?"></textarea>
          </div>

          <div class="flex gap-4 pt-4" style="border-top:1px solid #e5e7eb;margin-top:8px;">
            <button type="submit" class="btn btn-primary">Submit Application</button>
            <a href="${pageContext.request.contextPath}/ta/jobs/<%= jobId %>"
               class="btn btn-outline">Cancel</a>
          </div>
        </form>
      </div>
    </div>
  </main>
</div>
</body>
</html>
