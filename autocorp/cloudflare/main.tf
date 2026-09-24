terraform {
  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

data "terraform_remote_state" "api" {
  backend = "local"

  config = {
    path = "../api/terraform/terraform.tfstate"
  }
}

provider "cloudflare" {
  api_token = var.api_token
}

resource "cloudflare_record" "api" {
  zone_id = var.zone_id
  name = var.api-name
  content = data.terraform_remote_state.api.outputs["public-ip"]
  type = var.type
  ttl = 3600
  comment = "Points to AWS EC2"
}
