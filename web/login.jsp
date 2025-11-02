<%@ page import="java.sql.*" %>
<%@ include file="db.jsp" %>
<%
String message = "";

if(request.getParameter("login") != null){
    String username = request.getParameter("username").trim();
    String password = request.getParameter("password").trim();

    try {
        // 1) Principal special case (local/hardcoded) - still allowed
        if ("principal".equals(username) && "54321".equals(password)) {
            session.setAttribute("username", username);
            session.setAttribute("role", "principal");
            response.sendRedirect("principal_panel.jsp");
            return;
        }

        // 2) For teachers / other users - use DB (ensure con is not null)
        if (con == null) {
            message = "Database not available. Try later.";
        } else {
            // Use prepared statement and try-with-resources to auto-close
            String sql = "SELECT id, role FROM users WHERE username=? AND password=?";
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setString(1, username);
                ps.setString(2, password);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        // read role from DB (student/teacher/principal)
                        String role = rs.getString("role");
                        int userId = rs.getInt("id");
                        session.setAttribute("username", username);
                        session.setAttribute("userid", userId);
                        session.setAttribute("role", role);

                        // redirect based on role
                        if ("teacher".equalsIgnoreCase(role)) {
                            response.sendRedirect("teacher_home.jsp");
                        } else if ("student".equalsIgnoreCase(role)) {
                            response.sendRedirect("student_dashboard.jsp");
                        } else if ("principal".equalsIgnoreCase(role)) {
                            response.sendRedirect("principal_panel.jsp");
                        } else {
                            // fallback
                            response.sendRedirect("index.jsp");
                        }
                        return;
                    } else {
                        message = "Invalid login details!";
                    }
                }
            }
        }
    } catch (Exception e) {
        // For debugging print minimal message. In production log to file instead.
        message = "Login error: " + e.getMessage();
    } finally {
        // close connection here (optional). If you plan to reuse con across multiple includes
        // within this same request, do not close here. In simple pages, close it.
        try {
            if (con != null && !con.isClosed()) con.close();
        } catch (Exception ee) { /* ignore */ }
    }
}
%>

<!DOCTYPE html>
<html>
<head>
    <title>Login - Attendance</title>
    <link rel="stylesheet" href="style.css?v=<%= System.currentTimeMillis() %>">
    <style>
        /* (your styles here - unchanged) */
        body { margin:0; padding:0; background:white; font-family:'Poppins',sans-serif; height:100vh; display:flex; justify-content:center; align-items:center;}
        .container { background:#fff; width:350px; padding:40px 30px; border-radius:15px; box-shadow:0 8px 20px rgba(0,0,0,0.2); text-align:center; transition:transform .3s;}
        .container:hover{ transform:scale(1.02); }
        h2{ color:#333; margin-bottom:25px; }
        input[type="text"], input[type="password"]{ width:90%; padding:12px; margin:8px 0; border:1px solid #ccc; border-radius:8px; outline:none; font-size:15px; transition:.3s;}
        input[type="text"]:focus, input[type="password"]:focus{ border-color:#ff6000; box-shadow:0 0 6px rgba(255,96,0,.5); }
        .btn{ background:#dd383e; color:#fff; border:none; padding:12px 40px; margin-top:15px; border-radius:8px; cursor:pointer; font-size:15px; font-weight:bold; transition:background .3s, transform .2s;}
        .btn:hover{ background:#ff6000; transform:scale(1.05); }
        p{ margin-top:15px; font-size:14px; }
    </style>
</head>
<body>
<div class="container">
    <h2>Sem 3 Div B - Attendance Login</h2>
    <form method="post">
        <input type="text" name="username" placeholder="Enter Username" required><br>
        <input type="password" name="password" placeholder="Enter Password" required><br>
        <input type="submit" name="login" value="Login" class="btn">
    </form>
    <p style="color:red;"><%= message %></p>
</div>
</body>
</html>
