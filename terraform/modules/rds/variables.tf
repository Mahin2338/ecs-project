
variable "private_subnet_ids" {
    type = list(string)
}

variable "db_username" {
  type = string
  sensitive = true
  
}

variable "db_password" {
    type = string
    sensitive = true
  
}

variable "rds_sg_id" {
    type = string
}