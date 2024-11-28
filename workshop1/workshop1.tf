// AWS Provider konfigurieren, Zugangsdaten und Region festlegen.
provider "aws" {
  region     = "us-east-1"
  access_key = "ASIAWW7GLZWDKBIEC2MH"
  secret_key = "D02Q2C92YT6Fn1IABFPRXNGcDgEp9o4R/sqh1xWG"
  token      = "IQoJb3JpZ2luX2VjEKb//////////wEaCXVzLXdlc3QtMiJGMEQCHxEIGbbzG4qtIBa/YQ/sD5/iIbtDwD0RD24pcs5G3/gCIQDGNXuGVnomBrKfCayAiWrSGm23HqmrrxVbp4jXuiKrcCq0AghPEAAaDDQ2MTY1NTIzMTg3OCIM2mkJXhzP5OAvCsunKpECObItjq2S/xAp4wvREfnmbRGWpy7xKVjv68fDQFDrY75f/FIMLgdYRsdkPbPVpAz6c6KttetdRKm7vXAxb1TUIsIHAJpeNtyZiEZXnTqhqQ3h7SGf4W327M7AkeX/ekDNb2tV+mEByrfgKQmM6AYUGzow1rF7aKxE8PksN41ijDhcQ6BMvvnqY+KTZehHLhxwXUYtigY8RfN+LkZc0WoHuki0IkHtuqQdve8PHm+YFS91xFn3ws1CgUVUxbLg4XXGUNY7f5TrdDqRHkU2ILFBr4VM57OP6Q7KrwUKegp2myVSsyugfZgzvVpK1FibyEpWb02D7FkuYdSGh8+F6BqaD8BAj8vMYW7f/TlSzTE8lGpFMICvnroGOp4B++Y41bm3j8AKezSspfR1Wj443XM1qXRttdLmYNzcYvwFbVPLn68jnjq+ULPM4E0OWOy2nRLMCy3yj9BgYZph7hS3wibzZKxga75IOqCZdW3JR1tuDxRQIwX4WTF900wfuu7hy+aIRx80td217qH8FycmU7qZYphnkh61C4hBnG1yOdaJpui5y4408tMEds5WAHg3y2Iiugfoz2aHvZY="
}

// Sicherheitsgruppe mit Beschreibung und zugehörigem VPC erstellen.
resource "aws_security_group" "web_sg" {
  name        = "web_sg"
  description = "Allow web traffic"
  vpc_id      = "vpc-0440f849564f91382"
}

// Regel für eingehenden HTTP-Verkehr (Port 80) aus allen IP-Adressen (0.0.0.0/0) hinzufügen.
resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.web_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

// Regel für ausgehenden Verkehr (alle Protokolle, 0.0.0.0/0) hinzufügen.
resource "aws_vpc_security_group_egress_rule" "allow_all_egress" {
  security_group_id = aws_security_group.web_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" 
}

// EC2-Instanz mit einer AMI, einer t2.micro-Instanz und einer öffentlichen IP starten.
resource "aws_instance" "web_server" {
  ami                         = "ami-0dba2cb6798deb6d8"
  instance_type               = "t2.micro"
  security_groups             = [aws_security_group.web_sg.name]
  associate_public_ip_address = true

// Apache installieren und eine einfache "Hello World"-Webseite einrichten
  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update
              sudo apt-get install -y apache2
              sudo systemctl start apache2
              sudo systemctl enable apache2
              echo "<h1>Hello World</h1>" | sudo tee /var/www/html/index.html
              EOF
}

// Öffentliche DNS-Adresse der EC2-Instanz als Output printen
output "public_dns" {
  value = aws_instance.web_server.public_dns
}
