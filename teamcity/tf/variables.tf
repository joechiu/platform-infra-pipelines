variable "rg" {
  default = "db"
}

variable "prefix" {
  default = "mssql"
}

variable "postfix" {
  default = "nonprod"
}

variable "hosts" {
  default = "sql mssql"
}

variable "instance_count" {
  default = "1"
}

variable "vm_size" {
  description = "Standard_DS1_v2 / Standard_DS1_v2 / Standard_F2 / Standard_A4_v2"
  default = "Standard_DS1_v2"
}
variable "disk_type" {
  default = "Standard_LRS"
}

variable "location" {
  default = "australiaeast"
}

variable "vnet_cidr" {
  default = "10.4.0.0/16"
}

variable "subnet_cidr" {
  default = "10.4.0.0/24"
}

variable "sshdata" {
  description = "SSH key RSA data."
}

variable "tag" {
  default = "NonProd Infrastructure"
}
