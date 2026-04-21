<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.Map" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Profile - MO Portal</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
<div class="page-wrapper">
  <%@ include file="moheader.jsp" %>
  <div class="nav-main-row">
    <a href="${pageContext.request.contextPath}/mo/applicants" class="nav-link">Applicants</a>
    <a href="${pageContext.request.contextPath}/mo/post-job" class="nav-link">Post Job</a>
    <a href="${pageContext.request.contextPath}/mo/profile" class="nav-link active">Profile</a>
  </div>

  <main class="main-content" style="overflow-y:auto;">
    <div style="max-width:720px;margin:0 auto;padding:24px;">

      <%
        Map<String,String> user = (Map<String,String>) request.getAttribute("user");
        String uName  = user != null ? user.getOrDefault("name","") : "";
        String uEmail = user != null ? user.getOrDefault("email","") : "";
        String uPhone = user != null ? user.getOrDefault("phone","") : "";
        String uDept  = user != null ? user.getOrDefault("department","") : "";
        String success = (String) request.getAttribute("success");
        String error   = (String) request.getAttribute("error");
      %>

      <h2 class="text-2xl mb-2">Profile Management</h2>
      <p class="text-sm text-gray-600" style="margin-bottom:20px;">Role: Module Organiser</p>

      <% if (success != null) { %>
        <div style="background:#f0fdf4;border:1px solid #86efac;color:#15803d;padding:10px 14px;border-radius:6px;margin-bottom:16px;font-size:13px;"><%= success %></div>
      <% } %>
      <% if (error != null) { %>
        <div style="background:#fef2f2;border:1px solid #fca5a5;color:#b91c1c;padding:10px 14px;border-radius:6px;margin-bottom:16px;font-size:13px;"><%= error %></div>
      <% } %>

      <!-- Tabs -->
      <div class="tabs-list">
        <button class="tab-btn active" onclick="showTab('profile',this)">Profile</button>
        <button class="tab-btn" onclick="showTab('settings',this)">Settings</button>
      </div>

      <!-- Profile Tab -->
      <div id="tab-profile" class="tab-content active">
        <div class="card" style="padding:20px;">
          <h3 class="text-lg mb-4">Profile Information</h3>
          <form action="${pageContext.request.contextPath}/mo/profile" method="post">
            <input type="hidden" name="action" value="saveProfile">
            <div class="form-group">
              <label class="form-label">Full Name</label>
              <input class="form-input" name="name" type="text" value="<%= uName %>">
            </div>
            <div class="form-group">
              <label class="form-label">Email Address</label>
              <input class="form-input" type="email" value="<%= uEmail %>" disabled>
            </div>
            <div class="form-group">
              <label class="form-label">Phone Number</label>
              <input class="form-input" name="phone" type="tel" value="<%= uPhone %>">
            </div>
            <div class="form-group">
              <label class="form-label">Department</label>
              <input class="form-input" name="department" type="text" value="<%= uDept %>">
            </div>
            <div class="form-group">
              <label class="form-label">Role</label>
              <input class="form-input" type="text" value="Module Organiser" disabled>
            </div>
            <button type="submit" class="btn btn-primary btn-sm">Save Profile</button>
          </form>
        </div>
      </div>

      <!-- Settings Tab -->
      <div id="tab-settings" class="tab-content">
        <div class="card" style="padding:20px;">
          <h3 class="text-lg mb-4">Account Settings</h3>
          <h4 style="font-size:13px;font-weight:500;margin-bottom:12px;">Change Password</h4>
          <form action="${pageContext.request.contextPath}/mo/profile" method="post">
            <input type="hidden" name="action" value="changePassword">
            <div class="form-group">
              <label class="form-label">Current Password</label>
              <input class="form-input" name="oldPassword" type="password">
            </div>
            <div class="form-group">
              <label class="form-label">New Password</label>
              <input class="form-input" name="newPassword" type="password">
            </div>
            <div class="form-group">
              <label class="form-label">Confirm New Password</label>
              <input class="form-input" name="confirmPassword" type="password">
            </div>
            <button type="submit" class="btn btn-primary btn-sm">Update Password</button>
          </form>
        </div>
      </div>

    </div>
  </main>
</div>
<script>
function showTab(name, btn) {
  document.querySelectorAll('.tab-content').forEach(function(el){ el.classList.remove('active'); });
  document.querySelectorAll('.tab-btn').forEach(function(el){ el.classList.remove('active'); });
  document.getElementById('tab-' + name).classList.add('active');
  btn.classList.add('active');
}
</script>
</body>
</html>