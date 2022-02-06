variable "appId" {
  description = "Azure Kubernetes Service Cluster service principal"
}

variable "password" {
  description = "Azure Kubernetes Service Cluster password"
}

variable "rg" {
  default = "rg-auto-demo-aks-01"
}

variable "cluster" {
  default = "cluster-auto-demo-aks-01"
}
