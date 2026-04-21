<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, java.util.Map" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>User Management - Admin Portal</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
  <style>
    .modal-overlay {
      display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%;
      background: rgba(0,0,0,0.5); z-index: 1000;
      align-items: flex-start; justify-content: center;
      padding: 40px 16px; box-sizing: border-box; overflow-y: auto;
    }
    .modal-overlay.active { display: flex; }
    .modal-box {
      background: #fff; border-radius: 8px; padding: 28px;
      max-width: 640px; width: 100%; position: relative;
      max-height: 80vh; overflow-y: auto; box-shadow: 0 20px 60px rgba(0,0,0,0.3);
    }
    .modal-close {
      position: absolute; top: 12px; right: 16px; font-size: 24px;
      cursor: pointer; color: #6b7280; border: none; background: none; line-height: 1;
    }
    .modal-title { font-size: 18px; font-weight: 600; margin-bottom: 16px; color: #111827; }
    .modal-section { margin-top: 16px; padding-top: 16px; border-top: 1px solid #e5e7eb; }
    .modal-section-title { font-size: 13px; font-weight: 600; color: #374151; margin-bottom: 8px; text-transform: uppercase; letter-spacing: 0.05em; }
    .info-grid { display: grid; grid-template-columns: 110px 1fr; gap: 5px 12px; }
    .info-label { font-size: 13px; color: #9ca3af; }
    .info-value { font-size: 13px; color: #111827; word-break: break-word; }
    .cover-letter-empty { font-size: 13px; color: #9ca3af; font-style: italic; }
  </style>
</head>
<%!
  private String jsEsc(String s) {
    if (s == null) return "";
    return s.replace("\\", "\\\\")
            .replace("\"", "\\\"")
            .replace("\n", "\\n")
            .replace("\r", "")
            .replace("<", "\\u003C")
            .replace(">", "\\u003E");
  }
%>
<body>
<div class="page-wrapper">
  <%@ include file="adminheader.jsp" %>
  <div class="nav-main-row">
    <a href="${pageContext.request.contextPath}/admin" class="nav-link active">User Management</a>
    <a href="${pageContext.request.contextPath}/admin/jobs" class="nav-link">Job Management</a>
    <a href="${pageContext.request.contextPath}/admin/applications" class="nav-link">Application Management</a>
    <a href="${pageContext.request.contextPath}/admin/workload" class="nav-link">Workload Management</a>
  </div>
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
                  <tr class="user-row" data-role="<%= role.toLowerCase() %>" data-name="<%= user.getOrDefault("name","").toLowerCase() %>"
                      data-email="<%= user.getOrDefault("email","").toLowerCase() %>" data-status="<%= status.toLowerCase() %>"
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
                      <div style="display:flex;gap:8px;flex-wrap:wrap;">
                        <button type="button" class="btn btn-outline btn-sm"
                                onclick="showUserDetails('<%= user.get("id") %>')">View Details</button>
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

<!-- 弹窗结构 100% 对齐你的申请管理页面 -->
<div id="modal-overlay" class="modal-overlay" onclick="if(event.target===this)closeModal()">
  <div class="modal-box">
    <button class="modal-close" onclick="closeModal()">&times;</button>
    <h3 class="modal-title" id="modal-user-name"></h3>

    <div class="info-grid">
      <span class="info-label">Email</span>      <span class="info-value" id="modal-user-email"></span>
      <span class="info-label">Role</span>       <span class="info-value" id="modal-user-role"></span>
      <span class="info-label">Status</span>     <span class="info-value" id="modal-user-status"></span>
      <span class="info-label">Department</span> <span class="info-value" id="modal-user-dept"></span>
      <span class="info-label">Phone</span>      <span class="info-value" id="modal-user-phone"></span>
    </div>

    <!-- CV 区域：和申请页面完全一样 -->
    <div class="modal-section" id="modal-cv-section">
      <p class="modal-section-title">CV / Resume</p>
      <a id="modal-cv-link" href="#" target="_blank" class="btn btn-outline btn-sm">
        View / Download CV
      </a>
    </div>
    <div class="modal-section" id="modal-no-cv-section" style="display:none;">
      <p class="modal-section-title">CV / Resume</p>
      <p class="cover-letter-empty">No CV uploaded for this user.</p>
    </div>
  </div>
</div>

<script>
  var ctxPath = "${pageContext.request.contextPath}";

  function getQueryParam(name) {
    var url = new URL(window.location.href);
    return url.searchParams.get(name);
  }
  var currentRole = getQueryParam('role') || 'all';
  var currentStatus = getQueryParam('status') || 'all';

  function setRoleFilter(role) {
    var status = currentStatus;
    var url = new URL(window.location.href);
    url.searchParams.set('role', role);
    url.searchParams.set('status', status);
    window.location.href = url.pathname + '?role=' + role + '&status=' + status;
  }
  function setStatusFilter(status) {
    var role = currentRole;
    var url = new URL(window.location.href);
    url.searchParams.set('role', role);
    url.searchParams.set('status', status);
    window.location.href = url.pathname + '?role=' + role + '&status=' + status;
  }
  function filterUsers(query) {
    var q = (query || '').toLowerCase();
    document.querySelectorAll('.user-row').forEach(function(row) {
      var matchQuery = !q || row.dataset.name.includes(q) || row.dataset.email.includes(q) || row.dataset.role.includes(q);
      row.style.display = matchQuery ? '' : 'none';
    });
  }

  window.onload = function() {
    ['all','ta','mo','admin'].forEach(function(r){
      var btn = document.getElementById('role-' + r);
      if (btn) btn.className = (currentRole === r ? 'btn btn-primary btn-sm' : 'btn btn-outline btn-sm');
    });
    ['all','active','inactive'].forEach(function(s){
      var btn = document.getElementById('status-' + s);
      if (btn) btn.className = (currentStatus === s ? 'btn btn-primary btn-sm' : 'btn btn-outline btn-sm');
    });
  };

  var userDetails = {
    <%
      if (users != null) {
        for (int i = 0; i < users.size(); i++) {
          Map<String,String> user = users.get(i);
          String userId = user.get("id");
          if (userId == null) userId = "";
    %>
    "<%= userId %>": {
      name: "<%= jsEsc(user.get("name")) %>",
      email: "<%= jsEsc(user.get("email")) %>",
      role: "<%= jsEsc(user.getOrDefault("role", "")) %>",
      status: "<%= jsEsc(user.getOrDefault("status", "")) %>",
      department: "<%= jsEsc(user.getOrDefault("department", "")) %>",
      phone: "<%= jsEsc(user.getOrDefault("phone", "")) %>",
      cvFileName: "<%= jsEsc(user.getOrDefault("cvFileName", "")) %>"
    }<%= i < users.size() - 1 ? "," : "" %>
    <%
        }
      }
    %>
  };

  function capitalize(value) {
    if (!value) return 'N/A';
    return value.charAt(0).toUpperCase() + value.slice(1);
  }

  // JS 逻辑 100% 对齐你的参考页面
  function showUserDetails(userId) {
    var d = userDetails[userId];
    if (!d) return;

    document.getElementById('modal-user-name').textContent = d.name || '(No name)';
    document.getElementById('modal-user-email').textContent = d.email || 'N/A';
    document.getElementById('modal-user-role').textContent = d.role ? d.role.toUpperCase() : 'N/A';
    document.getElementById('modal-user-status').textContent = capitalize(d.status);
    document.getElementById('modal-user-dept').textContent = d.department || 'N/A';
    document.getElementById('modal-user-phone').textContent = d.phone || 'N/A';

    // CV 显示/隐藏逻辑（和申请页面完全一样）
    if (d.cvFileName) {
      document.getElementById('modal-cv-section').style.display = '';
      document.getElementById('modal-no-cv-section').style.display = 'none';
      document.getElementById('modal-cv-link').href = ctxPath + '/admin/cv/download?userId=' + encodeURIComponent(userId);
    } else {
      document.getElementById('modal-cv-section').style.display = 'none';
      document.getElementById('modal-no-cv-section').style.display = '';
    }

    document.getElementById('modal-overlay').classList.add('active');
  }

  function closeModal() {
    document.getElementById('modal-overlay').classList.remove('active');
  }
</script>
</body>
</html>