# main.tf

provider "aws" {
  region = "us-east-1"  # Set your AWS region here
}

# EC2 Key Pair for SSH access
resource "aws_key_pair" "ec2_key" {
  key_name   = "ec2-key"           # You can choose your preferred key name
  public_key = file("~/.ssh/id_rsa.pub")  # Local path to your existing public key
}

# Security Group For Ethereum
resource "aws_security_group" "ethereum_sg" {
  name        = "ethereum-sg"
  description = "Security group for Ethereum Execution and Consensus Layer"

  ingress {
    from_port   = 22  # SSH Port
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3500  
    to_port     = 3500
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8545  # Ethereum Execution Layer HTTP RPC
    to_port     = 8545
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8546  # Ethereum Execution Layer WebSocket RPC (if used)
    to_port     = 8546
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 4000  # Consensus Layer P2P Port (Beacon Chain)
    to_port     = 4000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5052  # Consensus Layer HTTP RPC
    to_port     = 5052
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Ingress for validator ports (optional, based on your validator client)
  ingress {
    from_port   = 13000
    to_port     = 13099
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0  # Allow all outbound traffic (optional)
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instance with 4GB of RAM 
resource "aws_instance" "ethereum_ec2" {
  ami           = "ami-0e2c8caa4b6378d8c"  
  instance_type = "t2.medium"  
  key_name      = aws_key_pair.ec2_key.key_name  
  security_groups = [aws_security_group.ethereum_sg.name]

  tags = {
    Name = "ethereum-ec2"
  }


}

