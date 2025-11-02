<%@ page import="java.sql.*" %>
<%@ include file="db.jsp" %>
<!DOCTYPE html>
<html>
<head>
    <title>Student Login</title>
    <link rel="icon" type="image/jpeg" href="images/favicon.jpg">
    <style>
        * {
            box-sizing: border-box; /* Fix alignment issue */
        }

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
            justify-content: center;
            align-items: center;
            box-shadow: 0 4px 10px rgba(0,0,0,0.2);
        }

        .navbar h3 {
            margin: 0;
            font-size: 22px;
        }

        .login-container {
            width: 350px;
            background: #fff;
            margin: 100px auto;
            padding: 40px 30px;
            border-radius: 12px;
            box-shadow: 0 6px 18px rgba(0,0,0,0.15);
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

        input {
            width: 100%;
            padding: 12px 14px;
            margin-bottom: 15px;
            border-radius: 8px;
            border: 1px solid #ccc;
            outline: none;
            font-size: 15px;
            transition: border 0.3s ease, box-shadow 0.3s ease;
        }

        input:focus {
            border-color: #ff6000;
            box-shadow: 0 0 6px rgba(255,96,0,0.4);
        }

        button {
            width: 100%;
            padding: 12px;
            background: #dd383e;
            color: #fff;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            font-size: 16px;
            font-weight: bold;
            transition: background 0.3s ease, transform 0.2s;
        }

        button:hover {
            background: #ff6000;
            transform: scale(1.03);
        }

        p {
            text-align: center;
            color: red;
            margin-top: 15px;
        }

        @media (max-width: 768px) {
            .login-container {
                width: 85%;
                padding: 30px 20px;
            }
        }
    </style>
</head>
<body>
    <div class="navbar">
        <h3>Student Login Panel</h3>
    </div>

    <div class="login-container">
        <h2>Login</h2>
        <form method="post">
            <input type="number" name="roll_no" placeholder="Enter Roll Number" required>
            <input type="text" name="division" placeholder="Enter Division" required>
            <button type="submit">Login</button>
        </form>

        <%
            if(request.getMethod().equalsIgnoreCase("POST")){
                int roll = Integer.parseInt(request.getParameter("roll_no"));
                String div = request.getParameter("division");

                try{
               
                    PreparedStatement ps = con.prepareStatement("SELECT * FROM students WHERE roll_no=? AND division=?");
                    ps.setInt(1, roll);
                    ps.setString(2, div);
                    ResultSet rs = ps.executeQuery();

                    if(rs.next()){
                        session.setAttribute("student_id", rs.getInt("id"));
                        session.setAttribute("student_name", rs.getString("name"));
                        session.setAttribute("roll_no", roll);
                        response.sendRedirect("student_home.jsp");
                    } else {
                        out.println("<p>Invalid Roll Number or Division!</p>");
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
