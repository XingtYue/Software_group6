<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, java.util.Map" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Workload Management - Admin Portal</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
<div class="page-wrapper">
 <%@ include file="adminheader.jsp" %>
 <div class="nav-main-row">
   <a href="${pageContext.request.contextPath}/admin" class="nav-link">User Management</a>
   <a href="${pageContext.request.contextPath}/admin/jobs" class="nav-link">Job Management</a>
   <a href="${pageContext.request.contextPath}/admin/applications" class="nav-link">Application Management</a>
   <a href="${pageContext.request.contextPath}/admin/workload" class="nav-link active">Workload Management</a>
 </div>
  <main class="main-content">
    <div class="content-with-sidebar">
      <div class="content-area">
        <div class="content-header">
          <div style="max-width:900px;margin:0 auto;">
            <h2 class="text-2xl mb-2">Workload Management</h2>
            <p class="text-gray-600">Monitor TA workload and hours</p>
          </div>
        </div>

        <div class="content-body">
          <div style="max-width:900px;margin:0 auto;">
            <div class="card" style="padding:0;overflow:hidden;">
              <div class="table-wrapper">
                <table>
                  <thead>
                    <tr>
                      <th>TA Name</th>
                      <th>Accepted Positions</th>
                      <th>Total Hours (hrs/wk × weeks)</th>
                      <th>Workload Status</th>
                      <th>Action</th>
                    </tr>
                  </thead>
                  <tbody>
                    <%
                      List<Map<String,String>> workloads = (List<Map<String,String>>) request.getAttribute("workloads");
                      if (workloads != null) {
                        for (Map<String,String> wl : workloads) {
                          int hours = 0;
                          try { hours = Integer.parseInt(wl.getOrDefault("totalHours","0")); } catch(Exception e){}
                          // 阈值：总工时 > 270h(超负荷), > 108h(正常), 否则轻负荷
                          String wlStatus = hours > 270 ? "Overloaded" : hours > 108 ? "Normal" : "Light";
                          String wlClass  = hours > 270 ? "badge-rejected" : hours > 108 ? "badge-accepted" : "badge-pending";
                          boolean isInactive = "inactive".equals(wl.get("status"));
                    %>

                    <tr style="<%= isInactive ? "opacity:0.5; background:#f9f9f9;" : "" %>">
                      <td><%= wl.getOrDefault("name","Unknown") %></td>
                      <td style="text-align:center;"><%= wl.getOrDefault("positions","0") %></td>
                      <td>
                        <div style="display:flex;align-items:center;gap:10px;">
                          <div class="progress-bar-track" style="flex:1;">
                            <div class="progress-bar-fill <%= hours > 15 ? "red" : hours > 8 ? "green" : "blue" %>"
                                 style="width:<%= Math.min(hours * 5, 100) %>%;"></div>
                          </div>
                          <span style="font-size:13px;font-weight:600;color:#334155;min-width:36px;"><%= hours %>h</span>
                        </div>
                      </td>
                      <td><span class="badge <%= wlClass %>"><%= wlStatus %></span></td>
                      <td>
                        <% if (!isInactive) { %>
                          <a href="${pageContext.request.contextPath}/admin/workload/edit/<%= wl.get("id") %>" class="btn btn-outline btn-sm">
                            Edit Workload
                          </a>
                        <% } else { %>
                          <button class="btn btn-outline btn-sm" disabled>Edit Disabled</button>
                        <% } %>
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
        <p class="sidebar-title">WORKLOAD SUMMARY</p>
        <div class="stat-card">
          <p class="stat-label">Total TAs</p>
          <p class="stat-value">${totalTAs}</p>
        </div>
        <div class="stat-card green">
          <p class="stat-label">Normal Workload</p>
          <p class="stat-value green">${normalCount}</p>
        </div>
        <div class="stat-card red">
          <p class="stat-label">Overloaded</p>
          <p class="stat-value red">${overloadedCount}</p>
        </div>
        <div class="stat-card blue">
          <p class="stat-label">Light Workload</p>
          <p class="stat-value blue">${lightCount}</p>
        </div>
      </div>
    </div>
  </main>
</div>
</body>
</html>