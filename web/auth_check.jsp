<%
    // Disable caching (prevents accessing pages after logout)
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    // Check for active session and user
    if (session == null || session.getAttribute("user") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Optional: role-based restriction
    String role = (String) session.getAttribute("role");

    // Safely get the current page name (avoid request.getRequestURI())
    String currentPage = request.getServletPath();  // ? safe alternative

    if (currentPage != null) {
        currentPage = currentPage.toLowerCase(); // normalize
    } else {
        currentPage = "";
    }

    // Role-based access control
    if (currentPage.contains("principal") && !"principal".equals(role)) {
        response.sendRedirect("unauthorized.jsp");
        return;
    }

    if ((currentPage.contains("teacher") || currentPage.contains("attendance") || currentPage.contains("report"))
        && !"teacher".equals(role)) {
        response.sendRedirect("unauthorized.jsp");
        return;
    }

    if ((currentPage.contains("student") || currentPage.contains("student_home"))
        && !"student".equals(role)) {
        response.sendRedirect("unauthorized.jsp");
        return;
    }
%>
