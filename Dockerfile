#Add base image eclipse-temurin:17-jdk-alpine
FROM eclipse-temurin:17-jdk-alpine
#Set working directory to /app
WORKDIR /app
# Copy the JAR file only
COPY target/*.jar app.jar
#Expose port 8080 for application
EXPOSE 8080
#Run the application with the generated JAR file
CMD ["java", "-jar", "target/*.jar"]
