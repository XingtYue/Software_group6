<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, java.util.Map, java.util.HashMap, java.util.ArrayList" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Browse Jobs - TA Portal</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">

    <style>

        /* 1. 全局背景：使用生成的莫兰迪弥散光抽象图片 (No Grid) */
        body {
            /* 页面基底色，确保图片加载前不全白 */
            background-color: #e2e8f0;
            /* 引用生成的图片 */
            background-image: url("${pageContext.request.contextPath}/images/bg.png");
            background-size: cover; /* 保持图片覆盖全屏 */
            background-position: center center; /* 居中显示 */
            background-repeat: no-repeat;
            background-attachment: fixed; /* 视差滚动效果，增加高级感 */

            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
            color: #1e293b;
            margin: 0;
            padding: 0;
        }

        /* 2. 改造职位卡片：增加一点点通透感，融入背景 */
        .job-card {
            /* 稍微使用一点毛玻璃效果，让卡片在带有弥散光的背景上浮现出来 */
            background: rgba(255, 255, 255, 0.85);
            backdrop-filter: blur(8px);
            -webkit-backdrop-filter: blur(8px);

            border: 1px solid rgba(226, 232, 240, 0.8);
            border-left: 4px solid #3b82f6; /* 保留品牌强调线 */
            border-radius: 12px;
            padding: 20px 24px;
            margin-bottom: 16px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            transition: all 0.3s ease;
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.02);
        }
        .job-card:hover {
            transform: translateY(-3px);
            border-color: #cbd5e0;
            box-shadow: 0 15px 30px -5px rgba(0, 0, 0, 0.1);
        }



        /* 3. 搜索框：通透且轻盈 */
        .search-input {
            width: 100%;
            padding: 12px 16px;
            font-size: 14px;
            color: #0f172a;
            background-color: rgba(255, 255, 255, 0.95);
            border: 2px solid transparent;
            border-radius: 10px;
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
            transition: all 0.2s ease;
            box-sizing: border-box;
        }
        .search-input:focus {
            outline: none;
            background-color: #ffffff;
            border-color: #60a5fa;
            box-shadow: 0 0 0 4px rgba(96, 165, 250, 0.3);
        }

        /* 4. 职位卡片：保留结构线，但去掉沉闷的边框 */
        .course-group-title {
            font-size: 16px;
            font-weight: 700;
            color: #1e293b;
            margin: 32px 0 16px 0;
            padding-bottom: 8px;
            border-bottom: 2px solid #e2e8f0;
        }
        .job-card {
            background: rgba(255, 255, 255, 0.85); /* 微微半透明，透出一点点底层网格 */
            backdrop-filter: blur(8px);
            -webkit-backdrop-filter: blur(8px);
            border: 1px solid #e2e8f0;
            border-left: 4px solid #3b82f6;
            border-radius: 12px;
            padding: 20px 24px;
            margin-bottom: 16px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            transition: all 0.2s ease;
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.02);
        }
        .job-card:hover {
            transform: translateY(-2px);
            border-color: #cbd5e0;
            box-shadow: 0 12px 20px -5px rgba(0, 0, 0, 0.08);
        }
        .job-card-title {
            font-size: 15px;
            font-weight: 700;
            color: #0f172a;
            margin: 0 0 6px 0;
            display: flex;
            align-items: center;
            gap: 12px;
        }
        .job-card-desc { font-size: 13px; color: #475569; margin: 0 0 8px 0; line-height: 1.5; }
        .job-card-meta { font-size: 12px; color: #64748b; margin: 0; font-weight: 600; }

        .position-type-tag {
            font-size: 11px;
            font-weight: 700;
            color: #2563eb;
            background-color: #eff6ff;
            padding: 4px 10px;
            border-radius: 6px;
        }

        /* 5. 侧边栏：柔和底色 + 强对比色带，清晰但不刺眼 */
        .sidebar { padding-top: 0; }
        .sidebar-title {
            font-size: 12px;
            font-weight: 700;
            color: #64748b;
            letter-spacing: 1px;
            margin-bottom: 12px;
        }
        .stat-card {
            background: rgba(255, 255, 255, 0.85);
            backdrop-filter: blur(8px);
            border: 1px solid #e2e8f0;
            border-radius: 12px;
            padding: 16px 20px;
            margin-bottom: 12px;
            transition: all 0.2s;
            box-shadow: 0 2px 4px rgba(0,0,0,0.02);
            border-left: 4px solid transparent;
        }
        .stat-card:hover { transform: translateY(-1px); box-shadow: 0 4px 6px rgba(0,0,0,0.05); }

        /* 利用左侧粗线定调，背景保持干净 */
        .stat-card:nth-of-type(1) { border-left-color: #8b5cf6; } /* 紫 */
        .stat-card:nth-of-type(1) .stat-value { color: #6d28d9; }

        .stat-card:nth-of-type(2) { border-left-color: #10b981; } /* 绿 */
        .stat-card:nth-of-type(2) .stat-value { color: #047857; }

        .stat-card:nth-of-type(3) { border-left-color: #3b82f6; } /* 蓝 */
        .stat-card:nth-of-type(3) .stat-value { color: #1d4ed8; }

        .stat-label { font-size: 13px; font-weight: 600; color: #475569; margin: 0; }
        .stat-value { font-size: 26px; font-weight: 800; margin: 4px 0 0 0; }

        /* 6. 按钮：适度的深色调 */
        .btn-primary.btn-sm {
            padding: 8px 18px;
            font-size: 13px;
            font-weight: 700;
            border-radius: 8px;
            background: #1e293b;
            color: #ffffff;
            border: none;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
            text-decoration: none;
            transition: all 0.2s ease;
        }
        .btn-primary.btn-sm:hover {
            transform: translateY(-2px);
            background: #3b82f6;
            box-shadow: 0 6px 10px rgba(59, 130, 246, 0.2);
        }

        .btn-outline {
            background: #ffffff;
            color: #1e293b;
            border: 1px solid #cbd5e0;
            border-radius: 8px;
            padding: 10px 16px;
            font-size: 13px;
            font-weight: 700;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.02);
            text-decoration: none;
            transition: all 0.2s ease;
            display: block;
            text-align: center;
        }
        .btn-outline:hover {
            border-color: #94a3b8;
            background: #f8fafc;
        }
    </style>
</head>
<body>
<div class="page-wrapper">
    <%@ include file="taheader.jsp" %>

    <div class="nav-main-row" style="background: #fff; border-bottom: 1px solid #e2e8f0; margin-bottom: 32px; padding: 0 40px;">
        <a href="${pageContext.request.contextPath}/ta/jobs" class="nav-link active" style="padding: 16px 0; margin-right: 32px; font-weight: 600; font-size: 14px; color: #1a1f36; border-bottom: 2px solid #0066cc;">Browse Jobs</a>
        <a href="${pageContext.request.contextPath}/ta/applications" class="nav-link" style="padding: 16px 0; color: #718096; font-size: 14px; font-weight: 500; text-decoration: none;">My Applications</a>
    </div>

    <main class="main-content" style="padding: 0 40px;">
        <div class="content-with-sidebar" style="display: flex; gap: 40px; max-width: 1100px; margin: 0 auto;">
            <div class="content-area" style="flex: 1;">

                <div class="page-hero">
                    <h2>Available Positions</h2>
                    <p>Browse and apply for teaching assistant positions</p>

                    <% if (request.getAttribute("errorMsg") != null) { %>
                    <div class="alert alert-error" style="background: rgba(254, 226, 226, 0.9); color: #991b1b; padding: 10px; border-radius: 8px; font-size: 13px; margin-bottom: 16px;"><%= request.getAttribute("errorMsg") %></div>
                    <% } %>
                    <% if (request.getAttribute("successMsg") != null) { %>
                    <div class="alert alert-success" style="background: rgba(220, 252, 231, 0.9); color: #166534; padding: 10px; border-radius: 8px; font-size: 13px; margin-bottom: 16px;"><%= request.getAttribute("successMsg") %></div>
                    <% } %>

                    <form method="get" action="${pageContext.request.contextPath}/ta/jobs">
                        <input class="search-input" type="search" name="q"
                               placeholder="Search jobs by title or department..."
                               value="${param.q != null ? param.q : ''}">
                    </form>
                </div>

                <div class="content-body">
                    <div>
                        <%
                            List<Map<String,String>> jobs = (List<Map<String,String>>) request.getAttribute("jobs");
                            if (jobs != null && !jobs.isEmpty()) {
                                Map<String, List<Map<String,String>>> jobsByCourse = new HashMap<String, List<Map<String,String>>>();
                                for (Map<String,String> job : jobs) {
                                    String courseName = job.get("courseName");
                                    if (courseName == null || courseName.trim().isEmpty()) { courseName = "Other Positions"; }
                                    else { courseName = courseName.trim(); }

                                    if (!jobsByCourse.containsKey(courseName)) { jobsByCourse.put(courseName, new ArrayList<Map<String,String>>()); }
                                    jobsByCourse.get(courseName).add(job);
                                }
                                for (Map.Entry<String, List<Map<String,String>>> courseEntry : jobsByCourse.entrySet()) {
                                    String courseName = courseEntry.getKey();
                                    List<Map<String,String>> courseJobs = courseEntry.getValue();
                        %>
                        <div class="course-group-title"><%= courseName %></div>

                        <% for (Map<String,String> job : courseJobs) { %>
                        <div class="job-card">
                            <div class="job-card-body" style="flex: 1;">
                                <h3 class="job-card-title">
                                    <%= job.get("title") %>
                                    <% String positionType = job.get("positionType"); if (positionType != null && !positionType.trim().isEmpty()) { %>
                                    <span class="position-type-tag"><%= positionType %></span>
                                    <% } %>
                                </h3>
                                <p class="job-card-desc"><%= job.get("description") %></p>
                                <p class="job-card-meta">Department: <%= job.get("department") %></p>
                            </div>
                            <div style="margin-left:24px; flex-shrink:0;">
                                <a href="${pageContext.request.contextPath}/ta/jobs/<%= job.get("jobId") %>" class="btn-primary btn-sm">View Details</a>
                            </div>
                        </div>
                        <% } } } else { %>
                        <div class="empty-state" style="text-align: center; padding: 48px 0; color: #718096; background: #fff; border-radius: 12px; border: 1px dashed #cbd5e0; font-size: 14px;">
                            <p style="margin: 0;">No jobs available at the moment.</p>
                        </div>
                        <% } %>
                    </div>
                </div>
            </div>

            <div class="sidebar" style="width: 260px; flex-shrink: 0;">
                <p class="sidebar-title">OVERVIEW</p>
                <div class="stat-card">
                    <p class="stat-label">Active Applications</p>
                    <p class="stat-value">${activeApplications}</p>
                </div>
                <div class="stat-card">
                    <p class="stat-label">Available Jobs</p>
                    <p class="stat-value">${totalJobs}</p>
                </div>
                <div class="stat-card">
                    <p class="stat-label">Accepted Positions</p>
                    <p class="stat-value">${acceptedPositions}</p>
                </div>

                <div class="sidebar-section">
                    <p class="sidebar-title" style="margin-top: 32px;">QUICK ACTIONS</p>
                    <div style="display:flex; flex-direction:column; gap:10px;">
                        <a href="${pageContext.request.contextPath}/ta/applications" class="btn-outline" style="border-radius: 10px; padding: 10px 16px; font-size: 13px; border: 1px solid #e2e8f0; text-decoration: none; color: #3c4257; background: #fff; text-align: center; font-weight: 600;">View Applications</a>
                        <a href="${pageContext.request.contextPath}/ta/profile" class="btn-outline" style="border-radius: 10px; padding: 10px 16px; font-size: 13px; border: 1px solid #e2e8f0; text-decoration: none; color: #3c4257; background: #fff; text-align: center; font-weight: 600;">Update Profile</a>
                    </div>
                </div>
            </div>
        </div>
    </main>
</div>
</body>
</html>