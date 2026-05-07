package com.ta.recruitment.servlet;

import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.*;
import java.io.IOException;

@WebFilter(urlPatterns = {"/admin/*", "/mo/*", "/ta/*"})
public class AuthFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest  req  = (HttpServletRequest)  request;
        HttpServletResponse resp = (HttpServletResponse) response;

        HttpSession session = req.getSession(false);
        String userId   = session != null ? (String) session.getAttribute("userId")   : null;
        String userRole = session != null ? (String) session.getAttribute("userRole") : null;

        if (userId == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String path = req.getServletPath();
        boolean allowed =
                (path.startsWith("/admin") && "admin".equals(userRole)) ||
                (path.startsWith("/mo")    && "mo".equals(userRole))    ||
                (path.startsWith("/ta")    && "ta".equals(userRole));

        if (!allowed) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        chain.doFilter(request, response);
    }

    @Override public void init(FilterConfig fc) {}
    @Override public void destroy() {}
}