<%@ page import="java.sql.*" %>
<%@ include file="db.jsp" %>

<%
if (session.getAttribute("username") == null) {
    response.sendRedirect("login.jsp");
}

String date = request.getParameter("date");
String subject = request.getParameter("subject");
String username = (String) session.getAttribute("username");

if (date == null || subject == null) {
    response.sendRedirect("teacher_home.jsp");
}
%>

<!DOCTYPE html>
<html>
<head>
    <title>Mark Attendance</title>
    <link rel="stylesheet" href="style.css?v=<%= System.currentTimeMillis() %>">
    <style>
        body {
            margin: 0;
            padding: 0;
            font-family: "Poppins", sans-serif;
            background: #f9f9f9;
        }

        .content {
            background: #fff;
            width: 90%;
            max-width: 950px;
            margin: 40px auto;
            padding: 30px 40px;
            border-radius: 12px;
            box-shadow: 0 6px 18px rgba(0, 0, 0, 0.15);
        }

        h2 {
            text-align: center;
            color: #dd383e;
            margin-bottom: 20px;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 15px;
            border-radius: 10px;
            overflow: hidden;
            box-shadow: 0 0 6px rgba(0,0,0,0.1);
        }

        th {
            background: #dd383e;
            color: #fff;
            padding: 10px;
            font-size: 16px;
        }

        td {
            border: 1px solid #eee;
            padding: 10px;
            text-align: center;
            background: #fff;
            font-size: 15px;
        }

        tr:nth-child(even) td {
            background: #f7f7f7;
        }

        input[type="radio"] {
            accent-color: #ff6000;
            transform: scale(1.2);
        }

        .btn {
            background: #dd383e;
            color: white;
            border: none;
            padding: 12px 30px;
            border-radius: 8px;
            cursor: pointer;
            font-size: 15px;
            margin: 15px 5px 0;
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
            font-size: 15px;
        }

        form {
            text-align: center;
        }

        .message {
            font-weight: bold;
        }

        a.btn {
            text-decoration: none;
            display: inline-block;
        }

        /* Responsive design */
        @media (max-width: 768px) {
            .content {
                padding: 20px;
            }
            table, th, td {
                font-size: 13px;
            }
            .btn {
                width: 90%;
                margin: 10px 0;
            }
        }
    </style>
</head>
<body>
<div class="content">
    <h2>Mark Attendance - <%= subject %> (<%= date %>)</h2>

    <%
    try {
        
        PreparedStatement check = con.prepareStatement(
            "SELECT * FROM attendance WHERE date=? AND subject=?");
        check.setString(1, date);
        check.setString(2, subject);
        ResultSet checkRS = check.executeQuery();

        boolean attendanceExists = checkRS.isBeforeFirst();

        if (request.getParameter("save") != null) {
            PreparedStatement psStudents = con.prepareStatement("SELECT id FROM students WHERE division='B'");
            ResultSet rsStudents = psStudents.executeQuery();

            while (rsStudents.next()) {
                int id = rsStudents.getInt("id");
                String status = request.getParameter("status_" + id);

                if (attendanceExists) {
                    PreparedStatement upd = con.prepareStatement(
                        "UPDATE attendance SET status=?, marked_by=? WHERE student_id=? AND date=? AND subject=?");
                    upd.setString(1, status);
                    upd.setString(2, username);
                    upd.setInt(3, id);
                    upd.setString(4, date);
                    upd.setString(5, subject);
                    upd.executeUpdate();
                } else {
                    PreparedStatement ins = con.prepareStatement(
                        "INSERT INTO attendance(student_id, date, subject, status, marked_by) VALUES(?,?,?,?,?)");
                    ins.setInt(1, id);
                    ins.setString(2, date);
                    ins.setString(3, subject);
                    ins.setString(4, status);
                    ins.setString(5, username);
                    ins.executeUpdate();
                }
            }

            out.println("<p class='message' style='color:green;'>Attendance " + (attendanceExists ? "Updated" : "Saved") + " Successfully!</p>");
            out.println("<a href='teacher_home.jsp' class='btn'>Back to Home</a>");
            con.close();

        } else if (attendanceExists) {
            out.println("<p class='message' style='color:orange;'>Attendance already exists. You can edit it below:</p>");
            out.println("<form method='post'>");
            out.println("<table><tr><th>Roll No</th><th>Name</th><th>Status</th></tr>");

            PreparedStatement psStudents = con.prepareStatement(
                "SELECT s.id, s.roll_no, s.name, a.status FROM students s " +
                "LEFT JOIN attendance a ON s.id=a.student_id AND a.date=? AND a.subject=? " +
                "WHERE s.division='B' ORDER BY s.roll_no");
            psStudents.setString(1, date);
            psStudents.setString(2, subject);
            ResultSet rs = psStudents.executeQuery();

            while (rs.next()) {
                int id = rs.getInt("id");
                String name = rs.getString("name");
                int roll = rs.getInt("roll_no");
                String status = rs.getString("status");
                if (status == null) status = "P";

                out.println("<tr>");
                out.println("<td>" + roll + "</td>");
                out.println("<td>" + name + "</td>");
                out.println("<td>");
                out.println("<input type='radio' name='status_" + id + "' value='P'" + ("P".equals(status)?" checked":"") + "> P ");
                out.println("<input type='radio' name='status_" + id + "' value='A'" + ("A".equals(status)?" checked":"") + "> A");
                out.println("</td></tr>");
            }

            out.println("</table>");
            out.println("<input type='hidden' name='date' value='" + date + "'>");
            out.println("<input type='hidden' name='subject' value='" + subject + "'>");
            out.println("<input type='submit' name='save' value='Update Attendance' class='btn'>");
            out.println("<a href='teacher_home.jsp' class='btn'>Back</a>");
            out.println("</form>");
            con.close();

        } else {
            out.println("<form method='post'>");
            out.println("<table><tr><th>Roll No</th><th>Name</th><th>Status</th></tr>");

            PreparedStatement psStudents = con.prepareStatement(
                "SELECT id, roll_no, name FROM students WHERE division='B' ORDER BY roll_no");
            ResultSet rs = psStudents.executeQuery();
            while (rs.next()) {
                int id = rs.getInt("id");
                int roll = rs.getInt("roll_no");
                String name = rs.getString("name");

                out.println("<tr>");
                out.println("<td>" + roll + "</td>");
                out.println("<td>" + name + "</td>");
                out.println("<td>");
                out.println("<input type='radio' name='status_" + id + "' value='P' checked> P ");
                out.println("<input type='radio' name='status_" + id + "' value='A'> A");
                out.println("</td></tr>");
            }

            out.println("</table>");
            out.println("<input type='hidden' name='date' value='" + date + "'>");
            out.println("<input type='hidden' name='subject' value='" + subject + "'>");
            out.println("<input type='submit' name='save' value='Save Attendance' class='btn'>");
            out.println("</form>");
            con.close();
        }

    } catch(Exception e) {
        out.println("<p style='color:red;'>Error: " + e + "</p>");
    }
    %>
</div>
</body>
</html>
