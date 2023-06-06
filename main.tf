terraform {
  required_providers {
      aws = {
          source = "hashicorp/aws"
          version = "~> 4.0"
      }
  }
}

# configure aws provider
provider "aws" {
  region = "us-east-2"
}

resource "aws_instance" "terra_demo" {
    ami = "ami-024e6efaf93d85776" # Ubuntu Server 22.04 LTS us-east-2
    instance_type = "t2.micro" # instance type, within the Free Tier
    vpc_security_group_ids = [ aws_security_group.terra-demo.id ]
    key_name = aws_key_pair.terra-demo.key_name
    root_block_device {
        volume_size = 30 # Size of the root volume in GB
        volume_type = "gp2" # General Purpose SSD (default)
        delete_on_termination = true
    }
    user_data = "${file("init_config.sh")}"
}

resource "aws_key_pair" "terra-demo" {
    key_name = "terra-demo-key"
    public_key = "Your Own Pub Key"
}

resource "aws_security_group" "terra-demo" {
    name = "terra-demo-security-group"
    ingress {  # ALLOW INCOMING HTTP TRAFFIC
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = [ "0.0.0.0/0" ]
    }
    ingress { # ALLOW INCOMING TRAFFIC AT PORT 8080
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = [ "0.0.0.0/0" ]
    }
    ingress { # ALLOW SSH INCOMING CONNECTION
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [ "0.0.0.0/0" ]
    }
    egress { # ALLOW ALL OUTGOING TRAFFIC
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}