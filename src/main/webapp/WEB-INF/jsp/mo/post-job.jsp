<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Post New Job - MO Portal</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
<div class="page-wrapper">
  <header class="site-header">
    <div class="header-inner">
      <div class="header-left">
        <span class="site-title">MO Portal</span>
        <nav>
          <a href="${pageContext.request.contextPath}/mo/applicants" class="nav-link">Review Applicants</a>
          <a href="${pageContext.request.contextPath}/mo/post-job" class="nav-link active">Post New Job</a>
        </nav>
      </div>
      <div class="header-right">
        <a href="${pageContext.request.contextPath}/mo/profile" class="btn-icon" title="Profile">
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
      <% String success = (String) request.getAttribute("success"); %>
      <% if (success != null) { %>
        <div style="background:#f0fdf4;border:1px solid #86efac;color:#15803d;padding:12px 16px;border-radius:6px;margin-bottom:16px;">
          <%= success %>
        </div>
      <% } %>

      <div class="card card-p8">
        <h2 class="text-2xl mb-6">Post New Job</h2>

        <form action="${pageContext.request.contextPath}/mo/post-job" method="post">
          <div class="form-group">
            <label class="form-label" for="title">Job Title</label>
            <input class="form-input" id="title" name="title" type="text"
                   placeholder="e.g. TA for Software Engineering Module" required>
          </div>

          <div class="form-grid-2">
            <div class="form-group">
              <label class="form-label" for="courseCode">Course Code</label>
              <input class="form-input" id="courseCode" name="courseCode" type="text"
                     placeholder="e.g. EBU6304" required>
            </div>
            <div class="form-group">
              <label class="form-label" for="department">Department</label>
              <input class="form-input" id="department" name="department" type="text"
                     placeholder="e.g. Computer Science" required>
            </div>
          </div>

          <div class="form-group">
            <label class="form-label" for="description">Job Description</label>
            <textarea class="form-textarea" id="description" name="description" rows="4"
                      placeholder="Describe the role and responsibilities..." required></textarea>
          </div>

          <div class="form-group">
            <label class="form-label" for="requirements">Requirements (one per line)</label>
            <textarea class="form-textarea" id="requirements" name="requirements" rows="4"
                      placeholder="Strong programming skills&#10;Previous TA experience preferred&#10;Available 10 hours per week"></textarea>
          </div>

          <div class="form-grid-2">
            <div class="form-group">
              <label class="form-label" for="hours">Hours per Week</label>
              <input class="form-input" id="hours" name="hours" type="text"
                     placeholder="e.g. 10 hours/week" required>
            </div>
            <div class="form-group">
              <label class="form-label" for="duration">Duration</label>
              <select class="form-select" id="duration" name="duration">
                <option value="Full Academic Year">Full Academic Year</option>
                <option value="Semester 1">Semester 1</option>
                <option value="Semester 2">Semester 2</option>
              </select>
            </div>
          </div>

          <div class="flex gap-4 pt-4" style="border-top:1px solid #e5e7eb;margin-top:8px;">
            <button type="submit" class="btn btn-primary">Post Job</button>
            <a href="${pageContext.request.contextPath}/mo/applicants" class="btn btn-outline">Cancel</a>
          </div>
        </form>
      </div>
    </div>
  </main>
</div>
</body>
</html>
