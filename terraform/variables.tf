variable "pubkey_path" {
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
