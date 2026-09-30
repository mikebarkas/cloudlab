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

## Terraform Remote State

The AutoCorp API Terraform state is stored in an encrypted, versioned S3 bucket. The bucket is private and has S3 public access blocked. Terraform 1.10 or newer uses native S3 locking with `use_lockfile = true`.

### Bootstrap

Create the state bucket before initializing the API backend. The bootstrap configuration uses local state because the S3 backend cannot store its own state until the bucket exists.

The bucket must be in `us-east-1` and have:

- S3 versioning enabled
- Server-side encryption enabled
- All S3 public access blocked

After the bucket exists, migrate the API stack's existing local state:

```bash
cd autocorp/api/terraform
terraform init -migrate-state
terraform plan
```

The API state is stored at `autocorp/api/terraform.tfstate` in the S3 bucket. The Cloudflare stack reads the API output from that object through `terraform_remote_state`:


Never commit Terraform state, `.tfvars` files, credentials, or private keys. The S3 bucket name and backend key must match the values in the API and Cloudflare Terraform configurations.

## Design Decisions

Why things are built the way they are, and what each choice trades off.

### Terraform

- **One state file per stack** (`account/budget`, `account/github-oidc`, `autocorp/api`). Each stack plans and applies on its own, so a mistake in one can't touch the others.
- **S3 native locking (`use_lockfile = true`) instead of DynamoDB.** One less resource to create and pay for. Requires Terraform 1.11 or newer.
- **Bootstrap uses local state.** The state bucket can't store its own state before it exists.
- **Version pins: `required_version = ">= 1.11"` and AWS provider `~> 6.0`.** The Terraform lower bound is the minimum (native S3 locking), not the version I happen to run. The provider accepts any 6.x but never 7.0, so breaking major upgrades are a deliberate change. Lock files are committed so everyone, including CI, uses the exact same provider build.
- **AMI from a data source, filtered by Debian's AWS account ID.** Anyone can publish an image named `debian-12-*`; filtering on the owner guarantees the official image.
- **`ignore_changes = [ami]` on the instance.** With `most_recent = true`, every new Debian release would otherwise replace the server on the next apply. New instances get the latest image; existing ones are replaced on purpose with `terraform apply -replace`.
- **`default_tags` on the provider** instead of `tags` on every resource. New resources are tagged automatically, which keeps cost reports and resource searches complete.
- **t3.micro instead of t2.micro.** Newer generation and free tier eligible.

### Networking and security

- **Caddy reverse proxy on 443 in front of the API.** Caddy gets and renews Let's Encrypt certificates on its own. The API listens on 8080, which the security group does not expose.
- **SSH limited to one admin CIDR** instead of `0.0.0.0/0`. Trade-off: the rule needs updating when my IP changes.
- **One Elastic IP association**, via `aws_eip_association` on the network interface. Associating the same address in two places can cause drift between plans.

### CI/CD

- **GitHub Actions authenticates to AWS with OIDC.** No AWS access keys are stored anywhere; each run gets temporary credentials that expire in about an hour.
- **The plan role is read-only and trusted only for pull requests from this repo.** Its one write permission is the Terraform lock file in the state bucket, which `plan` needs. Apply will use a separate role behind a manual approval ([#30](https://github.com/mikebarkas/cloudlab/issues/30)), so a pull request can never change infrastructure.
- **Plans are posted as PR comments, with sensitive values hidden.** The repo is public and GitHub masks secrets in logs, not in comments. The admin CIDR and alert email are `sensitive` variables, and the workflow replaces the AWS account ID with `***` before posting.
- **tflint fails on warnings**, so unpinned providers or unused variables can't be merged.

### Cost

- **$25/month AWS Budget**, alerting at 50% and 80% of actual spend and 100% of forecasted spend. The forecast alert warns before the limit is reached, not after.

## Related repositories

- [auto-corp-api](https://github.com/mikebarkas/auto-corp-api): Go API application
- [auto-corp-web](https://github.com/mikebarkas/auto-corp-web): Python web front end
- [homelab](https://github.com/mikebarkas/homelab): Kubernetes (k3s) homelab running the same apps on premises
