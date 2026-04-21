<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Register - TA Recruitment System</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
  <style>
    .login-header {
      position: relative;
      min-height: 40px;
      margin-bottom: 10px;
    }
    .school-logo {
      position: absolute;
      top: -20px;
      left: -15px;
      height: 60px;
      width: auto;
    }
    .login-title {
      padding-top: 45px;
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

    <% String error = (String) request.getAttribute("error"); %>
    <% if (error != null) { %>
      <div style="background:#fef2f2;border:1px solid #fca5a5;color:#b91c1c;padding:10px 14px;border-radius:6px;margin-bottom:16px;font-size:13px;">
        <%= error %>
      </div>
    <% } %>

    <form action="${pageContext.request.contextPath}/register" method="post">

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
        <select class="form-input" id="role" name="role" required>
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
</body>
</html>