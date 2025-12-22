terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.52"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

provider "proxmox" {
  endpoint  = var.proxmox_endpoint
  api_token = var.proxmox_api_token
  insecure  = true
}

# -----------------------------
# SSH Key
# -----------------------------
resource "tls_private_key" "traefik_container_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# -----------------------------
# Random root password
# -----------------------------
resource "random_password" "traefik_container_password" {
  length           = 16
  override_special = "_%@"
  special          = true
}

# -----------------------------
# Debian 13 LXC template
# -----------------------------
resource "proxmox_virtual_environment_file" "traefik_container_template" {
  content_type = "vztmpl"
  datastore_id = "local"
  node_name    = var.node

  source_file {
    path = "http://download.proxmox.com/images/system/debian-13-standard_13.1-2_amd64.tar.zst"
  }
}

# -----------------------------
# Traefik LXC
# -----------------------------
resource "proxmox_virtual_environment_container" "traefik" {
  description   = "Traefik LXC managed by Terraform"
  node_name     = var.node
  vm_id         = var.container_nbr
  started       = true
  unprivileged  = true


  initialization {
    hostname = "traefik"

    ip_config {
      ipv4 {
        address = "192.168.1.230/24"
	    gateway = "192.168.1.1"
      }
    }

    user_account {
      keys     = [tls_private_key.traefik_container_key.public_key_openssh]
      password = random_password.traefik_container_password.result
    }
  }

  network_interface {
    name   = "veth0"
    bridge = "vmbr0"
  }

  operating_system { 
    template_file_id = proxmox_virtual_environment_file.traefik_container_template.id 
    type = "debian" 
  }
  cpu {
    cores = 2
  }

  memory {
    dedicated = 512
    swap      = 512
  }

  disk {
    datastore_id = "local-lvm"
    size         = 4
  }

  features {
    nesting = true
  }
}

# -----------------------------
# Upload files + 
# Run bootstrap script using pct exec
# -----------------------------
resource "null_resource" "bootstrap_traefik" {
  depends_on = [
    proxmox_virtual_environment_container.traefik,
  ]

  provisioner "local-exec" {
    command = <<EOT
    pct push ${var.container_nbr} files/traefik.yml /root/traefik.yml
    pct push ${var.container_nbr} scripts/install-traefik.sh /root/install-traefik.sh
    pct exec ${var.container_nbr} -- bash /root/install-traefik.sh
    EOT
  }
}

# -----------------------------
# Outputs
# -----------------------------
output "traefik_container_password" {
  value     = random_password.traefik_container_password.result
  sensitive = true
}

output "traefik_container_private_key" {
  value     = tls_private_key.traefik_container_key.private_key_pem
  sensitive = true
}

output "traefik_container_public_key" {
  value = tls_private_key.traefik_container_key.public_key_openssh
}
