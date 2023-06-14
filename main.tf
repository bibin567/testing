provider "aws" {
  region = "us-east-1"  # Change this to your desired AWS region
}

resource "aws_security_group" "web_server_sg" {
  name        = "web-server-sg"
  description = "Security group for the web server"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Restrict the source IP range for security reasons
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Restrict the source IP range for security reasons
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web_server" {
  ami           = "ami-022e1a32d3f742bd8"  # Replace with the desired Amazon Linux AMI ID
  instance_type = "t2.micro"        # Replace with the desired EC2 instance type
  key_name = "bibinaws123"
  vpc_security_group_ids = [aws_security_group.web_server_sg.id]

  connection {
    type        = "ssh"
    user        = "ec2-user"
    host        = self.public_ip
    private_key = file("./bibinaws123.pem")  # Replace with the path to your private key file
    timeout     = "2m"
  }

  provisioner "file" {
    source      = "./day"
    destination = "/home/ec2-user/day"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install -y httpd",
      "sudo cp -r /home/ec2-user/day/* /var/www/html/",
      "sudo systemctl enable httpd",
      "sudo systemctl start httpd"
    ]
  }
}
