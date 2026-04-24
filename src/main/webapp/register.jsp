<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Register - TA Recruitment System</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
  <style>
    .login-header { position: relative; min-height: 40px; margin-bottom: 10px; }
    .school-logo { position: absolute; top: -20px; left: -15px; height: 60px; width: auto; }
    .login-title { padding-top: 45px; }
    #mo-modules-section { display: none; }
    .module-row { display: flex; gap: 8px; align-items: center; margin-bottom: 8px; }
    .module-row input { flex: 1; }
    .remove-module-btn {
      background: none; border: 1px solid #fca5a5; color: #dc2626;
      border-radius: 4px; padding: 4px 10px; cursor: pointer; font-size: 13px; white-space: nowrap;
    }
    .remove-module-btn:hover { background: #fef2f2; }
    .add-module-btn {
      background: none; border: 1px solid #93c5fd; color: #2563eb;
      border-radius: 4px; padding: 6px 14px; cursor: pointer; font-size: 13px; margin-top: 4px;
    }
    .add-module-btn:hover { background: #eff6ff; }
    .module-hint { font-size: 12px; color: #9ca3af; margin-top: 4px; }
  </style>
</head>
<body>
<div class="login-page">
  <div class="login-box">
    <div class="login-header">
      <img src="${pageContext.request.contextPath}/images/logo1.png" class="school-logo" alt="BUPT">
      <h1 class="login-title">Create Account</h1>
    </div>

    <% String error = (String) request.getAttribute("error"); %>
    <% if (error != null) { %>
      <div style="background:#fef2f2;border:1px solid #fca5a5;color:#b91c1c;padding:10px 14px;border-radius:6px;margin-bottom:16px;font-size:13px;">
        <%= error %>
      </div>
    <% } %>

    <form action="${pageContext.request.contextPath}/register" method="post" id="registerForm">

      <div class="form-group">
        <label class="form-label" for="name">Full Name <span style="color:#b91c1c;">*</span></label>
        <input class="form-input" id="name" name="name" type="text"
               placeholder="Enter your full name" required
               value="<%= request.getParameter("name") != null ? request.getParameter("name") : "" %>">
      </div>

      <div class="form-group">
        <label class="form-label" for="email">Email <span style="color:#b91c1c;">*</span></label>
        <input class="form-input" id="email" name="email" type="email"
               placeholder="Enter your email" required
               value="<%= request.getParameter("email") != null ? request.getParameter("email") : "" %>">
      </div>

      <div class="form-group">
        <label class="form-label" for="role">Role <span style="color:#b91c1c;">*</span></label>
        <select class="form-input" id="role" name="role" required onchange="onRoleChange(this.value)">
          <option value="">-- Select role --</option>
          <option value="ta"  <%= "ta".equals(request.getParameter("role"))  ? "selected" : "" %>>Teaching Assistant (TA)</option>
          <option value="mo"  <%= "mo".equals(request.getParameter("role"))  ? "selected" : "" %>>Module Organiser (MO)</option>
        </select>
      </div>

      <div class="form-group">
        <label class="form-label" for="department">Department</label>
        <input class="form-input" id="department" name="department" type="text"
               placeholder="e.g. Computer Science"
               value="<%= request.getParameter("department") != null ? request.getParameter("department") : "" %>">
      </div>

      <div class="form-group">
        <label class="form-label" for="phone">Phone</label>
        <input class="form-input" id="phone" name="phone" type="text"
               placeholder="Enter phone number"
               value="<%= request.getParameter("phone") != null ? request.getParameter("phone") : "" %>">
      </div>

      <!-- MO-only: module assignment -->
      <div id="mo-modules-section">
        <div style="border-top:1px solid #e5e7eb;margin:12px 0 14px;"></div>
        <div style="font-size:14px;font-weight:600;color:#374151;margin-bottom:8px;">
          Assigned Modules
        </div>
        <p class="module-hint" style="margin-bottom:10px;">
          Enter the courses you are responsible for. You can add more later via the admin.
        </p>
        <div id="module-list">
          <div class="module-row">
            <input class="form-input" name="moduleCode" type="text" placeholder="Course Code (e.g. EBU6304)">
            <input class="form-input" name="moduleName" type="text" placeholder="Course Name (e.g. Software Engineering EBU6304)">
          </div>
        </div>
        <button type="button" class="add-module-btn" onclick="addModuleRow()">+ Add another module</button>
        <p class="module-hint">You can leave these blank and have an admin assign modules later.</p>
      </div>

      <div class="form-group">
        <label class="form-label" for="password">Password <span style="color:#b91c1c;">*</span></label>
        <input class="form-input" id="password" name="password" type="password"
               placeholder="At least 6 characters" required>
      </div>

      <div class="form-group">
        <label class="form-label" for="confirmPassword">Confirm Password <span style="color:#b91c1c;">*</span></label>
        <input class="form-input" id="confirmPassword" name="confirmPassword" type="password"
               placeholder="Re-enter password" required>
      </div>

      <div class="flex gap-4" style="margin-top:8px;">
        <button type="submit" class="btn btn-primary flex-1">Register</button>
        <a href="${pageContext.request.contextPath}/login" class="btn btn-outline flex-1" style="text-align:center;">Back to Login</a>
      </div>
    </form>
  </div>
</div>

<script>
function onRoleChange(role) {
  document.getElementById('mo-modules-section').style.display = (role === 'mo') ? 'block' : 'none';
}

function addModuleRow() {
  var list = document.getElementById('module-list');
  var row = document.createElement('div');
  row.className = 'module-row';
  row.innerHTML =
    '<input class="form-input" name="moduleCode" type="text" placeholder="Course Code (e.g. EBU6304)">' +
    '<input class="form-input" name="moduleName" type="text" placeholder="Course Name (e.g. Software Engineering EBU6304)">' +
    '<button type="button" class="remove-module-btn" onclick="this.parentElement.remove()">Remove</button>';
  list.appendChild(row);
}

// Restore MO section if role was pre-selected (e.g. after validation error)
(function() {
  var role = document.getElementById('role').value;
  if (role === 'mo') onRoleChange('mo');
})();
</script>
</body>
</html>
