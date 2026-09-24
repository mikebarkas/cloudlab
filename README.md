# cloudlab

This repo contains the configuration and apps I use for learning and experimenting with cloud platforms.

Most projects are built with Terraform and provisioned with Ansible.

Hybrid cloud infrastructure combines my cloudlab and homelab.

## Cloud Providers
I primarily use AWS for most projects and for practicing for certifications. I also like to use Linode services. Some of my projects run containers in Azure as well.

## Projects

| Project | Description | Tools | Status |
|---|---|---|---|
| [AutoCorp](autocorp/) | Go API and Postgres on EC2, with DNS records managed in Cloudflare. Moved here from `auto-corp-infra` with its full history. | Terraform, Ansible, Docker, Cloudflare | Active |
| [Jenkins](infra/jenkins/) | Jenkins controller behind an Nginx reverse proxy on a Linux server | Terraform, Ansible, Linode | Complete |

### Planned

- **Remote state:** Terraform state in S3 with native locking
- **CI for infrastructure:** GitHub Actions runs `fmt`, `validate`, and `plan` on every pull request, authenticating to AWS through OIDC with no stored keys
- **Cost guardrails:** AWS Budgets alarm, managed in Terraform
- **[aws-ops-assistant](https://github.com/mikebarkas/aws-ops-assistant):** MCP server and daily AI briefing that reports on this lab's costs, resources, alarms, and logs

### Related repositories

- [auto-corp-api](https://github.com/mikebarkas/auto-corp-api): Go API application
- [auto-corp-web](https://github.com/mikebarkas/auto-corp-web): Python web front end
- [homelab](https://github.com/mikebarkas/homelab): Kubernetes (k3s) homelab running the same apps on premises
