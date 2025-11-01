<%@ page import="java.sql.*" %>
<%
/* db.jsp - central DB connection include
   - Uses environment variables if present (safer for deployment)
   - Falls back to localhost for local testing
   - Declares 'Connection con' variable for pages that include this file
*/
Connection con = null;
try {
    // Prefer environment variables (set these in Render / server)
    String dbURL  = System.getenv("DB_URL");
    String dbUser = System.getenv("DB_USER");
    String dbPass = System.getenv("DB_PASS");

    if(dbURL == null || dbURL.trim().isEmpty()){
        // fallback for local dev
        dbURL  = "jdbc:mysql://localhost:3306/attendance_sem3b?useSSL=false&serverTimezone=UTC";
        dbUser = "root";
        dbPass = "";
    }

    Class.forName("com.mysql.cj.jdbc.Driver");
    con = DriverManager.getConnection(dbURL, dbUser, dbPass);
} catch(Exception ex) {
    // It's useful to log; avoid exposing full stack to users in production.
    out.println("DB connection error: " + ex.getMessage());
}
%>
