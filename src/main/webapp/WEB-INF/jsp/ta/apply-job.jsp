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
  <%@ include file="taheader.jsp" %>
  <div class="nav-main-row">
    <a href="${pageContext.request.contextPath}/ta/jobs" class="nav-link active">Browse Jobs</a>
    <a href="${pageContext.request.contextPath}/ta/applications" class="nav-link">My Applications</a>
  </div>

  <main class="main-content" style="overflow-y:auto;">
    <div style="max-width:800px;margin:0 auto;padding:24px;">
      <% String jobId = (String) request.getAttribute("jobId"); if (jobId == null) jobId = "1"; %>
      <a href="${pageContext.request.contextPath}/ta/jobs/<%= jobId %>"
         class="btn btn-outline btn-sm mb-6">&larr; Back to Job Details</a>

      <div class="card card-p8" style="margin-top:16px;">
        <h2 class="text-2xl mb-6">Application Form</h2>

        <form action="${pageContext.request.contextPath}/ta/apply/<%= jobId %>"
              method="post" enctype="multipart/form-data">

          <!-- CV Section -->
          <div class="form-group">
            <label class="form-label">CV / Resume</label>
            <%
              String userCv = (String) request.getAttribute("userCvFileName");
              boolean hasCv = userCv != null && !userCv.trim().isEmpty();
            %>
            <% if (hasCv) { %>
            <div style="margin-top:6px;padding:13px 16px;border:1px solid #e2e8f0;border-radius:8px;background:#f8fafc;display:flex;justify-content:space-between;align-items:center;margin-bottom:10px;">
              <span style="font-size:13px;color:#334155;font-weight:500;">&#128196; <%= userCv %> <span style="color:#94a3b8;font-weight:400;">(from your profile)</span></span>
              <a href="${pageContext.request.contextPath}/ta/cv/download" target="_blank" class="btn btn-outline btn-sm">View</a>
            </div>
            <div style="margin-top:4px;">
              <label style="font-size:13px;color:#64748b;margin-bottom:6px;display:block;font-weight:500;">Update CV (optional — replaces your profile CV)</label>
              <div class="upload-area">
                <div class="upload-icon">&#128196;</div>
                <input name="cv" type="file" accept=".pdf,.doc,.docx"
                       style="display:block;width:100%;font-size:13px;color:#475569;margin-top:8px;">
                <p style="font-size:12px;color:#94a3b8;margin-top:4px;">PDF, DOC or DOCX</p>
              </div>
            </div>
            <% } else { %>
            <div class="alert alert-warning" style="margin-top:6px;">
              No CV on file. Please upload your CV below, or manage it on your <a href="${pageContext.request.contextPath}/ta/profile" style="color:#92400e;font-weight:600;">Profile</a> page.
            </div>
            <div class="upload-area" style="margin-top:4px;">
              <div class="upload-icon">&#128196;</div>
              <input name="cv" type="file" accept=".pdf,.doc,.docx"
                     style="display:block;width:100%;font-size:13px;color:#475569;margin-top:8px;">
              <p style="font-size:12px;color:#94a3b8;margin-top:4px;">PDF, DOC or DOCX</p>
            </div>
            <% } %>
          </div>

          <div class="form-group">
            <label class="form-label" for="coverLetter">Cover Letter (Optional)</label>
            <textarea class="form-textarea" id="coverLetter" name="coverLetter"
                      rows="6" placeholder="Why are you interested in this position?"></textarea>
          </div>

          <div class="flex gap-4 pt-4" style="border-top:1px solid #e2e8f0;margin-top:8px;">
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