# Get latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Security Group for EC2
resource "aws_security_group" "ec2_sg" {
  name        = "${var.project_name}-${var.environment}-ec2-sg"
  description = "Security group for web servers"
  vpc_id      = var.vpc_id

  # Allow SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTPS
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-ec2-sg"
    Environment = var.environment
  }
}

# EC2 Instances
resource "aws_instance" "web" {
  count                  = var.instance_count
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = var.public_subnet_ids[count.index % length(var.public_subnet_ids)]
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  tags = {
    Name        = "${var.project_name}-${var.environment}-web-${count.index + 1}"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Null resource for provisioners
resource "null_resource" "web_provisioner" {
  count = var.instance_count

  triggers = {
    instance_id = aws_instance.web[count.index].id
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file(var.private_key_path)
    host        = aws_instance.web[count.index].public_ip
    timeout     = "5m"
  }

  # Copy nginx config
  provisioner "file" {
    source      = "configs/app.conf"
    destination = "/tmp/app.conf"
  }

  # Install nginx
  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo amazon-linux-extras install nginx1 -y",
      "sudo mv /tmp/app.conf /etc/nginx/conf.d/default.conf",
      "sudo systemctl start nginx",
      "sudo systemctl enable nginx",
      "echo 'Nginx setup complete!'"
    ]
  }

  # Log locally
  provisioner "local-exec" {
    command = "echo 'Server ${count.index + 1} ready at http://${aws_instance.web[count.index].public_ip}' >> deployment.log"
  }
}