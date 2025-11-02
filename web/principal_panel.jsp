<%@ page import="java.sql.*" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.util.Calendar" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ include file="db.jsp" %>


<%
    if (session.getAttribute("username") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String username = (String) session.getAttribute("username");

    String today;
    String selectedDateParam = request.getParameter("date");
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
    sdf.setLenient(false);
    try {
        if (selectedDateParam != null && !selectedDateParam.isEmpty()) {
            sdf.parse(selectedDateParam); // validate date
            today = selectedDateParam;
        } else {
            today = sdf.format(new Date());
        }
    } catch (Exception e) {
        today = sdf.format(new Date());
        request.setAttribute("invalidDate", true);
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Principal Panel - Attendance Overview</title>
    <link rel="stylesheet" href="style.css?v=<%= System.currentTimeMillis() %>">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
     <link rel="icon" type="image/jpeg" href="images/favicon.jpg">

    <style>
        body {
            font-family: 'Poppins', sans-serif;
            background-color: #fdfdfd;
            margin: 0;
            padding: 0;
        }

        .navbar {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            background-color: #dd383e;
            color: white;
            padding: 12px 25px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            z-index: 1000;
            box-shadow: 0px 2px 6px rgba(0,0,0,0.1);
        }

        .navbar h3 {
            color: white;
            margin: 0;
            font-weight: 600;
        }

        .nav-buttons a {
            background-color: #dd383e;
            color: white;
            margin-left: 10px;
            text-decoration: none;
            font-weight: 500;
            padding: 8px 14px;
            border-radius: 6px;
            display: inline-block;
            transition: all 0.3s ease;
        }

        .nav-buttons a:hover {
            background-color: #ff6000;
            color: white;
        }

        .content {
            margin-top: 110px;
            padding: 0 25px;
        }

        .date-selector {
            margin: 20px 25px;
            padding: 10px;
            background: #fff;
            box-shadow: 0 1px 4px rgba(0,0,0,0.1);
            border-radius: 8px;
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 12px;
        }

        .date-selector label {
            font-weight: 500;
            color: #333;
        }

        input[type="date"] {
            padding: 8px 12px;
            border: 1px solid #ccc;
            border-radius: 6px;
            font-size: 14px;
            outline: none;
        }

        button {
            background-color: #dd383e;
            color: white;
            border: none;
            cursor: pointer;
            font-weight: 500;
            padding: 8px 16px;
            border-radius: 6px;
            transition: 0.3s;
        }

        button:hover {
            background-color: #ff6000;
        }

        h2, h3 {
            margin-top: 25px;
            color: #333;
            text-align: center;
        }

        .report-table {
            border-collapse: collapse;
            width: 90%;
            margin: 20px auto;
            background: white;
            box-shadow: 0px 2px 8px rgba(0,0,0,0.1);
        }

        .report-table th {
            background-color: #dd383e;
            color: white;
            padding: 10px;
        }

        .report-table td {
            border: 1px solid #ddd;
            padding: 8px;
            text-align: center;
        }

        .report-table tr:nth-child(even) {
            background-color: #f9f9f9;
        }

        .chart-container {
            width: 70%;
            margin: 30px auto;
            height: 230px;
        }

        p {
            text-align: center;
        }
    </style>
</head>
<body>

<div class="navbar">
    <h3>Principal Panel - <%= username %></h3>
    <div class="nav-buttons">
        <a href="teacher_report.jsp">Teacher Report</a>
        <a href="principal_panel.jsp" class="active">Overview</a>
        <a href="logout.jsp">Logout</a>
    </div>
</div>

<div class="content">
    <div class="date-selector">
        <form method="get" action="principal_panel.jsp">
            <label for="date">Select Date:</label>
            <input type="date" id="date" name="date" value="<%= today %>">
            <button type="submit">View</button>
        </form>
    </div>

    <% if (request.getAttribute("invalidDate") != null) { %>
        <p style="color:red;text-align:center;">Invalid date selected. Showing today's data instead.</p>
    <% } %>

    <h2>Attendance Overview for <%= today %></h2>

    <%
    try {
        out.println("<table class='report-table'>");
        out.println("<tr><th>Subject</th><th>Total Students</th><th>Present</th><th>Absent</th><th>Status</th></tr>");

        PreparedStatement subPS = con.prepareStatement("SELECT subject_name FROM subjects ORDER BY subject_name");
        ResultSet subRS = subPS.executeQuery();

        while (subRS.next()) {
            String sub = subRS.getString("subject_name");

            PreparedStatement ps = con.prepareStatement(
                "SELECT COUNT(DISTINCT student_id) AS total, SUM(status='P') AS present, SUM(status='A') AS absent FROM attendance WHERE date=? AND subject=?");
            ps.setString(1, today);
            ps.setString(2, sub);
            ResultSet rs = ps.executeQuery();

            int total = 0, present = 0, absent = 0;
            if (rs.next()) {
                total = rs.getInt("total");
                present = rs.getInt("present");
                absent = rs.getInt("absent");
            }

            String status = (total > 0) ? "Taken" : "Not Taken";

            out.println("<tr>");
            out.println("<td>" + sub + "</td>");
            out.println("<td>" + (total > 0 ? total : "-") + "</td>");
            out.println("<td>" + (total > 0 ? present : "-") + "</td>");
            out.println("<td>" + (total > 0 ? absent : "-") + "</td>");
            out.println("<td style='color:" + (status.equals("Taken") ? "green" : "orange") + ";'>" + status + "</td>");
            out.println("</tr>");

            rs.close();
            ps.close();
        }
        subRS.close();
        subPS.close();
        out.println("</table>");

        PreparedStatement countSubPS = con.prepareStatement("SELECT COUNT(*) AS cnt FROM subjects");
        ResultSet countSubRS = countSubPS.executeQuery();
        int totalSubjects = 0;
        if (countSubRS.next()) {
            totalSubjects = countSubRS.getInt("cnt");
        }
        countSubRS.close();
        countSubPS.close();

        out.println("<h3>Whole-Day Absent Students (absent in all " + totalSubjects + " subjects)</h3>");

        PreparedStatement psWhole = con.prepareStatement(
            "SELECT s.roll_no, s.name FROM students s WHERE s.id IN (SELECT a.student_id FROM attendance a WHERE a.date=? AND a.status='A' GROUP BY a.student_id HAVING COUNT(DISTINCT a.subject) = ?) ORDER BY s.roll_no");
        psWhole.setString(1, today);
        psWhole.setInt(2, totalSubjects);
        ResultSet rsWhole = psWhole.executeQuery();

        if (!rsWhole.isBeforeFirst()) {
            out.println("<p style='color:green;'>No whole-day absentees today ?</p>");
        } else {
            out.println("<table class='report-table'><tr><th>Roll No</th><th>Name</th></tr>");
            while (rsWhole.next()) {
                out.println("<tr><td>" + rsWhole.getInt("roll_no") + "</td><td>" + rsWhole.getString("name") + "</td></tr>");
            }
            out.println("</table>");
        }
        rsWhole.close();
        psWhole.close();

        // ? Fix: correct number of days in month
        Calendar cal = Calendar.getInstance();
        int year = cal.get(Calendar.YEAR);
        int month = cal.get(Calendar.MONTH) + 1;
        cal.set(Calendar.DAY_OF_MONTH, 1);
        int daysInMonth = cal.getActualMaximum(Calendar.DAY_OF_MONTH);

        List<Integer> daysList = new ArrayList<>();
        List<Double> presentPercentList = new ArrayList<>();

        for (int d = 1; d <= daysInMonth; d++) {
            daysList.add(d);
            String dayStr = String.format("%04d-%02d-%02d", year, month, d);
            PreparedStatement psDay = con.prepareStatement(
                "SELECT COUNT(*) AS total, SUM(status='P') AS present FROM attendance WHERE date=?");
            psDay.setString(1, dayStr);
            ResultSet rsDay = psDay.executeQuery();

            int totDay = 0, presDay = 0;
            if (rsDay.next()) {
                totDay = rsDay.getInt("total");
                presDay = rsDay.getInt("present");
            }
            rsDay.close();
            psDay.close();

            double percent = (totDay > 0) ? (presDay * 100.0 / totDay) : 0.0;
            presentPercentList.add(percent);
        }

        con.close();
    %>

    <div class="chart-container">
        <canvas id="attendanceChart"></canvas>
    </div>

    <script>
        const ctx = document.getElementById('attendanceChart').getContext('2d');
        const labels = <%= daysList.toString() %>;
        const dataVals = <%= presentPercentList.toString() %>;
        new Chart(ctx, {
            type: 'bar',
            data: {
                labels: labels,
                datasets: [{
                    label: 'Attendance %',
                    data: dataVals,
                    backgroundColor: '#dd383e',
                    borderColor: '#ff6000',
                    borderWidth: 1
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                scales: { y: { beginAtZero: true, max: 100 } },
                plugins: {
                    legend: { display: false },
                    tooltip: { callbacks: { label: ctx => ctx.parsed.y + '%' } }
                }
            }
        });
    </script>

    <%
    } catch (Exception e) {
        out.println("<p style='color:red;'>Error: " + e + "</p>");
    }
    %>
</div>

</body>
</html>
