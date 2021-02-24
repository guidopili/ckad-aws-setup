variable "aws_region" {
  type = string
}

variable "pubkey" {
  type = string
}

variable "name" {
  type = string
}

variable "minions_count" {
  type    = number
  default = 1
}

variable "master_instance_type" {
  type    = string
  default = "t3a.large"
}

variable "minion_instance_type" {
  type    = string
  default = "t3a.large"
}

variable "create_hosts_file" {
  type = bool
  default = true
}
