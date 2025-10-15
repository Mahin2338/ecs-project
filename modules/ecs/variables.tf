variable "database_url" {
    
    type = string
  
}

variable "private_subnet_ids" {
    type = list(string)
}

variable "ecs_security_group_id" {
  type = list(string)
}