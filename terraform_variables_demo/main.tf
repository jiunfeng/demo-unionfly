
provider "aws" {
  region = "us-west-2"
}

# 定義變數，包含不同類型應用創建 AWS 資源，若不要使用預設值，可在 terraform.tfvars 中設定

# S3 存儲桶名稱
variable "example_string_s3name" {
  type    = string
  default = "hello-terraform-demo-marcus"
}

# EC2 實例數量
variable "example_number_ec2_count" {
  type    = number
  default = 2
}

# EC2 監控
variable "example_bool_ec2_monitoring" {
  type    = bool
  default = true
}

# EC2 環境列表
variable "example_list" {
  type    = list(string)
  default = ["Dev", "Production"]
}

# EC2 安全組 IP 列表 預設IP僅範例用途
variable "example_set_ip" {
  type    = set(string)
  default = ["192.168.1.0/24", "10.0.0.0/8", "10.0.0.0/8"] # 重複的 IP 會被自動移除
}

# S3 存儲桶標籤
variable "example_map_s3tags" {
  type = map(string)
  default = {
    Name        = "s3_bucket_name"
    Environment = "Demo"
    key3        = "value3"
  }
}

# 建立 AWS S3 存儲桶資源
resource "aws_s3_bucket" "example_bucket" {
  bucket = var.example_string_s3name

  tags = var.example_map_s3tags
}

# 建立 AWS EC2 實例資源
resource "aws_instance" "example_instance" {
  count         = var.example_number_ec2_count
  ami           = "ami-08116b9957a259459"
  instance_type = "t2.micro"
  monitoring    = var.example_bool_ec2_monitoring


  tags = {
    Name        = "example-instance-${count.index + 1}"
    Environment = var.example_list[count.index]
  }
}


# 建立 AWS 安全組資源
resource "aws_security_group" "example_security_group" {
  name = "example-security-group"

  # 允許流量進入
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = var.example_set_ip
  }
}
