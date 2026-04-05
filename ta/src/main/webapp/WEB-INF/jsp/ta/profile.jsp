<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Profile - TA Portal</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>
<div style="min-height:100vh;background:#f9fafb;">
  <header class="profile-header">
    <h1 style="font-size:16px;font-weight:600;">User Profile</h1>
    <a href="${pageContext.request.contextPath}/ta/jobs" class="btn btn-outline btn-sm">Back to Dashboard</a>
  </header>

  <main style="max-width:800px;margin:0 auto;padding:16px;">
    <% String success = (String) request.getAttribute("success"); %>
    <% if (success != null) { %>
      <div style="background:#f0fdf4;border:1px solid #86efac;color:#15803d;padding:10px 14px;border-radius:6px;margin-bottom:16px;font-size:13px;">
        <%= success %>
      </div>
    <% } %>

    <div style="margin-bottom:16px;">
      <h2 style="font-size:18px;margin-bottom:4px;">Profile Management</h2>
      <p class="text-sm text-gray-600">Role: Teaching Assistant</p>
    </div>

    <!-- Tabs -->
    <div class="tabs-list">
      <button class="tab-btn active" onclick="showTab('profile',this)">Profile</button>
      <button class="tab-btn" onclick="showTab('cv',this)">CV</button>
      <button class="tab-btn" onclick="showTab('settings',this)">Settings</button>
    </div>

    <!-- Profile Tab -->
    <div id="tab-profile" class="tab-content active">
      <div class="card" style="padding:16px;">
        <h3 class="text-lg mb-4">Profile Information</h3>
        <form action="${pageContext.request.contextPath}/ta/profile" method="post">
          <input type="hidden" name="action" value="saveProfile">
          <div class="form-group">
            <label class="form-label" for="name">Full Name</label>
            <input class="form-input" id="name" name="name" type="text"
                   value="${userName != null ? userName : 'John Smith'}">
          </div>
          <div class="form-group">
            <label class="form-label" for="email">Email Address</label>
            <input class="form-input" id="email" name="email" type="email"
                   value="${userEmail != null ? userEmail : 'john.smith@example.com'}">
          </div>
          <div class="form-group">
            <label class="form-label" for="phone">Phone Number</label>
            <input class="form-input" id="phone" name="phone" type="tel"
                   value="${userPhone != null ? userPhone : '+44 123 456 7890'}">
          </div>
          <div class="form-group">
            <label class="form-label" for="department">Department</label>
            <input class="form-input" id="department" name="department" type="text"
                   value="${userDepartment != null ? userDepartment : 'Computer Science'}">
          </div>
          <div class="form-group">
            <label class="form-label">Role</label>
            <input class="form-input" type="text" value="Teaching Assistant" disabled>
          </div>
          <button type="submit" class="btn btn-primary btn-sm">Save Profile</button>
        </form>
      </div>
    </div>

    <!-- CV Tab -->
    <div id="tab-cv" class="tab-content">
      <div class="card" style="padding:16px;">
        <h3 class="text-lg mb-4">CV Management</h3>
        <div class="form-group">
          <label class="form-label">Current CV</label>
          <div style="margin-top:4px;padding:12px;border:1px solid #d1d5db;border-radius:6px;display:flex;justify-content:space-between;align-items:center;">
            <span style="font-size:13px;color:#374151;">${cvFileName != null ? cvFileName : 'CV_JohnSmith.pdf'}</span>
            <button class="btn btn-outline btn-sm">Download</button>
          </div>
        </div>
        <div class="form-group">
          <label class="form-label" for="cvUpload">Upload New CV</label>
          <form action="${pageContext.request.contextPath}/ta/profile" method="post" enctype="multipart/form-data">
            <input type="hidden" name="action" value="uploadCV">
            <div class="upload-area" style="margin-top:4px;">
              <div class="upload-icon">&#128196;</div>
              <input id="cvUpload" name="cvFile" type="file" accept=".pdf,.doc,.docx"
                     style="display:block;width:100%;font-size:12px;color:#4b5563;margin-top:8px;">
            </div>
            <button type="submit" class="btn btn-primary btn-sm" style="margin-top:12px;">Upload and Replace CV</button>
          </form>
        </div>
      </div>
    </div>

    <!-- Settings Tab -->
    <div id="tab-settings" class="tab-content">
      <div class="card" style="padding:16px;">
        <h3 class="text-lg mb-4">Account Settings</h3>
        <h4 style="font-size:13px;font-weight:500;margin-bottom:12px;">Change Password</h4>
        <form action="${pageContext.request.contextPath}/ta/profile" method="post">
          <input type="hidden" name="action" value="changePassword">
          <div class="form-group">
            <label class="form-label" for="oldPwd">Current Password</label>
            <input class="form-input" id="oldPwd" name="oldPassword" type="password">
          </div>
          <div class="form-group">
            <label class="form-label" for="newPwd">New Password</label>
            <input class="form-input" id="newPwd" name="newPassword" type="password">
          </div>
          <div class="form-group">
            <label class="form-label" for="confirmPwd">Confirm New Password</label>
            <input class="form-input" id="confirmPwd" name="confirmPassword" type="password">
          </div>
          <button type="submit" class="btn btn-primary btn-sm">Update Password</button>
        </form>

        <div style="border-top:1px solid #e5e7eb;margin-top:24px;padding-top:16px;">
          <h4 style="font-size:13px;font-weight:500;margin-bottom:12px;">Update Email</h4>
          <form action="${pageContext.request.contextPath}/ta/profile" method="post">
            <input type="hidden" name="action" value="updateEmail">
            <div class="form-group">
              <label class="form-label" for="newEmail">New Email Address</label>
              <input class="form-input" id="newEmail" name="newEmail" type="email" placeholder="Enter new email">
            </div>
            <button type="submit" class="btn btn-outline btn-sm">Send Verification Email</button>
          </form>
        </div>
      </div>
    </div>
  </main>
</div>

<script>
function showTab(name, btn) {
  document.querySelectorAll('.tab-content').forEach(function(el){ el.classList.remove('active'); });
  document.querySelectorAll('.tab-btn').forEach(function(el){ el.classList.remove('active'); });
  document.getElementById('tab-' + name).classList.add('active');
  btn.classList.add('active');
}
</script>
</body>
</html>
