<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, java.util.Map" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>User Management - Admin Portal</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
<div class="page-wrapper">
  <header class="site-header">
    <div class="header-inner">
      <div class="header-left">
        <span class="site-title">Admin Portal</span>
        <nav>
          <a href="${pageContext.request.contextPath}/admin" class="nav-link active">User Management</a>
          <a href="${pageContext.request.contextPath}/admin/jobs" class="nav-link">Job Management</a>
          <a href="${pageContext.request.contextPath}/admin/applications" class="nav-link">Application Management</a>
          <a href="${pageContext.request.contextPath}/admin/workload" class="nav-link">Workload Management</a>
        </nav>
      </div>
      <div class="header-right">
        <a href="${pageContext.request.contextPath}/admin/profile" class="btn-icon" title="Profile">
          <svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
            <circle cx="12" cy="8" r="4"/><path d="M4 20c0-4 3.6-7 8-7s8 3 8 7"/>
          </svg>
        </a>
        <a href="${pageContext.request.contextPath}/logout" class="btn btn-outline btn-sm">Logout</a>
      </div>
    </div>
  </header>

  <main class="main-content">
    <div class="content-with-sidebar">
      <div class="content-area">
        <div class="content-header">
          <div style="max-width:900px;margin:0 auto;">
            <h2 class="text-2xl mb-2">User Management</h2>
            <p class="text-gray-600 mb-4">Manage all system users</p>
            <input class="search-input" type="search" id="userSearch"
                   placeholder="Search users by name, email, or role..."
                   oninput="filterUsers(this.value)">
             <div class="filter-group" style="display: flex; flex-direction: column; gap: 8px; align-items: flex-start;">
               <div id="role-filter-row">
                 <button class="btn btn-primary btn-sm" id="role-all" onclick="setRoleFilter('all')">All Users</button>
                 <button class="btn btn-outline btn-sm" id="role-ta" onclick="setRoleFilter('ta')">TA</button>
                 <button class="btn btn-outline btn-sm" id="role-mo" onclick="setRoleFilter('mo')">MO</button>
                 <button class="btn btn-outline btn-sm" id="role-admin" onclick="setRoleFilter('admin')">Admin</button>
               </div>
               <div id="status-filter-row">
                 <button class="btn btn-primary btn-sm" id="status-all" onclick="setStatusFilter('all')">All</button>
                 <button class="btn btn-outline btn-sm" id="status-active" onclick="setStatusFilter('active')">Active</button>
                 <button class="btn btn-outline btn-sm" id="status-inactive" onclick="setStatusFilter('inactive')">Inactive</button>
               </div>
             </div>
          </div>
        </div>

        <div class="content-body">
          <div style="max-width:900px;margin:0 auto;">
            <div class="card" style="padding:0;overflow:hidden;">
              <div class="table-wrapper">
                <table>
                  <thead>
                    <tr>
                      <th>Name</th>
                      <th>Email</th>
                      <th>Role</th>
                      <th>Status</th>
                      <th>Actions</th>
                    </tr>
                  </thead>
                  <tbody id="userTableBody">
                    <%
                      List<Map<String,String>> users = (List<Map<String,String>>) request.getAttribute("users");
                      if (users != null) {
                        for (Map<String,String> user : users) {
                          String status = user.getOrDefault("status","active");
                          String role = user.getOrDefault("role","ta");
                    %>
                    <tr class="user-row" data-role="<%= role %>" data-name="<%= user.get("name").toLowerCase() %>"
                        data-email="<%= user.get("email").toLowerCase() %>"
                        style="<%= "inactive".equals(status) ? "background:#f3f4f6;" : "" %>">
                      <td><%= user.get("name") %></td>
                      <td class="text-gray-600"><%= user.get("email") %></td>
                      <td>
                        <span class="badge badge-outline" style="text-transform:uppercase;font-size:11px;">
                          <%= role.toUpperCase() %>
                        </span>
                      </td>
                      <td>
                        <span class="badge <%= "active".equals(status) ? "badge-active" : "badge-inactive" %>">
                          <%= status.substring(0,1).toUpperCase() + status.substring(1) %>
                        </span>
                      </td>
                      <td>
                        <div style="display:flex;gap:8px;">
                          <% if ("active".equals(status)) { %>
                            <form action="${pageContext.request.contextPath}/admin/users/action" method="post" style="display:inline;">
                              <input type="hidden" name="userId" value="<%= user.get("id") %>">
                              <input type="hidden" name="action" value="deactivate">
                              <button type="submit" class="btn btn-outline-red btn-sm">Deactivate</button>
                            </form>
                          <% } else { %>
                            <form action="${pageContext.request.contextPath}/admin/users/action" method="post" style="display:inline;">
                              <input type="hidden" name="userId" value="<%= user.get("id") %>">
                              <input type="hidden" name="action" value="activate">
                              <button type="submit" class="btn btn-outline-green btn-sm">Activate</button>
                            </form>
                          <% } %>
                        </div>
                      </td>
                    </tr>
                    <%
                        }
                      }
                    %>
                  </tbody>
                </table>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Sidebar -->
      <div class="sidebar">
        <p class="sidebar-title">OVERVIEW</p>
        <div class="stat-card">
          <p class="stat-label">Total Users</p>
          <p class="stat-value">${totalUsers != null ? totalUsers : 8}</p>
        </div>
        <div class="stat-card">
          <p class="stat-label">Teaching Assistants</p>
          <p class="stat-value">${taCount != null ? taCount : 5}</p>
        </div>
        <div class="stat-card">
          <p class="stat-label">Module Organisers</p>
          <p class="stat-value">${moCount != null ? moCount : 2}</p>
        </div>
        <div class="stat-card">
          <p class="stat-label">Admins</p>
          <p class="stat-value">${adminCount != null ? adminCount : 1}</p>
        </div>
      </div>
    </div>
  </main>
</div>

<script>
// 获取当前URL参数
function getQueryParam(name) {
  var url = new URL(window.location.href);
  return url.searchParams.get(name);
}
var currentRole = getQueryParam('role') || 'all';
var currentStatus = getQueryParam('status') || 'all';

function setRoleFilter(role) {
  var status = currentStatus;
  // 保持当前status参数，不自动切换
  var url = new URL(window.location.href);
  url.searchParams.set('role', role);
  url.searchParams.set('status', status);
  window.location.href = url.pathname + '?role=' + role + '&status=' + status;
}
function setStatusFilter(status) {
  var role = currentRole;
  // 允许All Users时也能点状态
  var url = new URL(window.location.href);
  url.searchParams.set('role', role);
  url.searchParams.set('status', status);
  window.location.href = url.pathname + '?role=' + role + '&status=' + status;
}
// 按钮高亮
window.onload = function() {
  // 角色按钮高亮
  ['all','ta','mo','admin'].forEach(function(r){
    var btn = document.getElementById('role-' + r);
    if (btn) btn.className = (currentRole === r ? 'btn btn-primary btn-sm' : 'btn btn-outline btn-sm');
  });
  // 状态按钮高亮
  ['all','active','inactive'].forEach(function(s){
    var btn = document.getElementById('status-' + s);
    if (btn) btn.className = (currentStatus === s ? 'btn btn-primary btn-sm' : 'btn btn-outline btn-sm');
  });
  // 状态按钮始终显示，无需隐藏
};
</script>
</body>
</html>
