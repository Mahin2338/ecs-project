output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnets_ids" {
    value = [aws_subnet.public-a.id, aws_subnet.public-b.id]
  
}

output "private_subnets_ids" {
    value = [aws_subnet.private-a.id, aws_subnet.private-b.id]
  
}


