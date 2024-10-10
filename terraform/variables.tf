variable "user_data_file_path" {
  type        = string
  description = "Path to the user data script"
  default = "user_data.sh"
}

variable "medium_instance_type" {
  type        = string
  description = "Medium EC2 instance type"
}

variable "large_instance_type" {
  type        = string
  description = "Large EC2 instance type"
}

variable "volume_size" {
  type        = number
  description = "Root volume size"
}

variable "volume_type" {
  type        = string
  description = "Root volume type"
  default = "gp2"
}

variable "key_name" {
  type        = string
  description = "Name of the key pair to use for the instance"
}

variable "tag_suffix" {
  type        = string
  description = "Suffix to append to all tags"
}