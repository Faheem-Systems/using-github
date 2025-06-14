#  Full DevOps Project : Spring Boot + Docker + GHCR + Terraform (Azure)

This project demonstrates a complete DevOps pipeline using:
- A Spring Boot Application
- Dockerization using Docker and GitHub Actions
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

#  3. GitHub Actions Workflow: `docker-app1.yml`
A CI workflow was created to:

1. Checkout code

2. Set up Java and Docker

3. Build Spring Boot project with Maven

4. Build Docker image

5. Push Docker image to GHCR (GitHub Container Registry)

---

### `docker-app1.yml`

```docker-app1.yml
name: Build and Push Docker Image

on:
  push:
    branches: [main]  # Trigger the workflow when pushing to the 'main' branch

permissions:
  contents: write    # Allow the action to write to the repository
  packages: write    # Allow the action to push Docker images to GitHub Container Registry

jobs:
  build:
    runs-on: ubuntu-latest  # Use the latest version of Ubuntu for the build environment

    steps:
      - name: Checkout code
        uses: actions/checkout@v3  # Checkout the code from the repository
      
      - name: Set up JDK 17
        uses: actions/setup-java@v3  # Set up Java 17 using the Temurin distribution
        with:
          distribution: 'temurin'  # Specify the JDK distribution (Temurin)
          java-version: '17'  # Set Java version to 17

      - name: Build project
        run: mvn clean install  # Build the project using Maven, install the dependencies

      - name: Log in to GitHub Container Registry
        uses: docker/login-action@v3  # Log in to GitHub Container Registry using Docker login action
        with:
          registry: ghcr.io  # Specify the GitHub Container Registry URL
          username: ${{ github.actor }}  # Use GitHub actor (username) for login
          password: ${{ secrets.GITHUB_TOKEN }}  # Use the GitHub token for authentication

      - name: Build and push Docker image
        run: |
          REPO_LOWER=$(echo "${{ github.repository }}" | tr '[:upper:]' '[:lower:]')  # Convert repository name to lowercase
          docker build -t ghcr.io/$REPO_LOWER:latest .  # Build the Docker image with the repository name in the tag
          docker push ghcr.io/$REPO_LOWER:latest  # Push the Docker image to GitHub Container Registry
```
---

# 4. Terraform Deployment for Spring Boot App on Azure


## Overview

This Terraform project automates the deployment of a **Spring Boot application** on **Microsoft Azure App** using:

- **Azure Resource Group** to group related resources.
- **Azure App Service Plan** to host the application as a web app.
- **Docker container images** stored in GitHub Container Registry (GHCR).

The Terraform scripts provision these Azure resources to enable smooth hosting of the app using Azure App Service.

---

## Key Components

| Component             | Description                                  |
|-----------------------|----------------------------------------------|
| Resource Group        | Logical container for Azure resources         |
| App Service Plan      | Compute resources to host the web application |
| Docker Image          | Containerized app stored in GitHub Container Registry |

---

## Prerequisites

- Azure subscription with appropriate permissions.
- GitHub Personal Access Token (PAT) with `read:packages` scope for GHCR authentication.
- Terraform CLI installed (version >= 1.0 recommended).
- Azure CLI installed and logged in.

---

## How It Works

1. Terraform creates an Azure resource group to organize resources.
2. It provisions an Azure App Service Plan to provide the hosting environment.
3. The Spring Boot app is deployed as a Docker container pulled from GitHub Container Registry using the provided credentials.
4. Terraform manages the lifecycle of these resources.

---

## Variables

The project uses several variables such as:

- `resource_group_name`: Name of the Azure resource group.
- `location`: Azure region (e.g., East US).
- `docker_image_name`: Docker image URL from GHCR.
- `docker_image_tag`: Docker image tag (e.g., latest).
- `ghcr_username`: GitHub username for GHCR.
- `ghcr_token`: GitHub PAT (sensitive).

See `variables.tf` for detailed descriptions.

---

## Usage

Sensitive variables such as GHCR credentials are passed via GitHub Actions Secrets using CLI `-var` flags during deployment. No terraform.tfvars file is needed.

---

## Terraform files

### `main.tf`
```
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0"
    }
  }
  required_version = ">= 1.0"
  backend "local" {}
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_app_service_plan" "plan" {
  name                = "springboot-app-plan"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  kind                = "Linux"
  reserved            = true

  sku {
    tier = "Basic"
    size = "B1"
  }
}

resource "azurerm_linux_web_app" "app" {
  name                = "springboot-webapp"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_app_service_plan.plan.id

  site_config {
    application_stack {
      docker_image = "${var.docker_image_name}:${var.docker_image_tag}"
    }
  }

  app_settings = {
    DOCKER_REGISTRY_SERVER_URL      = "https://ghcr.io"
    DOCKER_REGISTRY_SERVER_USERNAME = var.ghcr_username
    DOCKER_REGISTRY_SERVER_PASSWORD = var.ghcr_token
    WEBSITES_PORT                   = "8080"
  }
}
```
---
### `variable.tf`
```
variable "resource_group_name" {
  description = "Azure resource group name"
  type        = string
  default     = "springboot-rg"
}

variable "location" {
  description = "Azure location/region"
  type        = string
  default     = "East US"
}

variable "docker_image_name" {
  description = "Docker image repository URL (GHCR)"
  type        = string
}

variable "docker_image_tag" {
  description = "Docker image tag"
  type        = string
  default     = "latest"
}

variable "ghcr_username" {
  description = "GitHub username for GHCR auth"
  type        = string
}

variable "ghcr_token" {
  description = "GitHub Personal Access Token (PAT) with read:packages scope"
  type        = string
  sensitive   = true
}
```
---

### `output.tf`
```
output "web_app_url" {
  description = "Deployed Web App URL"
  value       = "https://${azurerm_linux_web_app.app.default_hostname}"
}
```
---

### `.github/workflows/terraform-deploy.yml`
```
name: Terraform Deploy to Azure

on:
  push:
    branches:
      - main

permissions:
  contents: read
  id-token: write

jobs:
  terraform:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repo
        uses: actions/checkout@v3

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: 1.5.7

      - name: Azure Login
        uses: azure/login@v1
        with:
          client-id: ${{ secrets.AZURE_CLIENT_ID }}
          tenant-id: ${{ secrets.AZURE_TENANT_ID }}
          subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
          client-secret: ${{ secrets.AZURE_CLIENT_SECRET }}

      - name: Terraform Init
        run: terraform init

      - name: Terraform Plan
        run: terraform plan \
          -var="ghcr_username=${{ secrets.GHCR_USERNAME }}" \
          -var="ghcr_token=${{ secrets.GHCR_TOKEN }}"

      - name: Terraform Apply
        run: terraform apply -auto-approve \
          -var="ghcr_username=${{ secrets.GHCR_USERNAME }}" \
          -var="ghcr_token=${{ secrets.GHCR_TOKEN }}"
```
---

##  Conclusion

This project demonstrates a complete DevOps lifecycle, starting from building a Spring Boot application to deploying it on Azure using infrastructure as code (Terraform) and automation (GitHub Actions). 

Key DevOps principles such as CI/CD, containerization, version control, secrets management, and cloud infrastructure provisioning were implemented and integrated successfully.

This setup ensures that the application can be reliably built, containerized, and deployed in a repeatable and scalable manner using modern DevOps practices.

---





