variable "project_id" {
  type = string
}

variable "region" {
  type    = string
  default = "us-central1"
}

variable "zone" {
  type    = string
  default = "us-central1-a"
}

variable "cluster_name" {
  type    = string
  default = "mission-status-gke"
}

variable "network_name" {
  type    = string
  default = "mission-status-vpc"
}

variable "subnet_name" {
  type    = string
  default = "mission-status-subnet"
}

variable "subnet_cidr" {
  type    = string
  default = "10.10.0.0/24"
}

variable "pods_cidr_name" {
  type    = string
  default = "gke-pods-range"
}

variable "services_cidr_name" {
  type    = string
  default = "gke-services-range"
}

variable "artifact_repo_name" {
  type    = string
  default = "mission-status"
}

variable "artifact_repo_location" {
  type    = string
  default = "us-central1"
}

variable "domain_name" {
  type    = string
  default = "app.kanedata.net"
}

variable "dns_zone_name" {
  type    = string
  default = "kanedata-net"
}
