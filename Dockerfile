# Use official Tomcat image with JDK
FROM tomcat:9-jdk17-temurin

# Remove default ROOT app
RUN rm -rf /usr/local/tomcat/webapps/ROOT

# Copy your JSP project files into Tomcat webapps folder
COPY ./web /usr/local/tomcat/webapps/ROOT/

# Copy MySQL connector jar to Tomcat lib (for DB connectivity)
COPY ./web/WEB-INF/lib/mysql-connector-j-9.5.0.jar /usr/local/tomcat/lib/

# Expose port 8080
EXPOSE 8080

# Start Tomcat server
CMD ["catalina.sh", "run"]
