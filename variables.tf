variable "name" {
  description = "Bastion Name"
}

variable "bastion_profile_name" {
  description = "Bastion profile Name"
  default     = "bastion-linux-profile"
}

variable "ssh_key_name" {
  description = "SSH Key Name"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  default     = {}
}

variable "bastion_tags" {
  description = "A map of tags to add to bastion"
  default     = {}
}

variable "policies" {
  description = "Policy to Instance Profile"
  default     = []
}

variable "instance_type" {
  description = "Instance type"
  default     = "t3.micro"
}

variable "subnet_id" {
  description = "Bastion Subnet"
}

variable "security_group_id" {
  description = "Security Group"
}

