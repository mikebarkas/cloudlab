terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

data "terraform_remote_state" "api" {
  backend = "s3"

  config = {
    bucket = "cloudlab-terraform-state-mikebarkas"
    key    = "autocorp/api/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "cloudflare" {
  api_token = var.api_token
}

resource "cloudflare_record" "api" {
  zone_id = var.zone_id
  name    = var.api-name
  content = data.terraform_remote_state.api.outputs["public-ip"]
  type    = var.type
  ttl     = 3600
  comment = "Points to AWS EC2"
}
