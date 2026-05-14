<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, java.util.Map" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Edit User - Admin Portal</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
  <style>
    .module-table { width: 100%; border-collapse: collapse; }
    .module-table th, .module-table td { padding: 10px 14px; text-align: left; border-bottom: 1px solid #f3f4f6; font-size: 14px; }
    .module-table th { background: #f8fafc; font-weight: 600; color: #374151; font-size: 13px; }
    .module-table tr:last-child td { border-bottom: none; }
    .module-table tr:hover td { background: #f9fafb; }
    .code-badge { background: #ede9fe; color: #6d28d9; font-size: 12px; font-weight: 600; padding: 2px 8px; border-radius: 4px; }
    .pending-badge { background: #fef3c7; color: #92400e; font-size: 12px; font-weight: 600; padding: 2px 8px; border-radius: 4px; }
    .alert-success { background: #f0fdf4; border: 1px solid #86efac; color: #15803d; padding: 10px 14px; border-radius: 6px; margin-bottom: 16px; font-size: 13px; }
    .alert-error   { background: #fef2f2; border: 1px solid #fca5a5; color: #b91c1c; padding: 10px 14px; border-radius: 6px; margin-bottom: 16px; font-size: 13px; }
  </style>
</head>
<body>
<div class="page-wrapper">
  <%@ include file="adminheader.jsp" %>
  <div class="nav-main-row">
    <a href="${pageContext.request.contextPath}/admin"              class="nav-link active">User Management</a>
    <a href="${pageContext.request.contextPath}/admin/jobs"         class="nav-link">Job Management</a>
    <a href="${pageContext.request.contextPath}/admin/applications" class="nav-link">Application Management</a>
    <a href="${pageContext.request.contextPath}/admin/workload"     class="nav-link">Workload Management</a>
  </div>

  <main class="main-content" style="overflow-y:auto;">
    <div style="max-width:760px;margin:0 auto;padding:24px;">

      <%
        com.ta.recruitment.model.User editUser = (com.ta.recruitment.model.User) request.getAttribute("editUser");
        @SuppressWarnings("unchecked")
        List<Map<String,String>> editUserModules = (List<Map<String,String>>) request.getAttribute("editUserModules");
        @SuppressWarnings("unchecked")
        List<Map<String,String>> editUserPendingModules = (List<Map<String,String>>) request.getAttribute("editUserPendingModules");
        if (editUser == null) { response.sendRedirect(request.getContextPath() + "/admin"); return; }
        String uid      = editUser.getId();
        String uName    = editUser.getName()       != null ? editUser.getName()       : "";
        String uEmail   = editUser.getEmail()      != null ? editUser.getEmail()      : "";
        String uPhone   = editUser.getPhone()      != null ? editUser.getPhone()      : "";
        String uDept    = editUser.getDepartment() != null ? editUser.getDepartment() : "";
        String uRole    = editUser.getRole()       != null ? editUser.getRole()       : "";
        String uStatus  = editUser.getStatus()     != null ? editUser.getStatus()     : "active";
        boolean isMo    = "mo".equals(uRole);
        String baseUrl  = request.getContextPath() + "/admin/users/" + uid + "/edit";

        String successParam = request.getParameter("success");
        String errorParam   = request.getParameter("error");
        String alertTab = null;
        if ("info".equals(successParam)) alertTab = "info";
        else if ("pwd".equals(successParam) || "pwd".equals(errorParam)) alertTab = "security";
        else if ("mod".equals(successParam)) alertTab = "modules";
      %>

      <div style="display:flex;align-items:center;gap:12px;margin-bottom:20px;">
        <a href="${pageContext.request.contextPath}/admin" class="btn btn-outline btn-sm">&larr; Back to User Management</a>
        <h2 class="text-2xl" style="margin:0;">Edit User</h2>
        <span class="badge badge-outline" style="text-transform:uppercase;font-size:11px;"><%= uRole.toUpperCase() %></span>
        <span class="badge <%= "active".equals(uStatus) ? "badge-active" : "badge-inactive" %>">
          <%= uStatus.substring(0,1).toUpperCase() + uStatus.substring(1) %>
        </span>
      </div>

      <!-- Tabs -->
      <div class="tabs-list" id="tabList">
        <button class="tab-btn" id="tab-btn-info"     onclick="showTab('info',this)">Basic Info</button>
        <button class="tab-btn" id="tab-btn-security" onclick="showTab('security',this)">Security</button>
        <% if (isMo) { %>
        <button class="tab-btn" id="tab-btn-modules"  onclick="showTab('modules',this)">Modules
          <span style="background:#ede9fe;color:#6d28d9;font-size:11px;padding:1px 6px;border-radius:10px;margin-left:4px;">
            <%= editUserModules != null ? editUserModules.size() : 0 %>
          </span>
          <% if (editUserPendingModules != null && !editUserPendingModules.isEmpty()) { %>
          <span style="background:#f59e0b;color:#fff;font-size:11px;padding:1px 6px;border-radius:10px;margin-left:2px;">
            <%= editUserPendingModules.size() %> pending
          </span>
          <% } %>
        </button>
        <% } %>
      </div>

      <!-- ===== Basic Info Tab ===== -->
      <div id="tab-info" class="tab-content">
        <% if ("info".equals(successParam)) { %>
          <div class="alert-success">Profile information saved successfully.</div>
        <% } %>
        <div class="card" style="padding:20px;">
          <h3 class="text-lg mb-4">Profile Information</h3>
          <form action="<%= baseUrl %>" method="post">
            <input type="hidden" name="action" value="saveInfo">
            <div class="form-group">
              <label class="form-label">Full Name <span style="color:#b91c1c;">*</span></label>
              <input class="form-input" name="name" type="text" value="<%= uName %>" required>
            </div>
            <div class="form-group">
              <label class="form-label">Email Address <span style="color:#b91c1c;">*</span></label>
              <input class="form-input" name="email" type="email" value="<%= uEmail %>" required>
              <p style="font-size:12px;color:#6b7280;margin-top:4px;">Changing email will affect the user's login credentials.</p>
            </div>
            <div class="form-grid-2">
              <div class="form-group">
                <label class="form-label">Phone Number</label>
                <input class="form-input" name="phone" type="tel" value="<%= uPhone %>">
              </div>
              <div class="form-group">
                <label class="form-label">Department</label>
                <input class="form-input" name="department" type="text" value="<%= uDept %>">
              </div>
            </div>
            <div class="form-group">
              <label class="form-label">Role</label>
              <input class="form-input" type="text" value="<%= uRole.toUpperCase() %>" disabled>
            </div>
            <button type="submit" class="btn btn-primary btn-sm">Save Changes</button>
          </form>
        </div>
      </div>

      <!-- ===== Security Tab ===== -->
      <div id="tab-security" class="tab-content">
        <% if ("pwd".equals(successParam)) { %>
          <div class="alert-success">Password updated successfully.</div>
        <% } else if ("pwd".equals(errorParam)) { %>
          <div class="alert-error">Password update failed. Make sure the new password is at least 4 characters and both fields match.</div>
        <% } %>
        <div class="card" style="padding:20px;">
          <h3 class="text-lg mb-4">Reset Password</h3>
          <p class="text-sm text-gray-600 mb-4">As an administrator you can set a new password for this user directly without requiring the current password.</p>
          <form action="<%= baseUrl %>" method="post">
            <input type="hidden" name="action" value="changePassword">
            <div class="form-group">
              <label class="form-label">New Password <span style="color:#b91c1c;">*</span></label>
              <input class="form-input" name="newPassword" type="password" minlength="4" required>
            </div>
            <div class="form-group">
              <label class="form-label">Confirm New Password <span style="color:#b91c1c;">*</span></label>
              <input class="form-input" name="confirmPassword" type="password" required>
            </div>
            <button type="submit" class="btn btn-primary btn-sm"
                    onclick="return confirm('Reset password for <%= uName %>?')">Reset Password</button>
          </form>
        </div>
      </div>

      <!-- ===== Modules Tab (MO only) ===== -->
      <% if (isMo) { %>
      <div id="tab-modules" class="tab-content">
        <% if ("mod".equals(successParam)) { %>
          <div class="alert-success">Module changes saved successfully.</div>
        <% } %>

        <!-- Pending Approval -->
        <% if (editUserPendingModules != null && !editUserPendingModules.isEmpty()) { %>
        <div class="card" style="padding:0;overflow:hidden;margin-bottom:24px;border-color:#fde68a;">
          <div style="padding:16px 20px;border-bottom:1px solid #fde68a;display:flex;justify-content:space-between;align-items:center;background:#fffbeb;">
            <span style="font-weight:600;font-size:15px;color:#92400e;">&#9888; Pending Approval</span>
            <div style="display:flex;gap:8px;align-items:center;">
              <span style="font-size:13px;color:#92400e;"><%= editUserPendingModules.size() %> module(s) awaiting review</span>
              <form action="<%= baseUrl %>" method="post" style="display:inline;">
                <input type="hidden" name="action" value="approvePendingModules">
                <button type="submit" class="btn btn-outline-green btn-sm">Approve All</button>
              </form>
              <form action="<%= baseUrl %>" method="post" style="display:inline;">
                <input type="hidden" name="action" value="rejectPendingModules">
                <button type="submit" class="btn btn-outline-red btn-sm"
                        onclick="return confirm('Reject all pending modules?')">Reject All</button>
              </form>
            </div>
          </div>
          <table class="module-table">
            <thead><tr><th>Course Code</th><th>Course Name</th><th style="width:160px;"></th></tr></thead>
            <tbody>
            <% for (Map<String,String> mod : editUserPendingModules) { %>
            <tr>
              <td><span class="pending-badge"><%= mod.get("code") %></span></td>
              <td><%= mod.get("name") %></td>
              <td>
                <div style="display:flex;gap:6px;">
                  <form action="<%= baseUrl %>" method="post" style="display:inline;">
                    <input type="hidden" name="action" value="approvePendingModule">
                    <input type="hidden" name="courseCode" value="<%= mod.get("code") %>">
                    <button type="submit" class="btn btn-outline-green btn-sm">Approve</button>
                  </form>
                  <form action="<%= baseUrl %>" method="post" style="display:inline;">
                    <input type="hidden" name="action" value="rejectPendingModule">
                    <input type="hidden" name="courseCode" value="<%= mod.get("code") %>">
                    <button type="submit" class="btn btn-outline-red btn-sm"
                            onclick="return confirm('Reject <%= mod.get("code") %>?')">Reject</button>
                  </form>
                </div>
              </td>
            </tr>
            <% } %>
            </tbody>
          </table>
        </div>
        <% } %>

        <!-- Current modules -->
        <div class="card" style="padding:0;overflow:hidden;margin-bottom:24px;">
          <div style="padding:16px 20px;border-bottom:1px solid #e5e7eb;display:flex;justify-content:space-between;align-items:center;">
            <span style="font-weight:600;font-size:15px;">Assigned Modules</span>
            <span style="font-size:13px;color:#6b7280;"><%= editUserModules != null ? editUserModules.size() : 0 %> module(s)</span>
          </div>
          <% if (editUserModules == null || editUserModules.isEmpty()) { %>
          <div style="padding:32px;text-align:center;color:#9ca3af;font-style:italic;">No modules assigned yet.</div>
          <% } else { %>
          <table class="module-table">
            <thead><tr><th>Course Code</th><th>Course Name</th><th style="width:80px;"></th></tr></thead>
            <tbody>
            <% for (Map<String,String> mod : editUserModules) { %>
            <tr>
              <td><span class="code-badge"><%= mod.get("code") %></span></td>
              <td><%= mod.get("name") %></td>
              <td>
                <form action="<%= baseUrl %>" method="post" style="display:inline;">
                  <input type="hidden" name="action" value="removeModule">
                  <input type="hidden" name="courseCode" value="<%= mod.get("code") %>">
                  <button type="submit" class="btn btn-outline-red btn-sm"
                          onclick="return confirm('Remove <%= mod.get("code") %>?')">Remove</button>
                </form>
              </td>
            </tr>
            <% } %>
            </tbody>
          </table>
          <% } %>
        </div>

        <!-- Add new module -->
        <div class="card card-p8">
          <h3 style="font-size:15px;font-weight:600;margin-bottom:16px;">Add New Module</h3>
          <form action="<%= baseUrl %>" method="post">
            <input type="hidden" name="action" value="addModule">
            <div class="form-grid-2">
              <div class="form-group">
                <label class="form-label" for="courseCode">Course Code <span style="color:#b91c1c;">*</span></label>
                <input class="form-input" id="courseCode" name="courseCode" type="text"
                       placeholder="e.g. EBU6304" required>
              </div>
              <div class="form-group">
                <label class="form-label" for="courseName">Course Name</label>
                <input class="form-input" id="courseName" name="courseName" type="text"
                       placeholder="e.g. Software Engineering">
              </div>
            </div>
            <button type="submit" class="btn btn-primary">Add Module</button>
          </form>
        </div>
      </div>
      <% } %>

    </div>
  </main>
</div>

<script>
  var initialTab = '<%= alertTab != null ? alertTab : "info" %>';
  var isMo = <%= isMo %>;

  function showTab(name, btn) {
    document.querySelectorAll('.tab-content').forEach(function(el) { el.classList.remove('active'); });
    document.querySelectorAll('.tab-btn').forEach(function(el) { el.classList.remove('active'); });
    var content = document.getElementById('tab-' + name);
    if (content) content.classList.add('active');
    if (btn) btn.classList.add('active');
  }

  window.onload = function() {
    var initBtn = document.getElementById('tab-btn-' + initialTab);
    showTab(initialTab, initBtn);
  };
</script>
</body>
</html>
