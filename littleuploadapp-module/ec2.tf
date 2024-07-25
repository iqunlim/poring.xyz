# Temporary computing solution to get this thing going

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "webserver" {
    ami = data.aws_ami.ubuntu.id
    instance_type = "t3.micro"
    subnet_id = aws_subnet.public[0].id
    associate_public_ip_address = true

    tags = {
        Terraform = "True"
    }
}