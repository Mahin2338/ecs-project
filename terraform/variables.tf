variable "az1" {
  type = string

}

variable "az2" {
  type = string

}



variable "db_username" {
  type      = string
  sensitive = true
}

variable "db_password" {
  type      = string
  sensitive = true

}