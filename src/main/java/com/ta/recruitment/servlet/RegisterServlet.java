package com.ta.recruitment.servlet;

import com.ta.recruitment.model.DataStore;
import com.ta.recruitment.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/register.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        String name     = trim(request.getParameter("name"));
        String email    = trim(request.getParameter("email"));
        String password = request.getParameter("password");
        String confirm  = request.getParameter("confirmPassword");
        String role     = trim(request.getParameter("role"));
        String phone    = trim(request.getParameter("phone"));
        String department = trim(request.getParameter("department"));

        // ---- Validation ----
        if (name.isEmpty() || email.isEmpty() || password == null || password.isEmpty()) {
            forward(request, response, "Name, email and password are required.");
            return;
        }
        if (!email.contains("@")) {
            forward(request, response, "Please enter a valid email address.");
            return;
        }
        if (password.length() < 6) {
            forward(request, response, "Password must be at least 6 characters.");
            return;
        }
        if (!password.equals(confirm)) {
            forward(request, response, "Passwords do not match.");
            return;
        }
        if (!"ta".equals(role) && !"mo".equals(role)) {
            forward(request, response, "Please select a valid role.");
            return;
        }

        DataStore ds = DataStore.getInstance();
        if (ds.findUserByEmail(email) != null) {
            forward(request, response, "An account with this email already exists.");
            return;
        }

        // ---- Create user ----
        User user = new User();
        user.setName(name);
        user.setEmail(email);
        user.setPassword(password);
        user.setRole(role);
        user.setPhone(phone);
        user.setDepartment(department.isEmpty() ? "Computer Science" : department);
        user.setStatus("active");

        // MO: save modules entered at registration
        if ("mo".equals(role)) {
            String[] codes = request.getParameterValues("moduleCode");
            String[] names = request.getParameterValues("moduleName");
            StringBuilder sb = new StringBuilder();
            if (codes != null) {
                for (int i = 0; i < codes.length; i++) {
                    String code = codes[i] != null ? codes[i].trim() : "";
                    String mname = (names != null && i < names.length && names[i] != null) ? names[i].trim() : code;
                    if (!code.isEmpty()) {
                        if (sb.length() > 0) sb.append(";");
                        sb.append(code).append("|").append(mname.isEmpty() ? code : mname);
                    }
                }
            }
            user.setModules(sb.toString());
        }

        ds.addUser(user);

        // Redirect to login with success message
        response.sendRedirect(request.getContextPath() + "/login?registered=1");
    }

    private void forward(HttpServletRequest request, HttpServletResponse response, String error)
            throws ServletException, IOException {
        request.setAttribute("error", error);
        request.getRequestDispatcher("/register.jsp").forward(request, response);
    }

    private String trim(String s) {
        return s != null ? s.trim() : "";
    }
}