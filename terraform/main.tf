terraform {
  required_version = ">= 1.9.0"
  backend "s3" {
    bucket = "terraform-state-bucket-nebo-vlzhukov"
    key    = "terraform.tfstate"
    region = "eu-west-1"
  }
}

provider "aws" {
  region = "eu-west-1"
}

resource "aws_default_vpc" "default" {}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["679593333241"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

resource "aws_subnet" "nebo-vnet" {
  vpc_id            = aws_default_vpc.default.id
  cidr_block        = "172.31.64.0/24"
  availability_zone = "eu-west-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "nebo-vnet"
  }
}

resource "aws_key_pair" "nebo-key" {
  key_name   = "nebo-key"
  public_key = var.ssh_public_key
}
resource "aws_security_group" "nebo-sg" {
  vpc_id = aws_default_vpc.default.id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    
  }

  ingress {
      from_port   = 27017
      to_port     = 27017
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_instance" "nebo-task-vm" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.medium"
  subnet_id     = aws_subnet.nebo-vnet.id
  security_groups = [aws_security_group.nebo-sg.id]
  key_name = aws_key_pair.nebo-key.key_name
  tags = {
    Name = "nebo-task-vm"
  }
    provisioner "remote-exec" {
        inline = [ "sudo apt-get -y update && sudo apt-get install -y python3.9" ]
    }
    connection {
      type = "ssh"
      user = "ubuntu"
      host = self.public_ip
      private_key = "${file("~/.ssh/id_ed25519")}"
    }
   provisioner "local-exec" {
      command = <<-EOT
        chmod +x scripts/get_vault_pass.sh
        ANSIBLE_CONFIG=../ansible.cfg \
        ansible-playbook -i '${self.public_ip},' \
        -u ubuntu --private-key ~/.ssh/id_ed25519 ../playbook.yml
      EOT
   }
}
