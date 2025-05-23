#  Full DevOps CI Project: Spring Boot + Docker + GHCR + Terraform (Azure)

This project demonstrates a complete DevOps pipeline using:
- A Spring Boot Application
- Dockerization using GitHub Actions
- GitHub Container Registry (GHCR) for image hosting
- Terraform Infrastructure Provisioning on Azure via CI/CD

#  1. Spring Boot App Setup

###  Created Using [Spring Initializr](https://start.spring.io/)

- **Project**: Maven
- **Language**: Java
- **Spring Boot**: 3.4.5
- **Group**: `com.faheemsystems`
- **Artifact**: `App1`
- **Java Version**: 17
- **Dependencies**: Spring Web, Spring Boot Actuator

### Process of initializing the application folder and pushing to GitHub (local git):

  1. Navigate to the application folder in the terminal and run (Intialize git repository):

     **git init**
     
  3. Add files to staging area:

     **git add .**
     
  5. Commit the files:

     **git commit -m "Push App1 to GitHub"**
     
  7. Add GitHub remote:

     **git remote add origin https://github.com/Faheem-Systems/using-github.git**
     
  9. Push to GitHub

     **git push -u origin main**
     

---

#  2. Dockerization Using GitHub Actions
 A custom `Dockerfile` was added to the Spring Boot project root:
### `Dockerfile`
 ```Dockerfile
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

 # Expose port 8080 for application

  EXPOSE 8080

 # Run the application with the generated JAR file

  CMD ["java", "-jar", "app.jar"]


```

#  3. GitHub Actions Workflow: `docker.yml`
A CI workflow was created to:

1.Checkout code

2.Set up Java and Docker

3.Build Spring Boot project with Maven

4.Build Docker image

5.Push Docker image to GHCR
