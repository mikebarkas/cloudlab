# Variables
variable "linode_token" {
  type      = string
  sensitive = true
}
variable "root_passwd" {
  type      = string
  sensitive = true
}
variable "instance_type" {
  type = string
}
variable "instance_image" {
  type = string
}
variable "instance_region" {
  type = string
}
variable "linode_public_key" {
  type      = string
  sensitive = true
}
variable "ansible_public_key" {
  type      = string
  sensitive = true
}
