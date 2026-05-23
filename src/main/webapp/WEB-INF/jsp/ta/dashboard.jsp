<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, java.util.Map" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>TA Dashboard - TA Recruitment System</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        /* ── Hero banner ─────────────────────────────────────────────────── */
        .dash-hero {
            background: linear-gradient(135deg, #1e3a8a 0%, #2563eb 60%, #3b82f6 100%);
            border-radius: 12px;
            padding: 28px 32px;
            color: #fff;
            margin-bottom: 24px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 20px;
            box-shadow: 0 4px 18px rgba(37, 99, 235, 0.22);
        }
        .dash-hero-greeting {
            font-size: 22px;
            font-weight: 700;
            margin: 0 0 6px 0;
            line-height: 1.2;
        }
        .dash-hero-sub {
            font-size: 14px;
            opacity: 0.85;
            margin: 0;
        }
        .dash-hero-badge {
            background: rgba(255, 255, 255, 0.18);
            border: 1.5px solid rgba(255, 255, 255, 0.35);
            border-radius: 10px;
            padding: 12px 22px;
            text-align: center;
            flex-shrink: 0;
        }
        .dash-hero-badge-label {
            font-size: 10px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.08em;
            opacity: 0.78;
            margin-bottom: 3px;
        }
        .dash-hero-badge-value {
            font-size: 24px;
            font-weight: 700;
            line-height: 1;
        }
        .dash-hero-badge-unit {
            font-size: 11px;
            opacity: 0.72;
            margin-top: 3px;
        }

        /* ── Inline stat cards (wider than sidebar stat-card) ────────────── */
        .dash-stats-row {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 14px;
            margin-bottom: 24px;
        }
        @media (max-width: 860px) {
            .dash-stats-row { grid-template-columns: repeat(2, 1fr); }
        }
        .dash-stat-card {
            background: #fff;
            border: 1px solid #e5e7eb;
            border-radius: 10px;
            padding: 16px 18px;
            display: flex;
            align-items: center;
            gap: 14px;
            transition: box-shadow 0.2s, transform 0.15s;
        }
        .dash-stat-card:hover {
            box-shadow: 0 4px 14px rgba(0, 0, 0, 0.08);
            transform: translateY(-1px);
        }
        .dash-stat-icon {
            width: 44px;
            height: 44px;
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 22px;
            flex-shrink: 0;
        }
        .dash-stat-icon.blue   { background: #dbeafe; }
        .dash-stat-icon.green  { background: #dcfce7; }
        .dash-stat-icon.yellow { background: #fef9c3; }
        .dash-stat-icon.gray   { background: #f3f4f6; }
        .dash-stat-icon.red    { background: #fee2e2; }
        .dash-stat-info { flex: 1; min-width: 0; }
        .dash-stat-num {
            font-size: 26px;
            font-weight: 700;
            color: #111827;
            line-height: 1;
            margin-bottom: 3px;
        }
        .dash-stat-num.blue   { color: #1d4ed8; }
        .dash-stat-num.green  { color: #16a34a; }
        .dash-stat-num.yellow { color: #b45309; }
        .dash-stat-num.red    { color: #dc2626; }
        .dash-stat-label {
            font-size: 12px;
            color: #6b7280;
            font-weight: 500;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        /* ── Section heading separator ──────────────────────────────────── */
        .dash-section-title {
            font-size: 12px;
            font-weight: 700;
            color: #374151;
            text-transform: uppercase;
            letter-spacing: 0.07em;
            margin: 0 0 14px 0;
            padding-bottom: 8px;
            border-bottom: 1px solid #e5e7eb;
        }

        /* ── Application status breakdown bar ──────────────────────────── */
        .status-breakdown-card {
            background: #fff;
            border: 1px solid #e5e7eb;
            border-radius: 10px;
            padding: 18px 20px;
            margin-bottom: 28px;
        }
        .breakdown-header {
            display: flex;
            justify-content: space-between;
            align-items: baseline;
            margin-bottom: 12px;
        }
        .breakdown-title {
            font-size: 14px;
            font-weight: 600;
            color: #111827;
        }
        .breakdown-total {
            font-size: 13px;
            color: #9ca3af;
        }
        .breakdown-track {
            height: 10px;
            border-radius: 99px;
            background: #f3f4f6;
            overflow: hidden;
            display: flex;
            margin-bottom: 12px;
        }
        .breakdown-seg {
            height: 100%;
            transition: width 0.5s ease;
        }
        .breakdown-seg.green  { background: #22c55e; }
        .breakdown-seg.amber  { background: #f59e0b; }
        .breakdown-seg.red    { background: #ef4444; }
        .breakdown-legend {
            display: flex;
            flex-wrap: wrap;
            gap: 16px;
        }
        .legend-item {
            display: flex;
            align-items: center;
            gap: 7px;
            font-size: 12px;
            color: #6b7280;
        }
        .legend-dot {
            width: 9px;
            height: 9px;
            border-radius: 50%;
            flex-shrink: 0;
        }
        .legend-dot.green  { background: #22c55e; }
        .legend-dot.amber  { background: #f59e0b; }
        .legend-dot.red    { background: #ef4444; }
        .legend-dot.gray   { background: #d1d5db; }
        .legend-count {
            font-weight: 600;
            color: #374151;
        }

        /* ── Quick action cards ─────────────────────────────────────────── */
        .quick-actions-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 14px;
            margin-bottom: 28px;
        }
        @media (max-width: 720px) {
            .quick-actions-grid { grid-template-columns: 1fr; }
        }
        .quick-action-card {
            background: #fff;
            border: 1px solid #e5e7eb;
            border-radius: 10px;
            padding: 20px;
            text-decoration: none;
            color: inherit;
            display: flex;
            flex-direction: column;
            gap: 10px;
            transition: box-shadow 0.2s, border-color 0.2s, transform 0.15s;
        }
        .quick-action-card:hover {
            box-shadow: 0 6px 18px rgba(0, 0, 0, 0.09);
            border-color: #93c5fd;
            transform: translateY(-2px);
        }
        .qa-desc {
            font-size: 12px;
            color: #9ca3af;
            line-height: 1.5;
            flex: 1;
        }
        .qa-arrow {
            font-size: 14px;
            color: #93c5fd;
            font-weight: 700;
            align-self: flex-end;
        }

        /* ── Tips grid ──────────────────────────────────────────────────── */
        .tips-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 12px;
            margin-bottom: 24px;
        }

        /* ── Sidebar workload progress bar ──────────────────────────────── */
        .workload-bar-wrap {
            background: #fff;
            border: 1px solid #e5e7eb;
            border-radius: 8px;
            padding: 14px;
            margin-bottom: 10px;
        }
        .workload-bar-lbl {
            font-size: 11px;
            font-weight: 700;
            color: #6b7280;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            margin-bottom: 8px;
        }
        .workload-bar-track {
            height: 7px;
            border-radius: 99px;
            background: #f3f4f6;
            overflow: hidden;
            margin-bottom: 7px;
        }
        .workload-bar-fill {
            height: 100%;
            border-radius: 99px;
        }
        .workload-bar-fill.green  { background: #22c55e; }
        .workload-bar-fill.yellow { background: #f59e0b; }
        .workload-bar-fill.red    { background: #ef4444; }
        .workload-bar-nums {
            display: flex;
            justify-content: space-between;
            align-items: baseline;
            font-size: 11px;
            color: #9ca3af;
        }
        .workload-big {
            font-size: 15px;
            font-weight: 700;
        }
        .workload-big.green  { color: #16a34a; }
        .workload-big.yellow { color: #b45309; }
        .workload-big.red    { color: #dc2626; }
        .inline-alert.danger  { background:#fef2f2; border:1px solid #fca5a5; }
        .inline-alert.danger  .inline-alert-title { color:#b91c1c; }
        .inline-alert.danger  .inline-alert-body  { color:#7f1d1d; }
        .inline-alert.warning { background:#fefce8; border:1px solid #fde047; }
        .inline-alert.warning .inline-alert-title { color:#854d0e; }
        .inline-alert.warning .inline-alert-body  { color:#713f12; }
        .inline-alert.success { background:#f0fdf4; border:1px solid #86efac; }
        .inline-alert.success .inline-alert-title { color:#15803d; }
        .inline-alert.success .inline-alert-body  { color:#166534; }
    </style>
</head>
<body>
<div class="page-wrapper">
    <%@ include file="taheader.jsp" %>

    <div class="nav-main-row">
        <a href="${pageContext.request.contextPath}/ta/jobs"         class="nav-link">Browse Jobs</a>
        <a href="${pageContext.request.contextPath}/ta/applications" class="nav-link">My Applications</a>
    </div>

    <main class="main-content">
        <div class="content-with-sidebar">
            <div class="content-area">

                <!-- ─── Page heading ────────────────────────────────────────── -->
                <div class="content-header">
                    <div style="max-width:860px; margin:0 auto;">
                        <h2 class="text-2xl mb-1">Dashboard</h2>
                        <p class="text-gray-600">Teaching Assistant Portal &nbsp;&mdash;&nbsp; an overview of your activity</p>
                    </div>
                </div>

                <div class="content-body">
                    <div style="max-width:860px; margin:0 auto;">

                        <!-- ─── Hero banner ──────────────────────────────────── -->
                        <div class="dash-hero">
                            <div>
                                <p class="dash-hero-greeting">Welcome back, ${sessionScope.userName}!</p>
                                <p class="dash-hero-sub">Teaching Assistant Portal &nbsp;·&nbsp; Browse positions and track your applications</p>
                            </div>
                            <div class="dash-hero-badge">
                                <div class="dash-hero-badge-label">Available</div>
                                <div class="dash-hero-badge-value">${totalJobs}</div>
                                <div class="dash-hero-badge-unit">open jobs</div>
                            </div>
                        </div>

                        <!-- ─── Application status breakdown bar ─────────────── -->
                        <%
                            int totalApps = 0;
                            int nAccepted = 0;
                            int nPending  = 0;
                            int nRejected = 0;
                            try {
                                Object tA = request.getAttribute("myApplications");
                                Object nA = request.getAttribute("acceptedCount");
                                Object nP = request.getAttribute("pendingCount");
                                Object nR = request.getAttribute("rejectedCount");
                                if (tA != null) totalApps = Integer.parseInt(tA.toString());
                                if (nA != null) nAccepted = Integer.parseInt(nA.toString());
                                if (nP != null) nPending  = Integer.parseInt(nP.toString());
                                if (nR != null) nRejected = Integer.parseInt(nR.toString());
                            } catch (NumberFormatException ignored) {}
                            int denom   = totalApps > 0 ? totalApps : 1;
                            int pctAcc  = (int) Math.round(nAccepted * 100.0 / denom);
                            int pctPend = (int) Math.round(nPending  * 100.0 / denom);
                            int pctRej  = (int) Math.round(nRejected * 100.0 / denom);
                        %>
                        <div class="status-breakdown-card">
                            <div class="breakdown-header">
                                <span class="breakdown-title">Application Status Breakdown</span>
                                <span class="breakdown-total"><%= totalApps %> application<%= totalApps != 1 ? "s" : "" %> total</span>
                            </div>
                            <div class="breakdown-track">
                                <div class="breakdown-seg green" style="width:<%= pctAcc  %>%;"></div>
                                <div class="breakdown-seg amber" style="width:<%= pctPend %>%;"></div>
                                <div class="breakdown-seg red"   style="width:<%= pctRej  %>%;"></div>
                            </div>
                        </div>
                    </div><!-- /inner max-width -->
                </div><!-- /content-body -->
            </div><!-- /content-area -->

            <!-- ─── Sidebar ──────────────────────────────────────────────── -->
            <div class="sidebar">
                <p class="sidebar-title">APPLICATION SUMMARY</p>
                <div class="stat-card">
                    <p class="stat-label">Total Applications</p>
                    <p class="stat-value">${myApplications}</p>
                </div>
                <div class="stat-card green">
                    <p class="stat-label">Accepted</p>
                    <p class="stat-value green">${acceptedCount}</p>
                </div>
                <div class="stat-card yellow">
                    <p class="stat-label">Pending</p>
                    <p class="stat-value yellow">${pendingCount}</p>
                </div>
                <div class="stat-card blue">
                    <p class="stat-label">Available Jobs</p>
                    <p class="stat-value blue">${totalJobs}</p>
                </div>

                <p class="sidebar-title" style="margin-top:20px;">WORKLOAD</p>
                <%
                    int wl = 0;
                    try {
                        Object wObj = request.getAttribute("taWorkload");
                        if (wObj != null) wl = Integer.parseInt(wObj.toString());
                    } catch (NumberFormatException ignored) {}
                    String wlColor = wl > 80 ? "red" : wl > 40 ? "yellow" : "green";
                    int wlPct = (int) Math.min(100, Math.round(wl * 100.0 / 100));
                %>
                <div class="workload-bar-wrap">
                    <div class="workload-bar-lbl">Total Committed Hours</div>
                    <div class="workload-bar-track">
                        <div class="workload-bar-fill <%= wlColor %>" style="width:<%= wlPct %>%;"></div>
                    </div>
                    <div class="workload-bar-nums">
                        <span class="workload-big <%= wlColor %>">${taWorkload} h</span>
                        <span>/ 100 h max</span>
                    </div>
                </div>
                <% if (wl > 80) { %>
                <div class="inline-alert danger">
                    <p class="inline-alert-title">⚠️ High Workload</p>
                    <p class="inline-alert-body">Your committed hours exceed 80 h. MOs see a score deduction in the AI analysis of your applications.</p>
                </div>
                <% } else if (wl > 40) { %>
                <div class="inline-alert warning">
                    <p class="inline-alert-title">⚡ Moderate Workload</p>
                    <p class="inline-alert-body">Consider your remaining capacity carefully before taking on additional positions.</p>
                </div>
                <% } else { %>
                <div class="inline-alert success">
                    <p class="inline-alert-title">✅ Workload OK</p>
                    <p class="inline-alert-body">Your workload is within the normal range. No AI penalty applied.</p>
                </div>
                <% } %>
                <p style="font-size:11px; color:#94a3b8; margin:0 0 16px 0; padding:0 4px;">
                    Based on accepted positions (hours/week × weeks)
                </p>

                <div class="sidebar-section">
                    <p class="sidebar-section-title">QUICK ACTIONS</p>
                    <div style="display:flex;flex-direction:column;gap:8px;">
                        <a href="${pageContext.request.contextPath}/ta/jobs"
                           class="btn btn-primary btn-full" style="justify-content:flex-start;">Browse Jobs</a>
                        <a href="${pageContext.request.contextPath}/ta/applications"
                           class="btn btn-outline btn-full" style="justify-content:flex-start;">My Applications</a>
                        <a href="${pageContext.request.contextPath}/ta/profile"
                           class="btn btn-outline btn-full" style="justify-content:flex-start;">Update Profile</a>
                    </div>
                </div>
            </div><!-- /sidebar -->
        </div><!-- /content-with-sidebar -->
    </main>
</div>
</body>
</html>
