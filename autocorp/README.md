# AutoCorp

Infrastructure for AutoCorp, a practice project built around a fictitious automobile company that provides sample data.

## What runs where

- **AWS:** one EC2 instance runs the whole app in Docker Compose: Caddy (TLS on 443), the Go API, the Python web app, and Postgres.
- **Cloudflare:** DNS records for the API and web subdomains point at the instance's Elastic IP.
- **Azure (not deployed):** `web/terraform` is an earlier version of the web app on Azure Container Instances, kept for reference.

## Directories

| Directory | Purpose |
|---|---|
| `api/terraform` | VPC, subnet, security group, EC2 instance, Elastic IP |
| `api/ansible` | Installs Docker and deploys the compose stack |
| `cloudflare` | DNS records |
| `web/terraform` | Earlier Azure deployment of the web app (not deployed) |
| `jenkins` | Jenkins server from the original auto-corp-infra repo |

Architecture, deploy order, costs, and design decisions are in the [main README](../README.md#autocorp-on-aws).

## Application repositories

- [auto-corp-api](https://github.com/mikebarkas/auto-corp-api): Go API with Postgres
- [auto-corp-web](https://github.com/mikebarkas/auto-corp-web): Python web front end

---

This project is for educational purposes only.
