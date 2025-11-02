<%@ page import="java.sql.*" %>
<%@ include file="db.jsp" %>

<%
if (session.getAttribute("username") == null) {
    response.sendRedirect("login.jsp");
}
String username = (String) session.getAttribute("username");
%>
<!DOCTYPE html>
<html>
<head>
    <title>Teacher Panel</title>
    <link rel="stylesheet" href="style.css?v=<%= System.currentTimeMillis() %>">
     <link rel="icon" type="image/jpeg" href="images/favicon.jpg">
    <style>
        body {
            margin: 0;
            padding: 0;
            font-family: "Poppins", sans-serif;
            background: #f9f9f9;
        }

        .navbar {
            background: #dd383e;
            color: #fff;
            padding: 15px 25px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            box-shadow: 0 4px 10px rgba(0,0,0,0.2);
        }

        .navbar h3 {
            margin: 0;
            font-size: 20px;
            letter-spacing: 0.5px;
        }

        .nav-buttons a {
            color: #fff;
            text-decoration: none;
            padding: 10px 16px;
            margin-left: 8px;
            border-radius: 6px;
            transition: background 0.3s ease, transform 0.2s;
        }

        .nav-buttons a:hover {
            background: #ff6000;
            transform: scale(1.05);
        }

        .nav-buttons .active {
            background: #ff6000;
        }

        .content {
            background: #fff;
            width: 90%;
            max-width: 800px;
            margin: 60px auto;
            padding: 40px;
            border-radius: 12px;
            box-shadow: 0 6px 18px rgba(0, 0, 0, 0.15);
        }

        h2 {
            text-align: center;
            color: #dd383e;
            margin-bottom: 25px;
        }

        form {
            display: flex;
            flex-direction: column;
            align-items: center;
        }

        input[type="date"],
        select {
            width: 80%;
            padding: 12px;
            margin: 10px 0;
            border: 1px solid #ccc;
            border-radius: 8px;
            font-size: 15px;
            outline: none;
            transition: border 0.3s ease;
        }

        input[type="date"]:focus,
        select:focus {
            border-color: #ff6000;
            box-shadow: 0 0 6px rgba(255,96,0,0.4);
        }

        .btn {
            background: #dd383e;
            color: white;
            border: none;
            padding: 12px 30px;
            border-radius: 8px;
            cursor: pointer;
            font-size: 16px;
            margin-top: 15px;
            font-weight: bold;
            transition: background 0.3s ease, transform 0.2s;
        }

        .btn:hover {
            background: #ff6000;
            transform: scale(1.05);
        }

        p {
            text-align: center;
            margin-top: 10px;
        }

        /* Responsive Design */
        @media (max-width: 768px) {
            .navbar {
                flex-direction: column;
                text-align: center;
            }
            .nav-buttons {
                margin-top: 10px;
            }
            .content {
                padding: 25px;
            }
            input[type="date"], select {
                width: 100%;
            }
        }
    </style>
</head>
<body>
    <div class="navbar">
        <h3>Teacher Panel - <%= username %></h3>
        <div class="nav-buttons">
            <a class="active" href="teacher_home.jsp">Take Attendance</a>
            <a href="teacher_report.jsp">View Report</a>
            <a href="logout.jsp">Logout</a>
        </div>
    </div>

    <div class="content">
        <h2>Take Attendance</h2>
        <form method="post" action="take_attendance.jsp">
            <label for="date"><b>Date:</b></label>
            <input type="date" name="date" id="date" value="<%= new java.sql.Date(System.currentTimeMillis()) %>" required>

            <label for="subject"><b>Subject:</b></label>
            <select name="subject" id="subject" required>
                <option value="">Select Subject</option>
                <%
                    try {
                    
                        Statement st = con.createStatement();
                        ResultSet rs = st.executeQuery("SELECT subject_name FROM subjects ORDER BY subject_name");
                        while (rs.next()) {
                %>
                <option value="<%= rs.getString("subject_name") %>"><%= rs.getString("subject_name") %></option>
                <%
                        }
                        con.close();
                    } catch (Exception e) {
                        out.println("<p style='color:red;'>Error loading subjects: " + e + "</p>");
                    }
                %>
            </select>

            <input type="submit" value="Start Attendance" class="btn">
        </form>
    </div>
</body>
</html>
