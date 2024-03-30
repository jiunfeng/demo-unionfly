# DMZ 允許的IP
variable "allowed_dms_ip" {
  type    = list(string)
  default = ["1.168.131.38/32"] #測試用 IP限制 
}

variable "dmz_instance_key" {
  type    = string
  default = "mackey" #ssh

}

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = "ap-southeast-1"
}

#create VPC
resource "aws_vpc" "demo_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "main_vpc"
  }
}

#create Internet Gateway
resource "aws_internet_gateway" "demo_igw" {
  vpc_id = aws_vpc.demo_vpc.id
}

#更新路由表
resource "aws_route" "default_route" {
  route_table_id         = aws_vpc.demo_vpc.default_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.demo_igw.id
}

#create DMZ subnet
resource "aws_subnet" "demo_dmz_subnet" {
  vpc_id            = aws_vpc.demo_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-southeast-1a"
  tags = {
    Name = "main_dmz_subnet"
  }
}

#create internal subnet
resource "aws_subnet" "demo_internal_subnet" {
  vpc_id            = aws_vpc.demo_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-southeast-1b"
  tags = {
    Name = "main_internal_subnet"
  }
}

#DMZ 安全群組設定
resource "aws_security_group" "demo_dmz_sg" {
  name        = "demo-dmz-sg"
  description = "sg for DMZ"
  vpc_id      = aws_vpc.demo_vpc.id
  tags = {
    Name = "dmz_sg"
  }
  # 允許 22 80 443 port 進入
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_dms_ip
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.allowed_dms_ip
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.allowed_dms_ip
  }

  #出不限制
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

#internal 安全群組設定
resource "aws_security_group" "demo_internal_sg" {
  name        = "demo-internal-sg"
  description = "sg for internal"
  vpc_id      = aws_vpc.demo_vpc.id
  tags = {
    Name = "internal_sg"
  }

  #允許DMZ的流量進入
  ingress {
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_security_group.demo_dmz_sg.id]
  }
  #出不限制
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

#DMZ EC2
resource "aws_instance" "demo_dmz_instance" {
  ami                         = "ami-06c4be2792f419b7b"
  instance_type               = "t2.micro"
  key_name                    = var.dmz_instance_key #使用者金鑰,測試用
  subnet_id                   = aws_subnet.demo_dmz_subnet.id
  security_groups             = [aws_security_group.demo_dmz_sg.id]
  associate_public_ip_address = true #允許外部IP

  tags = {
    Name = "dmz_instance"
  }
}

#internal EC2
resource "aws_instance" "demo_internal_instance" {
  ami             = "ami-06c4be2792f419b7b"
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.demo_internal_subnet.id
  security_groups = [aws_security_group.demo_internal_sg.id]
  tags = {
    Name = "internal_instance"
  }
}

#RDS 資料庫
resource "aws_db_instance" "demo_db_instance" {
  allocated_storage      = 20
  engine                 = "mysql"
  engine_version         = "8.0.35"
  instance_class         = "db.m5d.large"
  username               = "admin_demo"
  password               = "password_demo"
  db_subnet_group_name   = aws_db_subnet_group.demo_db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.demo_internal_sg.id]
  tags = {
    Name = "demo_db"
  }

}



#RDS 子網路群組
resource "aws_db_subnet_group" "demo_db_subnet_group" {
  name = "demo_db_subnet_group_name"
  subnet_ids = [aws_subnet.demo_dmz_subnet.id,
  aws_subnet.demo_internal_subnet.id]
}


# 保存連線訊息
resource "local_file" "connection_info" {
  filename = "${path.module}/connection_info.txt"

  content = <<EOF
EC2 Instance DMZ Public IP: ${aws_instance.demo_dmz_instance.public_ip}
EC2 Instance internal Private IP: ${aws_instance.demo_internal_instance.private_ip}
RDS Endpoint: ${aws_db_instance.demo_db_instance.endpoint}
EOF
}
