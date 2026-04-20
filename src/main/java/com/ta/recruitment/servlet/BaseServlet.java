package com.ta.recruitment.servlet;

import com.ta.recruitment.model.*;

import javax.servlet.ServletException;
import javax.servlet.http.*;
import java.io.*;
import java.util.Map;

public abstract class BaseServlet extends HttpServlet {

    // ---------- Application enrichment ----------

    protected void enrichAppWithTaInfo(Map<String, String> appMap, String taId, DataStore ds) {
        User ta = ds.findUserById(taId);
        appMap.put("taPhone",      ta != null && ta.getPhone()      != null ? ta.getPhone()      : "");
        appMap.put("taDepartment", ta != null && ta.getDepartment() != null ? ta.getDepartment() : "");
    }

    // ---------- CV file serving ----------

    protected void serveCV(HttpServletRequest req, HttpServletResponse resp,
                           String cvFile, String taName) throws IOException {
        if (cvFile == null || cvFile.isEmpty()) { resp.sendError(404, "CV not found"); return; }
        String uploadsDir = req.getServletContext().getRealPath("/WEB-INF/uploads/cv/");
        File file = new File(uploadsDir, cvFile);
        if (!file.exists()) { resp.sendError(404, "CV file not found"); return; }
        String contentType = cvFile.toLowerCase().endsWith(".pdf") ? "application/pdf" : "application/octet-stream";
        resp.setContentType(contentType);
        String safeName = taName.replaceAll("[^a-zA-Z0-9\\s._-]", "_") + "_CV.pdf";
        resp.setHeader("Content-Disposition", "inline; filename=\"" + safeName + "\"");
        resp.setContentLength((int) file.length());
        try (InputStream in = new FileInputStream(file); OutputStream out = resp.getOutputStream()) {
            byte[] buf = new byte[4096];
            int n;
            while ((n = in.read(buf)) != -1) out.write(buf, 0, n);
        }
    }

    // ---------- Profile POST handler ----------

    /**
     * Handles both "changePassword" and default profile-save actions.
     * Sets "success" or "error" request attributes and forwards to jspPath.
     */
    protected void handleProfilePost(HttpServletRequest req, HttpServletResponse resp,
                                     DataStore ds, String userId, String jspPath)
            throws ServletException, IOException {
        User user = ds.findUserById(userId);
        String action = req.getParameter("action");

        if ("changePassword".equals(action)) {
            if (user != null) {
                String oldPwd     = req.getParameter("oldPassword");
                String newPwd     = req.getParameter("newPassword");
                String confirmPwd = req.getParameter("confirmPassword");
                if (!user.getPassword().equals(oldPwd)) {
                    req.setAttribute("error", "Current password is incorrect.");
                } else if (newPwd == null || newPwd.length() < 4) {
                    req.setAttribute("error", "New password must be at least 4 characters.");
                } else if (!newPwd.equals(confirmPwd)) {
                    req.setAttribute("error", "New passwords do not match.");
                } else {
                    user.setPassword(newPwd);
                    ds.updateUser(user);
                    req.setAttribute("success", "Password changed successfully.");
                }
            }
        } else {
            if (user != null) {
                String name  = req.getParameter("name");
                String phone = req.getParameter("phone");
                String dept  = req.getParameter("department");
                if (name  != null && !name.trim().isEmpty()) user.setName(name.trim());
                if (phone != null) user.setPhone(phone.trim());
                if (dept  != null) user.setDepartment(dept.trim());
                ds.updateUser(user);
                req.getSession().setAttribute("userName", user.getName());
            }
            req.setAttribute("success", "Profile saved successfully.");
        }

        user = ds.findUserById(userId);
        if (user != null) req.setAttribute("user", user.toMap());
        req.getRequestDispatcher(jspPath).forward(req, resp);
    }
}