variable "location" {
  default = "centralus"
}

variable "rg_name" {
  default = "aks_demo"
}

variable "environment" {
  default = "test"
}

variable "vnet_name" {
  default = "demo_vnet"
}

variable "nsg_name" {
  default = "demo_nsg"
}

variable "app_subnet" {
  default = "demo_app_subnet"
}

variable "default_subnet" {
  default = "demo_default_subnet"
}

variable "ssh_public_key" {
  default = "~/.ssh/aks-prod-sshkeys-terraform/aksprodsshkey.pub"
}

variable "aks_name" {
  default = "aks_cluster"
}

