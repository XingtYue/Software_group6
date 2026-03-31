package com.ta.recruitment.servlet;

import com.ta.recruitment.model.DataStore;
import com.ta.recruitment.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("user") != null) {
            User user = (User) session.getAttribute("user");
            redirectByRole(resp, req, user.getRole());
            return;
        }
        req.getRequestDispatcher("/login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String email = req.getParameter("email");
        String password = req.getParameter("password");

        User user = DataStore.getInstance().findUserByEmailAndPassword(email, password);
        if (user != null) {
            HttpSession session = req.getSession(true);
            session.setAttribute("user", user);
            session.setAttribute("userId", user.getId());
            session.setAttribute("userName", user.getName());
            session.setAttribute("userRole", user.getRole());
            redirectByRole(resp, req, user.getRole());
        } else {
            req.setAttribute("error", "Invalid email or password. Please try again.");
            req.getRequestDispatcher("/login.jsp").forward(req, resp);
        }
    }

    private void redirectByRole(HttpServletResponse resp, HttpServletRequest req, String role)
            throws IOException {
        String ctx = req.getContextPath();
        switch (role) {
            case "admin": resp.sendRedirect(ctx + "/admin"); break;
            case "mo":    resp.sendRedirect(ctx + "/mo/applicants"); break;
            default:      resp.sendRedirect(ctx + "/ta/jobs"); break;
        }
    }
}
