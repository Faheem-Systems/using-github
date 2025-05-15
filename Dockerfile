# Use official Java 17 base image with Maven included
FROM maven:3.9.6-eclipse-temurin-17-alpine AS build

# Set working directory
WORKDIR /app

# Copy all source files
COPY . .

# Build the application (this creates the JAR in /app/target)
RUN ./mvnw clean package -DskipTests

# Step 2: Create final image with just the JAR file

FROM eclipse-temurin:17-jdk-alpine

WORKDIR /app

# Copy only the built JAR file from the previous stage
COPY --from=build /app/target/*.jar app.jar

# Expose port
EXPOSE 8080

# Run the application
CMD ["java", "-jar", "app.jar"]
