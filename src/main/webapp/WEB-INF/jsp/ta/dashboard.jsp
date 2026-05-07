<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>TA Dashboard - TA Recruitment System</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
<div class="page-wrapper">
  <%@ include file="taheader.jsp" %>

  <div class="nav-main-row">
    <a href="${pageContext.request.contextPath}/ta/jobs"         class="nav-link">Browse Jobs</a>
    <a href="${pageContext.request.contextPath}/ta/applications" class="nav-link">My Applications</a>
  </div>

  <main class="main-content" style="overflow-y:auto;">

    <!-- Welcome Hero -->
    <div class="welcome-hero">
      <div class="welcome-hero-inner">
        <div class="welcome-title">Welcome back, ${sessionScope.userName}</div>
        <div class="welcome-subtitle">Teaching Assistant Portal &nbsp;·&nbsp; Browse positions and track your applications</div>
      </div>
    </div>

    <!-- Stats -->
    <div class="stats-grid">
      <div class="stat-card">
        <div class="stat-icon">💼</div>
        <div class="stat-value">${totalJobs}</div>
        <div class="stat-label">Available Jobs</div>
      </div>
      <div class="stat-card">
        <div class="stat-icon">📋</div>
        <div class="stat-value">${myApplications}</div>
        <div class="stat-label">My Applications</div>
      </div>
      <div class="stat-card green">
        <div class="stat-icon">✅</div>
        <div class="stat-value green">${acceptedCount}</div>
        <div class="stat-label">Accepted</div>
      </div>
      <div class="stat-card yellow">
        <div class="stat-icon">⏳</div>
        <div class="stat-value yellow">${pendingCount}</div>
        <div class="stat-label">Pending</div>
      </div>
    </div>

    <!-- Quick Actions -->
    <div class="dashboard-actions">
      <a href="${pageContext.request.contextPath}/ta/jobs"         class="btn btn-primary btn-lg">Browse Available Jobs</a>
      <a href="${pageContext.request.contextPath}/ta/applications" class="btn btn-outline btn-lg">View My Applications</a>
      <a href="${pageContext.request.contextPath}/ta/profile"      class="btn btn-outline btn-lg">Update Profile</a>
    </div>

  </main>
</div>
</body>
</html>
