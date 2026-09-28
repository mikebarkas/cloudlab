
variable "instance_type" {
  description = "The type of EC2 instance"
  type        = string
  default     = "t2.micro"
}

variable "availability_zone" {
  description = "The zone for the resource"
  type        = string
  default     = "us-east-1a"
}

variable "key_name" {
  description = "Associated SSH key name for this instance"
  type        = string
  default     = ""
  sensitive   = true
}

variable "tags" {
  description = "Tags to apply to the resource"
  type        = map(string)
  default = {
    Name      = "AutoCorp API"
    auto-corp = "demo"
  }
}

variable "admin_cidr" {
  description = "CIDR allowed to SSH to the instance, public IP as x.x.x.x/32"
  type        = string

  validation {
    condition     = can(cidrnetmask(var.admin_cidr))
    error_message = "admin_cidr must be an IPv4 CIDR, e.g. 203.0.113.10/32."
  }
}
