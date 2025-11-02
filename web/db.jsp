<%@ page import="java.sql.*" %>
<%
Connection con = null;
try {
    // ? Use your Railway DB credentials
   String dbURL  = System.getenv("DB_URL");
   String dbUser = System.getenv("DB_USER");
   String dbPass = System.getenv("DB_PASS");

    Class.forName("com.mysql.cj.jdbc.Driver");
    con = DriverManager.getConnection(dbURL, dbUser, dbPass);

} catch (Exception ex) {
    out.println("<p style='color:red;'>DB connection error: " + ex.getMessage() + "</p>");
}
%>
