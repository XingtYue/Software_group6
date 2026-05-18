<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Register - TA Recruitment System</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
  <style>
    /* 登录页统一样式：背景、卡片、输入框、按钮全部继承 */
    .login-page {
      margin: 0;
      padding: 0;
      width: 100%;
      min-height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
      background-image:
              linear-gradient(rgba(0, 0, 0, 0.25), rgba(0, 0, 0, 0.25)),
              url("${pageContext.request.contextPath}/images/Login_bg.png");
      background-size: cover;
      background-position: center;
      background-repeat: no-repeat;
      background-attachment: fixed;
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
    }

    .login-box {
      width: 100%;
      max-width: 480px;
      padding: 48px 40px;
      background: rgba(255, 255, 255, 0.75);
      backdrop-filter: blur(24px) saturate(120%);
      -webkit-backdrop-filter: blur(24px) saturate(120%);
      border: 1px solid rgba(255, 255, 255, 0.8);
      border-radius: 24px;
      box-shadow: 0 24px 48px -12px rgba(0, 0, 0, 0.15),
      inset 0 1px 0 rgba(255, 255, 255, 1);
    }

    .login-header {
      display: flex;
      flex-direction: column;
      align-items: center;
      margin-bottom: 36px;
      text-align: center;
      position: relative;
      min-height: 40px;
    }
    .school-logo {
      height: 60px;
      width: auto;
      margin-bottom: 20px;
    }
    .login-title {
      font-size: 22px;
      font-weight: 700;
      color: #1a1f36;
      letter-spacing: -0.5px;
      margin: 0;
      padding-top: 0;
    }

    .form-group {
      margin-bottom: 20px;
      text-align: left;
    }
    .form-label {
      font-size: 13px;
      font-weight: 600;
      color: #3c4257;
      margin-bottom: 8px;
      display: block;
    }
    .form-input {
      width: 100%;
      padding: 14px 16px;
      font-size: 15px;
      color: #1a1f36;
      background-color: rgba(255, 255, 255, 0.5);
      border: 1px solid rgba(255, 255, 255, 0.8);
      border-radius: 12px;
      box-sizing: border-box;
      transition: all 0.3s ease;
    }
    .form-input:focus {
      outline: none;
      background-color: #ffffff;
      border-color: #0A2540;
      box-shadow: 0 0 0 4px rgba(10, 37, 64, 0.1);
    }

    .btn-container, .flex {
      display: flex;
      gap: 16px;
      margin-top: 24px;
    }
    .btn {
      flex: 1;
      padding: 14px 0;
      font-size: 15px;
      font-weight: 600;
      border-radius: 12px;
      text-align: center;
      cursor: pointer;
      transition: all 0.2s ease;
      box-sizing: border-box;
      text-decoration: none;
      display: flex;
      justify-content: center;
      align-items: center;
    }
    .btn-primary {
      background: linear-gradient(180deg, #1a1f36 0%, #0a0d1a 100%);
      color: #ffffff;
      border: 1px solid #000000;
      box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.15),
      0 4px 6px -1px rgba(0, 0, 0, 0.2);
    }
    .btn-primary:hover {
      background: linear-gradient(180deg, #2a314d 0%, #1a1f36 100%);
      transform: translateY(-1px);
      box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.15),
      0 6px 12px -2px rgba(0, 0, 0, 0.3);
    }
    .btn-outline {
      background: rgba(255, 255, 255, 0.6);
      color: #1a1f36;
      border: 1px solid rgba(0, 0, 0, 0.1);
      box-shadow: 0 1px 2px rgba(0, 0, 0, 0.05);
    }
    .btn-outline:hover {
      background: rgba(255, 255, 255, 0.9);
      border-color: rgba(0, 0, 0, 0.2);
    }

    /* 统一红色错误提示框（和登录页完全一样） */
    .error-alert {
      background-color: #fef2f2;
      border: 1px solid #fecdd3;
      color: #dc2626;
      padding: 12px 16px;
      border-radius: 10px;
      margin-bottom: 20px;
      font-size: 14px;
      font-weight: 600;
      text-align: center;
    }

    /* 原有 MO 模块样式保留 */
    #mo-modules-section { display: none; }
    .module-row {
      display: flex;
      gap: 8px;
      align-items: center;
      margin-bottom: 8px;
    }
    .module-row input { flex: 1; }
    .remove-module-btn {
      background: none;
      border: 1px solid #fca5a5;
      color: #dc2626;
      border-radius: 6px;
      padding: 5px 11px;
      cursor: pointer;
      font-size: 12px;
      white-space: nowrap;
      font-weight: 500;
    }
    .remove-module-btn:hover {
      background: #fff1f2;
      border-color: #f87171;
    }
    .add-module-btn {
      background: none;
      border: 1px solid #93c5fd;
      color: #2563eb;
      border-radius: 6px;
      padding: 7px 16px;
      cursor: pointer;
      font-size: 13px;
      margin-top: 4px;
      font-weight: 500;
    }
    .add-module-btn:hover {
      background: #eff6ff;
      border-color: #60a5fa;
    }
    .module-hint {
      font-size: 12px;
      color: #94a3b8;
      margin-top: 4px;
    }
  </style>
</head>
<body>
<div class="login-page">
  <div class="login-box">
    <div class="login-header">
      <img src="${pageContext.request.contextPath}/images/logo1.png" class="school-logo" alt="BUPT">
      <h1 class="login-title">Create Account</h1>
    </div>

    <!-- 统一红色错误弹窗（和登录页样式完全一致） -->
    <% String error = (String) request.getAttribute("error"); %>
    <% if (error != null) { %>
      <div class="error-alert"><%= error %></div>
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

      <div class="flex gap-4">
        <button type="submit" class="btn btn-primary flex-1">Register</button>
        <a href="${pageContext.request.contextPath}/login" class="btn btn-outline flex-1">Back to Login</a>
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

(function() {
  var role = document.getElementById('role').value;
  if (role === 'mo') onRoleChange('mo');
})();
</script>
</body>
</html>