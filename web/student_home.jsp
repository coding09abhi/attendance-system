<%@ page import="java.sql.*, java.text.*" %>
<%@ include file="db.jsp" %>

<%
  Integer studentId = (Integer) session.getAttribute("student_id");
  String studentName = (String) session.getAttribute("student_name");
  Integer rollNo = (Integer) session.getAttribute("roll_no");

  if(studentId == null){
    response.sendRedirect("student_login.jsp");
    return;
  }
%>
<!DOCTYPE html>
<html>
<head>
  <title>Student Attendance </title>
   <link rel="icon" type="image/jpeg" href="images/favicon.jpg">
  <style>
    * {
      box-sizing: border-box;
    }

    body {
      margin: 0;
      padding: 0;
      font-family: "Poppins", sans-serif;
      background: #f9f9f9;
    }

    .header {
      background: #dd383e;
      color: white;
      padding: 18px 25px;
      display: flex;
      justify-content: space-between;
      align-items: center;
      box-shadow: 0 4px 10px rgba(0,0,0,0.2);
    }

    .header h2 {
      margin: 0;
      font-size: 20px;
    }

    .logout {
      background: white;
      color: #dd383e;
      text-decoration: none;
      padding: 8px 14px;
      border-radius: 8px;
      font-weight: bold;
      transition: all 0.3s ease;
    }

    .logout:hover {
      background: #ff6000;
      color: white;
      transform: scale(1.05);
    }

    .container {
      background: #fff;
      width: 90%;
      max-width: 1000px;
      margin: 60px auto;
      padding: 40px;
      border-radius: 12px;
      box-shadow: 0 6px 18px rgba(0, 0, 0, 0.15);
    }

    h3 {
      text-align: center;
      color: #dd383e;
      margin-bottom: 25px;
    }

    form {
      display: flex;
      justify-content: center;
      align-items: center;
      flex-wrap: wrap;
      gap: 15px;
      margin-bottom: 25px;
    }

    label {
      font-weight: 500;
      color: #333;
    }

    input[type="date"] {
      padding: 10px 15px;
      border-radius: 8px;
      border: 1px solid #ccc;
      font-size: 15px;
      outline: none;
      transition: border 0.3s ease, box-shadow 0.3s ease;
    }

    input[type="date"]:focus {
      border-color: #ff6000;
      box-shadow: 0 0 6px rgba(255,96,0,0.4);
    }

    button {
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

    button:hover {
      background: #ff6000;
      transform: scale(1.05);
    }

    table {
      width: 100%;
      border-collapse: collapse;
      margin-top: 20px;
      border-radius: 10px;
      overflow: hidden;
      box-shadow: 0 2px 8px rgba(0,0,0,0.1);
    }

    th {
      background: #dd383e;
      color: white;
      padding: 10px;
    }

    td {
      border: 1px solid #ddd;
      padding: 10px;
      text-align: center;
    }

    tr:nth-child(even) {
      background: #f9f9f9;
    }

    tr:hover {
      background: #ffe5e5;
    }

    h4 {
      text-align: center;
      color: #dd383e;
      margin-top: 25px;
    }

    p {
      text-align: center;
      color: #333;
      font-weight: 500;
    }

    @media (max-width: 768px) {
      .container {
        padding: 25px;
      }

      form {
        flex-direction: column;
      }

      button {
        width: 100%;
      }
    }
  </style>
</head>
<body>
  <div class="header">
    <h2>Welcome, <%= studentName %> (Roll No: <%= rollNo %>)</h2>
    <a href="student_logout.jsp" class="logout">Logout</a>
  </div>

  <div class="container">
    <h3>View Attendance</h3>
    <form method="post">
      <label>From Date:</label>
      <input type="date" name="from_date" required>
      <label>To Date:</label>
      <input type="date" name="to_date" required>
      <button type="submit">Show Attendance</button>
    </form>

    <%
      if(request.getMethod().equalsIgnoreCase("POST")){
        String fromDate = request.getParameter("from_date");
        String toDate = request.getParameter("to_date");

        int total = 0, present = 0;

        try{
           PreparedStatement ps = con.prepareStatement(
            "SELECT date, subject, status FROM attendance WHERE student_id=? AND date BETWEEN ? AND ? ORDER BY date");
          ps.setInt(1, studentId);
          ps.setString(2, fromDate);
          ps.setString(3, toDate);
          ResultSet rs = ps.executeQuery();

          out.println("<table><tr><th>Date</th><th>Subject</th><th>Status</th></tr>");
          while(rs.next()){
            String d = rs.getString("date");
            String sub = rs.getString("subject");
            String st = rs.getString("status");
            total++;
            if("P".equalsIgnoreCase(st)) present++;
            out.println("<tr><td>"+d+"</td><td>"+sub+"</td><td>"+(st.equals("P") ? "Present" : "Absent")+"</td></tr>");
          }
          out.println("</table>");

          if(total > 0){
            double avg = (present * 100.0) / total;
            out.println("<h4>Average Attendance: "+String.format("%.2f", avg)+"%</h4>");
          } else {
            out.println("<p style='color:red;'>No attendance data found for this range.</p>");
          }

          con.close();
        } catch(Exception e){
          out.println("<p style='color:red;'>Error: "+e+"</p>");
        }
      }
    %>
  </div>
</body>
</html>
