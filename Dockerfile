# Step 1: Use official Java 17 base image with Maven included
FROM maven:3.9.6-eclipse-temurin-17-alpine AS build

WORKDIR /app

# Copy all files
COPY . .

# Give execute permission to the Maven wrapper script
RUN chmod +x mvnw

# Build the Spring Boot app
RUN ./mvnw clean package -DskipTests

# Step 2: Create final image with just the JAR file

FROM eclipse-temurin:17-jdk-alpine

WORKDIR /app

# Copy only the built JAR file from the previous stage
COPY --from=build /app/target/*.jar app.jar

#Expose port 8080 for application
EXPOSE 8080

#Run the application with the generated JAR file
CMD ["java", "-jar", "app.jar"]
