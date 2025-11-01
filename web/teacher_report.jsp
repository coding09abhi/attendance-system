<%@ page import="java.sql.*,javax.servlet.*,javax.servlet.http.*" %>
<%@ include file="db.jsp" %>
<%
    // ? Prevent direct access without login
    if (session == null || session.getAttribute("username") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    String username = (String) session.getAttribute("username");
%>
<!DOCTYPE html>
<html>
    <head>
        <title>Teacher Panel</title>
        <link rel="stylesheet" href="style.css?v=<%= System.currentTimeMillis()%>">
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

            .nav-buttons a.active {
                background-color: #ff6000;
                color: white;
                font-weight: 600;
            }

            .content {
                background: #fff;
                width: 90%;
                max-width: 1000px;
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
                text-align: center;
                margin-bottom: 25px;
            }

            input[type="date"] {
                padding: 10px 15px;
                border-radius: 8px;
                border: 1px solid #ccc;
                font-size: 15px;
                outline: none;
                margin-right: 10px;
                transition: border 0.3s ease;
            }

            input[type="date"]:focus {
                border-color: #ff6000;
                box-shadow: 0 0 6px rgba(255,96,0,0.4);
            }

            .btn {
                background: #dd383e;
                color: white;
                border: none;
                padding: 10px 20px;
                border-radius: 8px;
                cursor: pointer;
                font-size: 15px;
                font-weight: bold;
                transition: background 0.3s ease, transform 0.2s;
            }

            .btn:hover {
                background: #ff6000;
                transform: scale(1.05);
            }

            .view-btn {
                padding: 5px 10px;
                background-color: #007bff;
                color: white;
                border: none;
                border-radius: 5px;
                cursor: pointer;
                font-size: 13px;
                transition: background 0.3s ease;
            }

            .view-btn:hover {
                background-color: #0056b3;
            }

            .report-table {
                border-collapse: collapse;
                width: 100%;
                background: white;
                margin-top: 10px;
                border-radius: 10px;
                overflow: hidden;
                box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            }

            .report-table th {
                background: #dd383e;
                color: white;
                padding: 10px;
            }

            .report-table td {
                border: 1px solid #ddd;
                padding: 10px;
            }

            .report-table tr:nth-child(even) {
                background: #f9f9f9;
            }

            .report-table tr:hover {
                background: #ffe5e5;
            }

            h3 {
                margin-top: 30px;
                color: #dd383e;
            }

            h4 {
                color: #333;
            }

            p {
                text-align: center;
                color: #333;
            }

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
                .report-table {
                    font-size: 14px;
                }
            }
        </style>
    </head>
    <body>
        <div class="navbar">
            <h3>Teacher Panel - <%= username%></h3>
            <div class="nav-buttons">
                <a href="teacher_home.jsp">Take Attendance</a>
                <a class="active" href="teacher_report.jsp">View Report</a>
                <a href="logout.jsp">Logout</a>
            </div>
        </div>

        <div class="content">
            <h2>View Attendance Report</h2>
            <form method="post">
                <label for="rdate"><b>Select Date:</b></label>
                <input type="date" name="rdate" id="rdate" required>
                <input type="submit" name="show" value="Show Report" class="btn">
            </form>

            <%
                if (request.getParameter("show") != null || request.getParameter("showAbsent") != null) {
                    String rdate = request.getParameter("rdate");
                    String showSub = request.getParameter("subject");

                    try {
                       
                        // Fetch subjects
                        PreparedStatement subPS = con.prepareStatement("SELECT subject_name FROM subjects ORDER BY subject_name");
                        ResultSet subRS = subPS.executeQuery();

                        boolean anyTaken = false;
                        out.println("<table class='report-table'>");
                        out.println("<tr><th>Subject</th><th>Total</th><th>Present</th><th>Absent</th><th>Status</th></tr>");

                        while (subRS.next()) {
                            String sub = subRS.getString("subject_name");

                            PreparedStatement ps = con.prepareStatement(
                                    "SELECT COUNT(*) AS total, SUM(status='P') AS present, SUM(status='A') AS absent "
                                    + "FROM attendance WHERE date=? AND subject=?");
                            ps.setString(1, rdate);
                            ps.setString(2, sub);
                            ResultSet rs = ps.executeQuery();

                            if (rs.next()) {
                                int total = rs.getInt("total");
                                if (total == 0) {
                                    out.println("<tr><td>" + sub + "</td><td>-</td><td>-</td><td>-</td><td style='color:orange;'>Not Taken</td></tr>");
                                } else {
                                    anyTaken = true;
                                    int present = rs.getInt("present");
                                    int absent = rs.getInt("absent");

                                    out.println("<tr>");
                                    out.println("<td>" + sub + "</td>");
                                    out.println("<td>" + total + "</td>");
                                    out.println("<td>" + present + "</td>");
                                    out.println("<td>" + absent
                                            + "<form style='display:inline;' method='get' action='teacher_report.jsp'>"
                                            + "<input type='hidden' name='rdate' value='" + rdate + "'>"
                                            + "<input type='hidden' name='subject' value='" + sub + "'>"
                                            + "<input type='hidden' name='showAbsent' value='1'>"
                                            + "<button type='submit' class='view-btn'>View</button>"
                                            + "</form></td>");
                                    out.println("<td style='color:green;'>Taken</td>");
                                    out.println("</tr>");
                                }
                            }
                        }
                        out.println("</table><br>");

                        // Subject-specific absent list
                        if (request.getParameter("showAbsent") != null && showSub != null) {
                            out.println("<h3>Absent Students for " + showSub + " on " + rdate + "</h3>");
                            PreparedStatement ps3 = con.prepareStatement(
                                    "SELECT s.roll_no, s.name FROM students s "
                                    + "JOIN attendance a ON s.id=a.student_id "
                                    + "WHERE a.date=? AND a.subject=? AND a.status='A' ORDER BY s.roll_no");
                            ps3.setString(1, rdate);
                            ps3.setString(2, showSub);
                            ResultSet rs3 = ps3.executeQuery();

                            if (!rs3.isBeforeFirst()) {
                                out.println("<p style='color:green;'>No absentees for this subject.</p>");
                            } else {
                                out.println("<table class='report-table'><tr><th>Roll No</th><th>Name</th></tr>");
                                while (rs3.next()) {
                                    out.println("<tr><td>" + rs3.getInt("roll_no") + "</td><td>" + rs3.getString("name") + "</td></tr>");
                                }
                                out.println("</table><br>");
                            }
                        }

                        // Whole-day absentees
                        if (anyTaken) {
                            PreparedStatement psSubjects = con.prepareStatement("SELECT COUNT(*) AS total_subjects FROM subjects");
                            ResultSet rsSubjects = psSubjects.executeQuery();
                            int totalSubjects = 0;
                            if (rsSubjects.next()) {
                                totalSubjects = rsSubjects.getInt("total_subjects");
                            }

                            PreparedStatement psWholeDay = con.prepareStatement(
                                    "SELECT s.roll_no, s.name "
                                    + "FROM students s "
                                    + "WHERE s.id IN ( "
                                    + "    SELECT student_id "
                                    + "    FROM attendance "
                                    + "    WHERE date=? AND status='A' "
                                    + "    GROUP BY student_id "
                                    + "    HAVING COUNT(DISTINCT subject) = ? "
                                    + ") "
                                    + "ORDER BY s.roll_no");
                            psWholeDay.setString(1, rdate);
                            psWholeDay.setInt(2, totalSubjects);
                            ResultSet rsWholeDay = psWholeDay.executeQuery();

                            out.println("<h3>Whole-day Absent Students (" + rdate + ")</h3>");
                            if (!rsWholeDay.isBeforeFirst()) {
                                out.println("<p style='color:green;'>No whole-day absentees.</p>");
                            } else {
                                out.println("<table class='report-table'><tr><th>Roll No</th><th>Name</th></tr>");
                                while (rsWholeDay.next()) {
                                    out.println("<tr><td>" + rsWholeDay.getInt("roll_no") + "</td><td>" + rsWholeDay.getString("name") + "</td></tr>");
                                }
                                out.println("</table>");
                            }

                            PreparedStatement avgPS = con.prepareStatement(
                                    "SELECT (SUM(status='P') / COUNT(*)) * 100 AS avg_percent FROM attendance WHERE date=?");
                            avgPS.setString(1, rdate);
                            ResultSet avgRS = avgPS.executeQuery();
                            if (avgRS.next()) {
                                double avg = avgRS.getDouble("avg_percent");
                                out.println("<h4>Average Attendance for the Day: " + String.format("%.2f", avg) + "%</h4>");
                            }
                        } else {
                            out.println("<p style='color:red;'>No attendance taken on this date.</p>");
                        }

                        con.close();
                    } catch (Exception e) {
                        out.println("<p style='color:red;'>Error: " + e + "</p>");
                    }
                }
            %>
        </div>
    </body>
</html>
