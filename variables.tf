variable "proxmox_api_token" {
  type      = string
  sensitive = true
}

variable "node" {
  default = "pve"
}

variable "proxmox_endpoint" {
  type        = string
  description = "Proxmox API endpoint"
}

variable "container_nbr" {
  default ="110"
}