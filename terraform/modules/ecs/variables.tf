variable "database_url" {
    
    type = string
    sensitive = true
  
}

variable "private_subnet_ids" {
    type = list(string)
}

variable "ecs_security_group_id" {
  type = list(string)
}

variable "target_group_arn" {
  type = string
}

variable "image_url" {
  type = string
  
}