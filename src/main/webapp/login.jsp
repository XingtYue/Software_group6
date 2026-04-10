<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Login - TA Recruitment System</title>
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
    <h1 class="login-title">TA Recruitment System</h1>

    <% String error = (String) request.getAttribute("error"); %>
    <% if (error != null) { %>
      <div style="background:#fef2f2;border:1px solid #fca5a5;color:#b91c1c;padding:10px 14px;border-radius:6px;margin-bottom:16px;font-size:13px;">
        <%= error %>
      </div>
    <% } %>
    <% if ("1".equals(request.getParameter("registered"))) { %>
      <div style="background:#f0fdf4;border:1px solid #86efac;color:#15803d;padding:10px 14px;border-radius:6px;margin-bottom:16px;font-size:13px;">
        Account created successfully. Please log in.
      </div>
    <% } %>

    <form action="${pageContext.request.contextPath}/login" method="post">
      <div class="form-group">
        <label class="form-label" for="email">Email</label>
        <input class="form-input" id="email" name="email" type="email"
               placeholder="Enter email" required
               value="${param.email != null ? param.email : ''}">
      </div>

      <div class="form-group">
        <label class="form-label" for="password">Password</label>
        <input class="form-input" id="password" name="password" type="password"
               placeholder="Enter password" required>
      </div>

      <div class="flex gap-4" style="margin-top:8px;">
        <button type="submit" class="btn btn-primary flex-1">Login</button>
        <a href="${pageContext.request.contextPath}/register" class="btn btn-outline flex-1" style="text-align:center;">Register</a>
      </div>
    </form>

    <div class="login-demo">
      <p style="margin-bottom:4px;font-weight:600;">Demo logins:</p>
      <p>ta@example.com / password123 &rarr; TA Dashboard</p>
      <p>mo@example.com / password123 &rarr; Module Organiser</p>
      <p>admin@example.com / password123 &rarr; Admin Dashboard</p>
    </div>
  </div>
</div>
</div>
</body>
</html>
