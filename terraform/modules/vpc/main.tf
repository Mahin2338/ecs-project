 resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true


tags = {
    Name = "umami-vpc"
}
}


resource "aws_subnet" "public-a" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = var.az1
  map_public_ip_on_launch = true

  tags = {
    Name = "Public-subnet-a"
  }
}

resource "aws_subnet" "public-b" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  availability_zone = var.az2
  map_public_ip_on_launch = true

  tags = {
    Name = "Public-subnet-b"
  }
}

resource "aws_subnet" "private-a" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.3.0/24"
  availability_zone = var.az1

  tags = {
    Name = "Private-subnet-b"
  }
}

resource "aws_subnet" "private-b" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.4.0/24"
  availability_zone = var.az2

  tags = {
    Name = "Private-subnet-b"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-igw"
  }
}

resource "aws_eip" "nat" {
  domain   = "vpc"

  tags = {

    Name = "eip-nat"
  }


}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public-a.id

  tags = {
    Name = "gw NAT"
  
}
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }


  tags = {
    Name = "public-route-table"
  }
}


resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id  = aws_nat_gateway.main.id
  }


  tags = {
    Name = "private-route-table"
  }
}


resource "aws_route_table_association" "public-a" {
  subnet_id      = aws_subnet.public-a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public-b" {
  subnet_id      = aws_subnet.public-b.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private-a" {
  subnet_id      = aws_subnet.private-a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "privtae-b" {
  subnet_id      = aws_subnet.private-b.id
  route_table_id = aws_route_table.private.id
}


