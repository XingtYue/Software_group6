<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Add New Module Organiser - Admin Portal</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <style>
        .form-container {
            max-width: 680px;
            margin: 0 auto;
        }
        .form-section {
            background: #fff;
            border: 1px solid #e5e7eb;
            border-radius: 8px;
            padding: 16px 20px;
            margin-bottom: 14px;
        }
        .form-section-title {
            font-size: 12px;
            font-weight: 700;
            color: #2563eb;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            margin-bottom: 12px;
            padding-bottom: 8px;
            border-bottom: 2px solid #e5e7eb;
        }
        .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 14px;
            margin-bottom: 14px;
        }
        .form-row.single {
            grid-template-columns: 1fr;
        }
        .form-row:last-child {
            margin-bottom: 0;
        }
        .form-group {
            margin-bottom: 0;
        }
        .form-group label {
            display: block;
            font-size: 13px;
            font-weight: 600;
            color: #374151;
            margin-bottom: 6px;
        }
        .form-group label .required {
            color: #ef4444;
            margin-left: 2px;
        }
        .form-group label .optional {
            color: #9ca3af;
            font-weight: 400;
            font-size: 11px;
            margin-left: 4px;
        }
        .form-group input,
        .form-group select {
            width: 100%;
            padding: 8px 12px;
            border: 1px solid #d1d5db;
            border-radius: 6px;
            font-size: 13px;
            transition: all 0.2s;
            box-sizing: border-box;
        }
        .form-group input:focus,
        .form-group select:focus {
            outline: none;
            border-color: #2563eb;
            box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.1);
        }
        .form-group input::placeholder {
            color: #9ca3af;
        }
        .input-hint {
            font-size: 11px;
            color: #6b7280;
            margin-top: 4px;
        }
        .form-actions {
            display: flex;
            gap: 10px;
            margin-top: 16px;
        }
        .alert {
            padding: 10px 14px;
            border-radius: 6px;
            margin-bottom: 14px;
            font-size: 13px;
        }
        .alert-error {
            background: #fee;
            border: 1px solid #fcc;
            color: #c33;
        }
    </style>
</head>
<body>
<div class="page-wrapper">
    <%@ include file="adminheader.jsp" %>

    <div class="nav-main-row">
        <a href="${pageContext.request.contextPath}/admin" class="nav-link">User Management</a>
        <a href="${pageContext.request.contextPath}/admin/jobs" class="nav-link">Job Management</a>
        <a href="${pageContext.request.contextPath}/admin/applications" class="nav-link">Application Management</a>
        <a href="${pageContext.request.contextPath}/admin/workload" class="nav-link">Workload Management</a>
    </div>

    <main class="main-content">
        <div class="content-area">
            <div class="content-header">
                <div class="form-container">
                    <h2 class="text-2xl mb-2">Add New Module Organiser</h2>
                    <p class="text-gray-600">Create a new MO account to manage course modules</p>
                </div>
            </div>

            <div class="content-body">
                <div class="form-container">
                    <%
                        String error = request.getParameter("error");
                        if ("missing".equals(error)) {
                    %>
                        <div class="alert alert-error">
                            All required fields must be filled in. Please check your input.
                        </div>
                    <%
                        } else if ("duplicate".equals(error)) {
                    %>
                        <div class="alert alert-error">
                            Username already exists. Please choose a different username.
                        </div>
                    <%
                        }
                    %>

                    <form action="${pageContext.request.contextPath}/admin/add-mo" method="post">
                        <div class="form-section">
                            <div class="form-section-title">Account Credentials</div>
                            <div class="form-row">
                                <div class="form-group">
                                    <label>Username <span class="required">*</span></label>
                                    <input type="text" name="username" placeholder="e.g., dr.smith" required>
                                </div>
                                <div class="form-group">
                                    <label>Password <span class="required">*</span></label>
                                    <input type="password" name="password" placeholder="Minimum 6 characters" required>
                                </div>
                            </div>
                        </div>

                        <div class="form-section">
                            <div class="form-section-title">Personal Information</div>
                            <div class="form-row single">
                                <div class="form-group">
                                    <label>Full Name <span class="required">*</span></label>
                                    <input type="text" name="fullName" placeholder="e.g., Dr. John Smith" required>
                                </div>
                            </div>
                            <div class="form-row">
                                <div class="form-group">
                                    <label>Email Address <span class="required">*</span></label>
                                    <input type="email" name="email" placeholder="e.g., john.smith@bupt.edu.cn" required>
                                </div>
                                <div class="form-group">
                                    <label>Phone Number <span class="optional">(optional)</span></label>
                                    <input type="tel" name="phone" placeholder="e.g., +86 138 0000 0000">
                                </div>
                            </div>
                            <div class="form-row single">
                                <div class="form-group">
                                    <label>Department <span class="optional">(optional)</span></label>
                                    <select name="department">
                                        <option value="">Select a department</option>
                                        <option value="Computer Science">Computer Science</option>
                                        <option value="Software Engineering">Software Engineering</option>
                                        <option value="Information Technology">Information Technology</option>
                                        <option value="Data Science">Data Science</option>
                                        <option value="Artificial Intelligence">Artificial Intelligence</option>
                                        <option value="Cybersecurity">Cybersecurity</option>
                                        <option value="Mathematics">Mathematics</option>
                                        <option value="Physics">Physics</option>
                                        <option value="Engineering">Engineering</option>
                                        <option value="Business">Business</option>
                                    </select>
                                    <div class="input-hint">Select the primary department this MO belongs to</div>
                                </div>
                            </div>
                        </div>

                        <div class="form-actions">
                            <button type="submit" class="btn btn-primary">Create MO Account</button>
                            <a href="${pageContext.request.contextPath}/admin" class="btn btn-outline">Cancel</a>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </main>
</div>
</body>
</html>
