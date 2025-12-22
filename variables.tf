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

variable "container_ip" {
  default ="192.168.1.230/24"
}

variable "container_gateway"{
  default ="192.168.1.1"
}

variable "mem_dedicated" {
  default =512
}

variable "mem_swap" {
  default =512
}

variable "cpu_cores" {
  default =2
}

variable "disk_datastore_id" {
  default="local-lvm"
}

variable "disk_size"{
  default=4
}

variable "hostname"{
  default ="Traefik"
}