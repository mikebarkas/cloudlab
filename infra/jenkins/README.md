# Jenkins Controller

The Jenkins controller is built with Terraform and provisioned with Ansible.

SSL termination is done with Nginx proxy and forwarded to Jenkins.

### Ansible

Set the vars needed in the jenkins role.

### Terraform

Create a `terraform.tfvars` file with the needed variables
