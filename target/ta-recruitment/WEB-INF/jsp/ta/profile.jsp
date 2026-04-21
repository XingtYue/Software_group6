<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.Map" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Profile - TA Portal</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
<div class="page-wrapper">
  <%@ include file="taheader.jsp" %>
  <div class="nav-main-row">
    <a href="${pageContext.request.contextPath}/ta/jobs" class="nav-link">Browse Jobs</a>
    <a href="${pageContext.request.contextPath}/ta/applications" class="nav-link">My Applications</a>
    <a href="${pageContext.request.contextPath}/ta/profile" class="nav-link active">Profile</a>
  </div>

  <main class="main-content" style="overflow-y:auto;">
    <div style="max-width:720px;margin:0 auto;padding:24px;">

      <%
        Map<String,String> user = (Map<String,String>) request.getAttribute("user");
        String uName  = user != null ? user.getOrDefault("name","") : "";
        String uEmail = user != null ? user.getOrDefault("email","") : "";
        String uPhone = user != null ? user.getOrDefault("phone","") : "";
        String uDept  = user != null ? user.getOrDefault("department","") : "";
        String uCv    = user != null ? user.getOrDefault("cvFileName","") : "";
        String success = (String) request.getAttribute("success");
        String error   = (String) request.getAttribute("error");
      %>

      <h2 class="text-2xl mb-2">Profile Management</h2>
      <p class="text-sm text-gray-600" style="margin-bottom:20px;">Role: Teaching Assistant</p>

      <% if (success != null) { %>
        <div style="background:#f0fdf4;border:1px solid #86efac;color:#15803d;padding:10px 14px;border-radius:6px;margin-bottom:16px;font-size:13px;"><%= success %></div>
      <% } %>
      <% if (error != null) { %>
        <div style="background:#fef2f2;border:1px solid #fca5a5;color:#b91c1c;padding:10px 14px;border-radius:6px;margin-bottom:16px;font-size:13px;"><%= error %></div>
      <% } %>

      <!-- Tabs -->
      <div class="tabs-list">
        <button class="tab-btn active" onclick="showTab('profile',this)">Profile</button>
        <button class="tab-btn" onclick="showTab('cv',this)">CV</button>
        <button class="tab-btn" onclick="showTab('settings',this)">Settings</button>
      </div>

      <!-- Profile Tab -->
      <div id="tab-profile" class="tab-content active">
        <div class="card" style="padding:20px;">
          <h3 class="text-lg mb-4">Profile Information</h3>
          <form action="${pageContext.request.contextPath}/ta/profile" method="post">
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
              <input class="form-input" type="text" value="Teaching Assistant" disabled>
            </div>
            <button type="submit" class="btn btn-primary btn-sm">Save Profile</button>
          </form>
        </div>
      </div>

      <!-- CV Tab -->
      <div id="tab-cv" class="tab-content">
        <div class="card" style="padding:20px;">
          <h3 class="text-lg mb-4">CV Management</h3>

          <% if (uCv != null && !uCv.isEmpty()) { %>
          <div class="form-group">
            <label class="form-label">Current CV</label>
            <div style="margin-top:6px;padding:12px;border:1px solid #d1d5db;border-radius:6px;display:flex;justify-content:space-between;align-items:center;background:#f9fafb;">
              <span style="font-size:13px;color:#374151;">&#128196; <%= uCv %></span>
              <a href="${pageContext.request.contextPath}/ta/cv/download" class="btn btn-outline btn-sm">Download</a>
            </div>
          </div>
          <div class="form-group">
            <label class="form-label">Replace CV</label>
            <form action="${pageContext.request.contextPath}/ta/profile" method="post" enctype="multipart/form-data">
              <input type="hidden" name="action" value="uploadCV">
              <div class="upload-area" style="margin-top:6px;">
                <div class="upload-icon">&#128196;</div>
                <input name="cvFile" type="file" accept=".pdf,.doc,.docx"
                       style="display:block;width:100%;font-size:12px;color:#4b5563;margin-top:8px;">
                <p style="font-size:12px;color:#9ca3af;margin-top:4px;">PDF, DOC or DOCX</p>
              </div>
              <button type="submit" class="btn btn-primary btn-sm" style="margin-top:12px;">Upload and Replace CV</button>
            </form>
          </div>
          <% } else { %>
          <div class="form-group">
            <p style="font-size:13px;color:#6b7280;margin-bottom:12px;">No CV uploaded yet. Please upload your CV.</p>
            <form action="${pageContext.request.contextPath}/ta/profile" method="post" enctype="multipart/form-data">
              <input type="hidden" name="action" value="uploadCV">
              <div class="upload-area">
                <div class="upload-icon">&#128196;</div>
                <input name="cvFile" type="file" accept=".pdf,.doc,.docx"
                       style="display:block;width:100%;font-size:12px;color:#4b5563;margin-top:8px;">
                <p style="font-size:12px;color:#9ca3af;margin-top:4px;">PDF, DOC or DOCX</p>
              </div>
              <button type="submit" class="btn btn-primary btn-sm" style="margin-top:12px;">Upload CV</button>
            </form>
          </div>
          <% } %>
        </div>
      </div>

      <!-- Settings Tab -->
      <div id="tab-settings" class="tab-content">
        <div class="card" style="padding:20px;">
          <h3 class="text-lg mb-4">Account Settings</h3>
          <h4 style="font-size:13px;font-weight:500;margin-bottom:12px;">Change Password</h4>
          <form action="${pageContext.request.contextPath}/ta/profile" method="post">
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