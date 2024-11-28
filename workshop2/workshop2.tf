provider "aws" {
  region     = "us-east-1"
  access_key = "ASIAWW7GLZWDKBIEC2MH"
  secret_key = "D02Q2C92YT6Fn1IABFPRXNGcDgEp9o4R/sqh1xWG"
  token      = "IQoJb3JpZ2luX2VjEKb//////////wEaCXVzLXdlc3QtMiJGMEQCHxEIGbbzG4qtIBa/YQ/sD5/iIbtDwD0RD24pcs5G3/gCIQDGNXuGVnomBrKfCayAiWrSGm23HqmrrxVbp4jXuiKrcCq0AghPEAAaDDQ2MTY1NTIzMTg3OCIM2mkJXhzP5OAvCsunKpECObItjq2S/xAp4wvREfnmbRGWpy7xKVjv68fDQFDrY75f/FIMLgdYRsdkPbPVpAz6c6KttetdRKm7vXAxb1TUIsIHAJpeNtyZiEZXnTqhqQ3h7SGf4W327M7AkeX/ekDNb2tV+mEByrfgKQmM6AYUGzow1rF7aKxE8PksN41ijDhcQ6BMvvnqY+KTZehHLhxwXUYtigY8RfN+LkZc0WoHuki0IkHtuqQdve8PHm+YFS91xFn3ws1CgUVUxbLg4XXGUNY7f5TrdDqRHkU2ILFBr4VM57OP6Q7KrwUKegp2myVSsyugfZgzvVpK1FibyEpWb02D7FkuYdSGh8+F6BqaD8BAj8vMYW7f/TlSzTE8lGpFMICvnroGOp4B++Y41bm3j8AKezSspfR1Wj443XM1qXRttdLmYNzcYvwFbVPLn68jnjq+ULPM4E0OWOy2nRLMCy3yj9BgYZph7hS3wibzZKxga75IOqCZdW3JR1tuDxRQIwX4WTF900wfuu7hy+aIRx80td217qH8FycmU7qZYphnkh61C4hBnG1yOdaJpui5y4408tMEds5WAHg3y2Iiugfoz2aHvZY="
}

# 1. Create a VPC
resource "aws_vpc" "web_server" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
}

# 2. Create an internet gateway
resource "aws_internet_gateway" "web_server_gw" {
  vpc_id = aws_vpc.web_server.id
}

# 3. Create a custom route table
resource "aws_route_table" "web_server_route_table" {
  vpc_id = aws_vpc.web_server.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.web_server_gw.id
  }
}

# 4. Create subnet
resource "aws_subnet" "web_server_subnet" {
  vpc_id = aws_vpc.web_server.id
  cidr_block = "10.0.0.0/24"
  map_public_ip_on_launch = true
}

# 5. Create Security groups
resource "aws_security_group" "web_server_security_group" {
  vpc_id      = aws_vpc.web_server.id
}

resource "aws_route_table_association" "web_server_route_assoc" {
  subnet_id      = aws_subnet.web_server_subnet.id
  route_table_id = aws_route_table.web_server_route_table.id
}

resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.web_server_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "allow_all_egress" {
  security_group_id = aws_security_group.web_server_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" 
}

# 6. Create an EC2 instance
resource "aws_instance" "web_server" {
  ami                         = "ami-0dba2cb6798deb6d8"
  instance_type               = "t2.micro"
  subnet_id = aws_subnet.web_server_subnet.id
  security_groups = [ aws_security_group.web_server_security_group.id ]

  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update
              sudo apt-get install -y apache2
              sudo systemctl start apache2
              sudo systemctl enable apache2
              echo "<h1>Hello World</h1>" | sudo tee /var/www/html/index.html
              EOF
}

# Output the public IP address of the instance
output "instance_public_ip" {
  value = aws_instance.web_server.public_ip
}
