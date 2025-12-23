# Traefik-terraform-template
Template for auto provisioning of traefik with terraform and proxmox 

## Files to fill out 

* `terraform.tfvars` : fill out with your variables
* `/files/traefik.yml` : add your traefik configuration 

## Building the container
1. Install terraform in your Proxmox server (on the main shell)
2. pull the repo 
3. edit your files 

4. Terraform init in the repo 
5. Terraform apply 
6. Sync your changes with your fork of the repo, IAC
