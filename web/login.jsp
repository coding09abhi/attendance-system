<%@ page import="java.sql.*" %>
<%@ page session="true" %>
<%@ include file="db.jsp" %>
<%
String message = "";

if(request.getParameter("login") != null){
    String username = request.getParameter("username").trim();
    String password = request.getParameter("password").trim();

    try {
        // Principal (hardcoded)
        if ("principal".equalsIgnoreCase(username) && "54321".equals(password)) {
            session.setAttribute("username", username);
            session.setAttribute("role", "principal");
            response.sendRedirect("principal_panel.jsp");
            return;
        }

        // Database check
        if (con == null) {
            message = "Database not connected. Please try later.";
        } else {
            String sql = "SELECT id, role FROM users WHERE username=? AND password=?";
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setString(1, username);
                ps.setString(2, password);

                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        int userId = rs.getInt("id");
                        String role = rs.getString("role");

                        // ? Set session attributes
                        session.setAttribute("username", username);
                        session.setAttribute("userid", userId);
                        session.setAttribute("role", role);

                        // Debug log (view in Render logs)
                        System.out.println("? Login success for: " + username + " | role=" + role);

                        // ? Role-based redirect
                        if ("teacher".equalsIgnoreCase(role)) {
                            response.sendRedirect("teacher_home.jsp");
                        } else if ("student".equalsIgnoreCase(role)) {
                            response.sendRedirect("student_home.jsp");
                        } else if ("principal".equalsIgnoreCase(role)) {
                            response.sendRedirect("principal_panel.jsp");
                        } else {
                            response.sendRedirect("index.jsp");
                        }
                        return;
                    } else {
                        message = "Invalid username or password!";
                    }
                }
            }
        }
    } catch (Exception e) {
        // Print detailed error in Render logs
        e.printStackTrace();
        message = "Login error: " + e.getMessage();
    } finally {
        try { if (con != null && !con.isClosed()) con.close(); } catch (Exception ee) {}
    }
}
%>

<!DOCTYPE html>
<html>
<head>
    <title>Login - Attendance</title>
    <style>
        body { margin:0; padding:0; background:#f5f7fa; font-family:'Poppins',sans-serif;
               height:100vh; display:flex; justify-content:center; align-items:center;}
        .container { background:#fff; width:350px; padding:40px 30px; border-radius:15px;
                     box-shadow:0 8px 20px rgba(0,0,0,0.15); text-align:center; }
        h2{ color:#333; margin-bottom:25px; }
        input[type="text"], input[type="password"]{
            width:90%; padding:12px; margin:8px 0;
            border:1px solid #ccc; border-radius:8px; outline:none;
            font-size:15px; transition:0.3s;
        }
        input[type="text"]:focus, input[type="password"]:focus{
            border-color:#0078ff; box-shadow:0 0 6px rgba(0,120,255,.4);
        }
        .btn{
            background:#0078ff; color:#fff; border:none; padding:12px 40px;
            margin-top:15px; border-radius:8px; cursor:pointer;
            font-size:15px; font-weight:bold; transition:0.3s;
        }
        .btn:hover{ background:#005ecc; transform:scale(1.05); }
        p{ margin-top:15px; font-size:14px; color:red; }
    </style>
</head>
<body>
<div class="container">
    <h2>Attendance Login</h2>
    <form method="post">
        <input type="text" name="username" placeholder="Enter Username" required><br>
        <input type="password" name="password" placeholder="Enter Password" required><br>
        <input type="submit" name="login" value="Login" class="btn">
    </form>
    <p><%= message %></p>
</div>
</body>
</html>
