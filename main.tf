provider "aws" {
  region = "ap-southeast-1"
}

resource aws_instance "Public" {
        ami                = "ami-0bd6906508e74f692"
        instance_type      = "t2.micro"
        associate_public_ip_address = "true"
        vpc_security_group_ids = [aws_security_group.g1.id]
        user_data = <<-EOF
             #!/bin/bash 
             sudo -i
             sudo yum update
             yum install httpd -y
             systemctl start httpd
             systemctl enable httpd
             echo "Learning Terraform is Fun !!!">/var/www/html/index.html
             EOF

        tags = {
	Name = "WS"
        }
}
 
resource aws_security_group "g1" {
     description = "Allow HTTP and HTTPS traffic"
     name = "g1"
     
     ingress {
        description = "HTTPS"
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
     }

     ingress {
        description = "HTTP"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
     }

     egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
     }
}
