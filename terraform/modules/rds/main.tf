resource "aws_db_subnet_group" "main" {
    name = "umami-db-subnet-group"
    subnet_ids = var.private_subnet_ids
  

tags = {
  Name = "umami-db-subnet-group"
}


}


resource "aws_db_instance" "main" {
    identifier = "umami-db"
    engine = "postgres"
    engine_version = "16"
    instance_class = "db.t3.micro"
    allocated_storage = 20


    db_name = "umami"
    username = var.db_username
    password = var.db_password

    db_subnet_group_name = aws_db_subnet_group.main.name
    vpc_security_group_ids = [var.rds_sg_id]
  

    skip_final_snapshot = true

    tags = {
        Name = "Umami-db"
    }

}