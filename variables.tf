variable "name" {}

variable "region" {}

variable "vpc_id" {}

variable "availability_zones" {}

variable "public_subnets" {}

variable "private_subnets" {}

variable "ami_id" {}

variable "instance_count" {
  default = "1"
}

variable "instance_type" {
  default = "t2.medium"
}

variable "maximum_number_of_instances" {
  default = 3
}

variable "minimum_number_of_instances" {
  default = 1
}

variable "number_of_instances" {
  default = 2
}

variable "rolling_update_bitch_size" {
  default = 1
}
