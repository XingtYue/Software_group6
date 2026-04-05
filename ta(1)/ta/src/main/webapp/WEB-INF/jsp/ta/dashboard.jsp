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
<nav class="navbar">
  <div class="navbar-brand">
    <span class="brand-icon">🎓</span>
    <span>TA Recruitment</span>
  </div>
  <div class="navbar-links">
    <a href="${pageContext.request.contextPath}/ta/jobs" class="nav-link">Browse Jobs</a>
    <a href="${pageContext.request.contextPath}/ta/applications" class="nav-link">My Applications</a>
    <a href="${pageContext.request.contextPath}/ta/profile" class="nav-link">Profile</a>
    <a href="${pageContext.request.contextPath}/logout" class="nav-link logout-link">Logout</a>
  </div>
</nav>

<div class="page-container">
  <div class="page-header">
    <h1 class="page-title">Welcome, ${sessionScope.userName}!</h1>
    <p class="page-subtitle">Teaching Assistant Portal</p>
  </div>

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
    <div class="stat-card">
      <div class="stat-icon">✅</div>
      <div class="stat-value">${acceptedCount}</div>
      <div class="stat-label">Accepted</div>
    </div>
    <div class="stat-card">
      <div class="stat-icon">⏳</div>
      <div class="stat-value">${pendingCount}</div>
      <div class="stat-label">Pending</div>
    </div>
  </div>

  <div class="dashboard-actions">
    <a href="${pageContext.request.contextPath}/ta/jobs" class="btn btn-primary btn-lg">
      🔍 Browse Available Jobs
    </a>
    <a href="${pageContext.request.contextPath}/ta/applications" class="btn btn-secondary btn-lg">
      📋 View My Applications
    </a>
    <a href="${pageContext.request.contextPath}/ta/profile" class="btn btn-outline btn-lg">
      👤 Update Profile
    </a>
  </div>
</div>
</body>
</html>
