<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"%>

<style>
  .top-bar {
    height: 70px;
    background: #fff;
    border-bottom: 1px solid #e5e7eb;
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 0 24px;
    box-sizing: border-box;
  }
  .top-bar-left {
    display: flex;
    align-items: center;
    gap: 16px;
  }
  .school-logo {
    height: 50px;
    width: auto;
  }
  .top-bar-title {
    font-size: 22px;
    font-weight: 600;
    color: #111827;
  }
  .nav-main-row {
    background: #f9fafb;
    border-bottom: 1px solid #e5e7eb;
    padding: 0 24px;
  }
  .nav-main-row .nav-link {
    padding: 16px 20px;
    display: inline-block;
    text-decoration: none;
    color: #4b5563;
  }
  .nav-main-row .nav-link.active {
    color: #2563eb;
    font-weight: 600;
    border-bottom: 2px solid #2563eb;
  }

</style>

<div class="top-bar">
  <div class="top-bar-left">
    <img src="${pageContext.request.contextPath}/images/logo.png" class="school-logo" alt="School Logo">
    <span class="top-bar-title">MO Portal</span>
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