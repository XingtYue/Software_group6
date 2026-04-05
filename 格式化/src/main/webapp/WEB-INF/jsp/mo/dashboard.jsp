<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>MO Dashboard - TA Recruitment System</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
<nav class="navbar">
  <div class="navbar-brand">
    <span class="brand-icon">🎓</span>
    <span>TA Recruitment</span>
  </div>
  <div class="navbar-links">
    <a href="${pageContext.request.contextPath}/mo/applicants" class="nav-link">Applicants</a>
    <a href="${pageContext.request.contextPath}/mo/post-job" class="nav-link">Post Job</a>
    <a href="${pageContext.request.contextPath}/mo/profile" class="nav-link">Profile</a>
    <a href="${pageContext.request.contextPath}/logout" class="nav-link logout-link">Logout</a>
  </div>
</nav>

<div class="page-container">
  <div class="page-header">
    <h1 class="page-title">Welcome, ${sessionScope.userName}!</h1>
    <p class="page-subtitle">Module Organiser Portal</p>
  </div>

  <div class="stats-grid">
    <div class="stat-card">
      <div class="stat-icon">📢</div>
      <div class="stat-value">${myJobs}</div>
      <div class="stat-label">My Job Posts</div>
    </div>
    <div class="stat-card">
      <div class="stat-icon">👥</div>
      <div class="stat-value">${totalApplicants}</div>
      <div class="stat-label">Total Applicants</div>
    </div>
    <div class="stat-card">
      <div class="stat-icon">✅</div>
      <div class="stat-value">${acceptedCount}</div>
      <div class="stat-label">Accepted TAs</div>
    </div>
    <div class="stat-card">
      <div class="stat-icon">⏳</div>
      <div class="stat-value">${pendingCount}</div>
      <div class="stat-label">Pending Review</div>
    </div>
  </div>

  <div class="dashboard-actions">
    <a href="${pageContext.request.contextPath}/mo/post-job" class="btn btn-primary btn-lg">
      ➕ Post New Job
    </a>
    <a href="${pageContext.request.contextPath}/mo/applicants" class="btn btn-secondary btn-lg">
      👥 View Applicants
    </a>
    <a href="${pageContext.request.contextPath}/mo/profile" class="btn btn-outline btn-lg">
      👤 Update Profile
    </a>
  </div>
</div>
</body>
</html>
