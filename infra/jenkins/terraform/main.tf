terraform {
  required_providers {
    linode = {
      source  = "linode/linode"
      version = "2.9.1"
    }
  }
}

provider "linode" {
  token = var.linode_token
}

resource "linode_instance" "jenkins" {
  image           = var.instance_image
  label           = "Jenkins"
  group           = "Jenkins"
  region          = var.instance_region
  type            = var.instance_type
  authorized_keys = [var.ansible_public_key]
  root_pass       = var.root_passwd
  #booted          = false
}

resource "linode_firewall" "jenkins_server" {
  inbound_policy  = "DROP"
  label           = "Jenkins"
  outbound_policy = "ACCEPT"

  inbound {
    action   = "ACCEPT"
    label    = "allow-https"
    ports    = "443"
    protocol = "TCP"
    ipv4     = ["0.0.0.0/0"]
    ipv6     = ["::/0"]
  }
  inbound {
    action   = "ACCEPT"
    label    = "allow-ssh"
    ports    = "22"
    protocol = "TCP"
    ipv4     = ["0.0.0.0/0"]
    ipv6     = ["::/0"]
  }

  linodes = [linode_instance.jenkins.id]
}

