<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8"%>
<%-- Parameters passed via jsp:param:
     portalTitle  - e.g. "Admin Portal"
     profileUrl   - e.g. "/admin/profile"
--%>
<style>
  .top-bar {
    height: 68px;
    background: linear-gradient(135deg, #0c1e3c 0%, #1a3a6b 100%);
    border-bottom: 1px solid rgba(255,255,255,0.08);
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 0 28px;
    box-sizing: border-box;
    box-shadow: 0 2px 12px rgba(10, 20, 50, 0.25);
  }
  .top-bar-left {
    display: flex;
    align-items: center;
    gap: 16px;
  }
  .school-logo {
    height: 44px;
    width: auto;
    filter: brightness(0) invert(1);
    opacity: 0.92;
  }
  .top-bar-title {
    font-size: 20px;
    font-weight: 600;
    color: #fff;
    letter-spacing: 0.01em;
  }
  .nav-main-row {
    background: #fff;
    border-bottom: 1px solid #dde4ef;
    padding: 0 28px;
    box-shadow: 0 1px 4px rgba(15, 30, 60, 0.06);
  }
  .nav-main-row .nav-link {
    padding: 15px 20px;
    display: inline-block;
    text-decoration: none;
    color: #64748b;
    font-size: 14px;
    font-weight: 500;
    border-bottom: 2px solid transparent;
    transition: color 0.18s;
  }
  .nav-main-row .nav-link:hover {
    color: #1e40af;
  }
  .nav-main-row .nav-link.active {
    color: #1e40af;
    font-weight: 600;
    border-bottom: 2px solid #2563eb;
  }
</style>

<div class="top-bar">
  <div class="top-bar-left">
    <img src="${pageContext.request.contextPath}/images/logo.png" class="school-logo" alt="School Logo">
    <span class="top-bar-title">Hi，${sessionScope.userName}</span>
  </div>
  <div class="header-right">
    <a href="${pageContext.request.contextPath}${param.profileUrl}" class="btn-icon" title="Profile">
      <svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
        <circle cx="12" cy="8" r="4"/><path d="M4 20c0-4 3.6-7 8-7s8 3 8 7"/>
      </svg>
    </a>
    <a href="${pageContext.request.contextPath}/logout" class="btn btn-outline btn-sm">Logout</a>
  </div>
</div>