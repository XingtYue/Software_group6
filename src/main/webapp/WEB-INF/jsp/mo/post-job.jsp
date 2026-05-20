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
      <div class="alert alert-success"><%= success %></div>
      <% } %>

      <%
        // 只定义一次！
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

          <div style="display:flex;gap:16px;align-items:flex-start;">
            <div class="form-group" style="width:140px;flex-shrink:0;">
              <label class="form-label" for="openings">Openings <span style="color:#b91c1c;">*</span></label>
              <input class="form-input" id="openings" name="openings" type="number" min="1" max="50"
                     placeholder="e.g. 3" required style="text-align:center;" value="1">
            </div>
            <div class="form-group" style="width:140px;flex-shrink:0;">
              <label class="form-label" for="hours">Hrs/Week <span style="color:#b91c1c;">*</span></label>
              <input class="form-input" id="hours" name="hours" type="number" min="1" max="40"
                     placeholder="e.g. 10" required style="text-align:center;">
            </div>
            <div class="form-group" style="flex:1;">
              <label class="form-label">Duration <span style="color:#b91c1c;">*</span></label>
              <input type="hidden" id="duration" name="duration">
              <div style="display:flex;align-items:center;gap:8px;">
                <div id="wkCount" style="font-size:13px;color:#374151;flex:1;">No weeks selected</div>
                <button type="button" class="btn btn-outline btn-sm" onclick="toggleWeekPicker()" id="wkToggleBtn">
                  ▾ Select Weeks
                </button>
              </div>
              <div id="weekPicker" style="display:none;margin-top:8px;padding:12px;border:1px solid #e5e7eb;border-radius:8px;background:#f9fafb;">
                <div style="display:flex;gap:6px;flex-wrap:wrap;margin-bottom:8px;">
                  <button type="button" class="btn btn-outline btn-sm" onclick="selectWeeks(1,9)">Sem 1 (Wk 1–9)</button>
                  <button type="button" class="btn btn-outline btn-sm" onclick="selectWeeks(10,18)">Sem 2 (Wk 10–18)</button>
                  <button type="button" class="btn btn-outline btn-sm" onclick="selectAllWeeks()">All</button>
                  <button type="button" class="btn btn-outline btn-sm" onclick="clearAllWeeks()">Clear</button>
                </div>
                <div style="display:grid;grid-template-columns:repeat(6,1fr);gap:4px;">
                  <% for (int w = 1; w <= 18; w++) { %>
                  <label style="display:flex;align-items:center;gap:4px;font-size:12px;cursor:pointer;
                                padding:4px 6px;border:1px solid #e5e7eb;border-radius:5px;background:#fff;user-select:none;">
                    <input type="checkbox" class="wk-cb" value="<%= w %>" onchange="syncDuration()">
                    <span>Wk <%= w %></span>
                  </label>
                  <% } %>
                </div>
              </div>
            </div>
          </div>

          <div class="flex gap-4 pt-4" style="border-top:1px solid #e2e8f0;margin-top:8px;">
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
    autoTitle();
  }

  function autoTitle() {
    var courseNameEl = document.getElementById('courseName');
    var posEl = document.getElementById('positionType');
    var titleEl = document.getElementById('title');
    if (!courseNameEl.value || !posEl.value) return;
    if (!titleEl.value) {
      titleEl.value = courseNameEl.value + ' - ' + posEl.value + ' TA';
    }
  }

  function toggleWeekPicker() {
    var picker = document.getElementById('weekPicker');
    var btn = document.getElementById('wkToggleBtn');
    if (picker.style.display === 'none') {
      picker.style.display = 'block';
      btn.textContent = '▴ Close';
    } else {
      picker.style.display = 'none';
      btn.textContent = '▾ Select Weeks';
    }
  }

  function syncDuration() {
    var checked = Array.from(document.querySelectorAll('.wk-cb:checked'))
                       .map(function(cb) { return parseInt(cb.value); });
    checked.sort(function(a, b) { return a - b; });
    document.getElementById('duration').value = checked.join(',');
    document.getElementById('wkCount').textContent = checked.length > 0
      ? checked.length + ' week(s) selected (Wk ' + checked[0] + ' – Wk ' + checked[checked.length-1] + ')'
      : 'No weeks selected';
  }

  function selectAllWeeks() {
    document.querySelectorAll('.wk-cb').forEach(function(cb) { cb.checked = true; });
    syncDuration();
  }

  function clearAllWeeks() {
    document.querySelectorAll('.wk-cb').forEach(function(cb) { cb.checked = false; });
    syncDuration();
  }

  function selectWeeks(from, to) {
    document.querySelectorAll('.wk-cb').forEach(function(cb) {
      var v = parseInt(cb.value);
      cb.checked = (v >= from && v <= to);
    });
    syncDuration();
  }

  document.getElementById('positionType').addEventListener('change', autoTitle);
</script>
</body>
</html>
