<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, java.util.Map" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Post New Position - MO Portal</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
<div class="page-wrapper">
   <%@ include file="moheader.jsp" %>

   <div class="nav-main-row">
     <a href="${pageContext.request.contextPath}/mo/applicants" class="nav-link">Review Applicants</a>
     <a href="${pageContext.request.contextPath}/mo/post-job" class="nav-link active">Post New Position</a>
   </div>

  <main class="main-content" style="overflow-y:auto;">
    <div style="max-width:800px;margin:0 auto;padding:24px;">

      <% String success = (String) request.getAttribute("success"); %>
      <% if (success != null) { %>
        <div style="background:#f0fdf4;border:1px solid #86efac;color:#15803d;padding:12px 16px;border-radius:6px;margin-bottom:16px;">
          <%= success %>
        </div>
      <% } %>

      <%
        List<Map<String,String>> moModules = (List<Map<String,String>>) request.getAttribute("moModules");
        boolean hasModules = moModules != null && !moModules.isEmpty();
      %>

      <% if (!hasModules) { %>
      <div style="background:#fef3c7;border:1px solid #fcd34d;color:#92400e;padding:14px 18px;border-radius:8px;margin-bottom:20px;">
        <strong>No modules assigned.</strong> You have no courses assigned to your account yet.
        Please contact an administrator to add your modules before posting positions.
      </div>
      <% } %>

      <div class="card card-p8">
        <h2 class="text-2xl mb-6">Post New Position</h2>

        <form action="${pageContext.request.contextPath}/mo/post-job" method="post">

          <!-- Course selection from MO's assigned modules -->
          <div class="form-group">
            <label class="form-label" for="moduleSelect">Course <span style="color:#b91c1c;">*</span></label>
            <% if (hasModules) { %>
            <select class="form-select" id="moduleSelect" name="moduleSelect" required
                    onchange="fillCourseFields(this)">
              <option value="">-- Select a course --</option>
              <% for (Map<String,String> mod : moModules) { %>
              <option value="<%= mod.get("code") %>|<%= mod.get("name") %>">
                <%= mod.get("name") %> (<%= mod.get("code") %>)
              </option>
              <% } %>
            </select>
            <% } else { %>
            <select class="form-select" disabled>
              <option>No courses assigned — contact admin</option>
            </select>
            <% } %>
            <input type="hidden" id="courseCode" name="courseCode">
            <input type="hidden" id="courseName" name="courseName">
          </div>

          <div class="form-grid-2">
            <div class="form-group">
              <label class="form-label" for="positionType">Position Type <span style="color:#b91c1c;">*</span></label>
              <select class="form-select" id="positionType" name="positionType" required>
                <option value="">Select Position Type</option>
                <option value="Assignment Grading">Assignment Grading</option>
                <option value="Lab Assessment">Lab Assessment</option>
                <option value="Project Assessment">Project Assessment</option>
                <option value="Exam Invigilation">Exam Invigilation</option>
                <option value="Lab Session Support">Lab Session Support</option>
                <option value="Tutorial Support">Tutorial Support</option>
                <option value="Other">Other</option>
              </select>
            </div>
            <div class="form-group">
              <label class="form-label" for="department">Department <span style="color:#b91c1c;">*</span></label>
              <input class="form-input" id="department" name="department" type="text"
                     placeholder="e.g. Computer Science" required>
            </div>
          </div>

          <div class="form-group">
            <label class="form-label" for="title">Position Title <span style="color:#b91c1c;">*</span></label>
            <input class="form-input" id="title" name="title" type="text"
                   placeholder="e.g. Software Engineering - Assignment Grading TA" required>
          </div>

          <div class="form-group">
            <label class="form-label" for="description">Job Description <span style="color:#b91c1c;">*</span></label>
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
              <label class="form-label" for="hours">Hours per Week <span style="color:#b91c1c;">*</span></label>
              <input class="form-input" id="hours" name="hours" type="text"
                     placeholder="e.g. 10" required>
            </div>
            <div class="form-group">
              <label class="form-label" for="duration">Duration</label>
              <select class="form-select" id="duration" name="duration">
                <option value="Full Academic Year">Full Academic Year</option>
                <option value="Semester 1">Semester 1</option>
                <option value="Semester 2">Semester 2</option>
                <option value="Exam Period">Exam Period</option>
              </select>
            </div>
          </div>

          <div class="flex gap-4 pt-4" style="border-top:1px solid #e5e7eb;margin-top:8px;">
            <button type="submit" class="btn btn-primary" <%= !hasModules ? "disabled" : "" %>>Post Position</button>
            <a href="${pageContext.request.contextPath}/mo/applicants" class="btn btn-outline">Cancel</a>
          </div>
        </form>
      </div>
    </div>
  </main>
</div>

<script>
function fillCourseFields(sel) {
  var val = sel.value;
  if (!val) {
    document.getElementById('courseCode').value = '';
    document.getElementById('courseName').value = '';
    return;
  }
  var parts = val.split('|');
  document.getElementById('courseCode').value = parts[0] || '';
  document.getElementById('courseName').value = parts[1] || parts[0] || '';

  // Auto-suggest title if positionType is already selected
  autoTitle();
}

function autoTitle() {
  var courseNameEl = document.getElementById('courseName');
  var posEl = document.getElementById('positionType');
  var titleEl = document.getElementById('title');
  if (!courseNameEl.value || !posEl.value) return;
  // Only auto-fill if title is still empty
  if (!titleEl.value) {
    titleEl.value = courseNameEl.value + ' - ' + posEl.value + ' TA';
  }
}

document.getElementById('positionType').addEventListener('change', autoTitle);
</script>
</body>
</html>
