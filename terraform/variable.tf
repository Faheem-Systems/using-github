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
