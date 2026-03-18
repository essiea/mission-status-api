variable "cluster_name" {
  type = string
}

variable "cluster_version" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}

variable "desired_size" {
  type = number
}

variable "min_size" {
  type = number
}

variable "max_size" {
  type = number
}

variable "instance_types" {
  type = list(string)
}
