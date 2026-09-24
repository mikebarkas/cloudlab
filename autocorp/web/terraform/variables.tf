variable "subscription_id" {
  description = "The Azure subscription ID"
  type = string
}

variable "registry_server" {
  description = "This is the container registry"
  type = string
  default = "index.docker.io"
}
variable "registry_username" {
  description = "Authenticate to the container registry"
  type = string
}
variable "registry_passwd" {
  description = "Authenticate to the container registry"
  type = string
}

variable "container_name" {
  description = "The name for your container"
  type = string
}
variable "container_image" {
  description = "The image to use in the container"
  type = string
}

variable "api_url" {
  description = "An environment variable for the endpoint to the api"
  type = string
}
