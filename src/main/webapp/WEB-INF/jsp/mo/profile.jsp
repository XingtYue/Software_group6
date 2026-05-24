<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.Map, java.util.List" %>
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

        @SuppressWarnings("unchecked")
        List<Map<String,String>> moModules = (List<Map<String,String>>) request.getAttribute("moModules");
        @SuppressWarnings("unchecked")
        List<Map<String,String>> moPendingModules = (List<Map<String,String>>) request.getAttribute("moPendingModules");
      %>

      <h2 class="text-2xl mb-2">Profile Management</h2>
      <p class="text-sm text-gray-600" style="margin-bottom:20px;">Role: Module Organiser</p>

      <% if (success != null) { %>
        <div class="alert alert-success"><%= success %></div>
      <% } %>
      <% if (error != null) { %>
        <div class="alert alert-error"><%= error %></div>
      <% } %>

      <!-- Tabs -->
      <div class="tabs-list">
        <button class="tab-btn active" id="tab-btn-profile"   onclick="showTab('profile',this)">Profile</button>
        <button class="tab-btn"        id="tab-btn-modules"   onclick="showTab('modules',this)">My Modules
          <% if (moPendingModules != null && !moPendingModules.isEmpty()) { %>
          <span style="background:#f59e0b;color:#fff;font-size:11px;padding:1px 6px;border-radius:10px;margin-left:4px;">
            <%= moPendingModules.size() %> pending
          </span>
          <% } %>
        </button>
        <button class="tab-btn"        id="tab-btn-settings"  onclick="showTab('settings',this)">Settings</button>
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

      <!-- Modules Tab -->
      <div id="tab-modules" class="tab-content">

        <%-- Pending requests (awaiting admin approval) --%>
        <% if (moPendingModules != null && !moPendingModules.isEmpty()) { %>
        <div class="card" style="padding:0;overflow:hidden;margin-bottom:20px;border-color:#fde68a;">
          <div style="padding:14px 18px;background:#fffbeb;border-bottom:1px solid #fde68a;">
            <span style="font-weight:600;font-size:14px;color:#92400e;">&#9203; Pending Admin Approval</span>
            <span style="font-size:12px;color:#92400e;margin-left:8px;"><%= moPendingModules.size() %> module(s) awaiting review</span>
          </div>
          <div style="padding:12px 18px;">
            <% for (Map<String,String> mod : moPendingModules) { %>
            <div style="display:flex;align-items:center;justify-content:space-between;padding:8px 0;border-bottom:1px solid #fef3c7;">
              <div>
                <span style="background:#fef3c7;color:#92400e;font-size:12px;font-weight:600;padding:2px 8px;border-radius:4px;margin-right:8px;">
                  <%= mod.get("code") %>
                </span>
                <span style="font-size:13px;color:#374151;"><%= mod.get("name") %></span>
              </div>
              <form action="${pageContext.request.contextPath}/mo/profile" method="post" style="display:inline;">
                <input type="hidden" name="action" value="cancelModuleRequest">
                <input type="hidden" name="courseCode" value="<%= mod.get("code") %>">
                <button type="submit" class="btn btn-outline-red btn-sm"
                        onclick="return confirm('Cancel request for <%= mod.get("code") %>?')">Cancel</button>
              </form>
            </div>
            <% } %>
          </div>
        </div>
        <% } %>

        <%-- Approved modules --%>
        <div class="card" style="padding:0;overflow:hidden;margin-bottom:20px;">
          <div style="padding:14px 18px;border-bottom:1px solid #e5e7eb;display:flex;justify-content:space-between;align-items:center;">
            <span style="font-weight:600;font-size:14px;">Assigned Modules</span>
            <span style="font-size:13px;color:#6b7280;"><%= moModules != null ? moModules.size() : 0 %> module(s)</span>
          </div>
          <% if (moModules == null || moModules.isEmpty()) { %>
          <div style="padding:28px;text-align:center;color:#9ca3af;font-style:italic;font-size:13px;">
            No modules assigned yet. Submit a request below.
          </div>
          <% } else { %>
          <div style="padding:12px 18px;">
            <% for (Map<String,String> mod : moModules) { %>
            <div style="display:flex;align-items:center;gap:8px;padding:8px 0;border-bottom:1px solid #f3f4f6;">
              <span style="background:#ede9fe;color:#6d28d9;font-size:12px;font-weight:600;padding:2px 8px;border-radius:4px;">
                <%= mod.get("code") %>
              </span>
              <span style="font-size:13px;color:#374151;"><%= mod.get("name") %></span>
            </div>
            <% } %>
          </div>
          <% } %>
        </div>

        <%-- Request new module --%>
        <div class="card" style="padding:20px;">
          <h3 class="text-lg mb-2">Request New Module</h3>
          <p style="font-size:13px;color:#6b7280;margin-bottom:16px;">
            Submit a request to be assigned a module. An admin will review and approve it.
          </p>
          <form action="${pageContext.request.contextPath}/mo/profile" method="post">
            <input type="hidden" name="action" value="requestModule">
            <div class="form-grid-2">
              <div class="form-group">
                <label class="form-label">Course Code <span style="color:#b91c1c;">*</span></label>
                <input class="form-input" name="courseCode" type="text"
                       placeholder="e.g. EBU6304" required>
              </div>
              <div class="form-group">
                <label class="form-label">Course Name</label>
                <input class="form-input" name="courseName" type="text"
                       placeholder="e.g. Software Engineering">
              </div>
            </div>
            <button type="submit" class="btn btn-primary btn-sm">Submit Request</button>
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
var initialTab = '<%= request.getAttribute("activeTab") != null ? request.getAttribute("activeTab") : "profile" %>';

function showTab(name, btn) {
  document.querySelectorAll('.tab-content').forEach(function(el){ el.classList.remove('active'); });
  document.querySelectorAll('.tab-btn').forEach(function(el){ el.classList.remove('active'); });
  document.getElementById('tab-' + name).classList.add('active');
  if (btn) btn.classList.add('active');
}

window.onload = function() {
  var btn = document.getElementById('tab-btn-' + initialTab);
  showTab(initialTab, btn);
};
</script>
</body>
</html>