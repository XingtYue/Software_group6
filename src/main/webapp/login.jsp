<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Login - TA Recruitment System</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
  <style>
    /* 1. 干净的背景：去除蓝调，只用极淡的黑色遮罩压暗底图，突出主体 */
    .login-page {
      margin: 0;
      padding: 0;
      width: 100%;
      min-height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
      background-image:
              linear-gradient(rgba(0, 0, 0, 0.25), rgba(0, 0, 0, 0.25)),
              url("${pageContext.request.contextPath}/images/Login_bg.png");
      background-size: cover;
      background-position: center;
      background-repeat: no-repeat;
      background-attachment: fixed;
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
    }

    /* 2. 极致纯白悬浮卡片 */
    .login-box {
      width: 100%;
      max-width: 440px;
      padding: 48px 40px;
      /* 75% 透明度的白，既能看清文字，又能透出背景的光影 */
      background: rgba(255, 255, 255, 0.75);
      /* 关键：增加 saturate(120%) 让透过去的背景色不发灰，保持鲜活 */
      backdrop-filter: blur(24px) saturate(120%);
      -webkit-backdrop-filter: blur(24px) saturate(120%);
      /* 极细的白色高光边框 */
      border: 1px solid rgba(255, 255, 255, 0.8);
      border-radius: 24px;
      /* 内外双重阴影，消除硬边缘 */
      box-shadow: 0 24px 48px -12px rgba(0, 0, 0, 0.15),
      inset 0 1px 0 rgba(255, 255, 255, 1);
    }

    /* 3. 头部排版 */
    .login-header {
      display: flex;
      flex-direction: column;
      align-items: center;
      margin-bottom: 36px;
      text-align: center;
    }
    .school-logo {
      height: 60px;
      width: auto;
      margin-bottom: 20px;
    }
    .login-title {
      font-size: 22px;
      font-weight: 700;
      color: #1a1f36; /* Stripe 风格的高级深灰蓝 */
      letter-spacing: -0.5px;
      margin: 0;
    }

    /* 4. 高级输入框体系 */
    .form-group {
      margin-bottom: 20px;
      text-align: left;
    }
    .form-label {
      font-size: 13px;
      font-weight: 600;
      color: #3c4257;
      margin-bottom: 8px;
      display: block;
    }
    /* 2. 输入框也融入环境 */
    .form-input {
      width: 100%;
      padding: 14px 16px;
      font-size: 15px;
      color: #1a1f36;
      /* 半透明底色，配合主容器的质感 */
      background-color: rgba(255, 255, 255, 0.5);
      border: 1px solid rgba(255, 255, 255, 0.8);
      border-radius: 12px;
      box-sizing: border-box;
      transition: all 0.3s ease;
    }
    .form-input:focus {
      outline: none;
      background-color: #ffffff; /* 聚焦时变回纯白以突出显示 */
      border-color: #0A2540; /* 极简的深色边框 */
      box-shadow: 0 0 0 4px rgba(10, 37, 64, 0.1);
    }
    /* 5. 按钮全面升级 */
    .btn-container {
      display: flex;
      gap: 16px;
      margin-top: 32px;
    }
    .btn {
      flex: 1;
      padding: 14px 0;
      font-size: 15px;
      font-weight: 600;
      border-radius: 12px;
      text-align: center;
      cursor: pointer;
      transition: all 0.2s ease;
      box-sizing: border-box;
      text-decoration: none;
      display: flex;
      justify-content: center;
      align-items: center;
    }

    /* 主按钮：微渐变 + 顶部高光 + 悬浮上浮 */
    /* 3. 按钮颜色重构：黑曜石高级渐变 */
    .btn-primary {
      /* 深空灰到极致黑的微渐变，类似 Stripe/Vercel 的高级质感 */
      background: linear-gradient(180deg, #1a1f36 0%, #0a0d1a 100%);
      color: #ffffff;
      border: 1px solid #000000;
      /* 顶部内阴影高光，底部外阴影托底 */
      box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.15),
      0 4px 6px -1px rgba(0, 0, 0, 0.2);
    }
    .btn-primary:hover {
      /* 悬浮时稍微变亮，带有呼吸感 */
      background: linear-gradient(180deg, #2a314d 0%, #1a1f36 100%);
      transform: translateY(-1px);
      box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.15),
      0 6px 12px -2px rgba(0, 0, 0, 0.3);
    }

    /* 4. 注册按钮：跟随主容器的半透明材质 */
    .btn-outline {
      background: rgba(255, 255, 255, 0.6);
      color: #1a1f36;
      border: 1px solid rgba(0, 0, 0, 0.1);
      box-shadow: 0 1px 2px rgba(0, 0, 0, 0.05);
    }
    .btn-outline:hover {
      background: rgba(255, 255, 255, 0.9);
      border-color: rgba(0, 0, 0, 0.2);
    }
    /* 底部提示文字 */
    .login-demo {
      margin-top: 32px;
      padding-top: 24px;
      border-top: 1px solid #e2e8f0;
      font-size: 12px;
      color: #718096;
      text-align: center;
      line-height: 1.6;
    }
    .login-demo strong {
      color: #4a5568;
      font-weight: 600;
      display: block;
      margin-bottom: 8px;
    }
     /* 醒目红色错误提示样式 */
        .error-alert {
          background-color: #fef2f2;
          border: 1px solid #fecdd3;
          color: #dc2626;
          padding: 12px 16px;
          border-radius: 10px;
          margin-bottom: 20px;
          font-size: 14px;
          font-weight: 600;
          text-align: center;
        }
  </style>
</head>
<body>
<div class="login-page">
  <div class="login-box">
    <div class="login-header">
      <img src="${pageContext.request.contextPath}/images/logo1.png" class="school-logo" alt="BUPT">
      <h1 class="login-title">TA Recruitment System</h1>
    </div>

  <% String error = (String) request.getAttribute("error"); %>
  <% if (error != null) { %>
  <div class="alert-error"><%= error %></div>
  <% } %>

  <% if ("1".equals(request.getParameter("registered"))) { %>
  <div style="background:#f0fdf4;border:1px solid #86efac;color:#15803d;padding:10px 14px;border-radius:6px;margin-bottom:16px;font-size:13px;">
    Account created successfully. Please log in.
  </div>
  <% } %>

    <form action="${pageContext.request.contextPath}/login" method="post">
      <div class="form-group">
        <label class="form-label" for="email">Email</label>
        <input class="form-input" id="email" name="email" type="email"
               placeholder="Enter your email" required
               value="${param.email != null ? param.email : ''}">
      </div>

      <div class="form-group">
        <label class="form-label" for="password">Password</label>
        <input class="form-input" id="password" name="password" type="password"
               placeholder="Enter your password" required>
      </div>

      <div class="btn-container">
        <button type="submit" class="btn btn-primary">Login</button>
        <a href="${pageContext.request.contextPath}/register" class="btn btn-outline">Register</a>
      </div>
    </form>

    <div class="login-demo">
      <strong>Demo logins:</strong>
      ta@example.com / password123 &rarr; TA Dashboard<br>
      mo@example.com / password123 &rarr; Module Organiser<br>
      admin@example.com / password123 &rarr; Admin
    </div>
  </div>
</div>
</body>
</html>