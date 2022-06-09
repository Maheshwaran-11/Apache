provider "aws" {
  region = "ap-southeast-1"
}

resource "aws_vpc" "myvpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "terraformvpc"
  }
}

resource "aws_subnet" "pubsub" {
     vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "publicsubnet"
  }
}

resource "aws_subnet" "privsub" {
     vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "privatesubnet"
  }
}

resource "aws_internetgateway" "tigw" {
     vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "IGW"
  }
}

resource "aws_route_table" "pubrt" {
      vpc_id = aws_vpc.myvpc.id
    
    route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.tigw.id
    }

  tags = {
    Name = "publicRT"
  }
}

resource "aws_route_table_association" "pubassociation" {
  subnet_id      = aws_subnet.pubsub.id
  route_table_id = aws_route_table.pubrt.id
}

resource "aws_eip" "eip" {
    vpc = "true"
}
resource "aws_nat_gateway" "tnat" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.pubsub.id
  }

  resource "aws_route_table" "privrt" {
      vpc_id = aws_vpc.myvpc.id
    
    route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_nat_gateway_tnat.id
    }
  tags = {
    Name = "privateRT"
  }
}

resource "aws_route_table_association" "privateassociation" {
  subnet_id      = aws_subnet.privsub.id
  route_table_id = aws_route_table.privrt.id
}


resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.myvpc.id

  ingress {
      description      = "TLS from VPC"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
    }

     ingress {
      description      = "TLS from VPC"
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
    }


  egress {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  tags = { 
    Name = "allow_all"    
    }
}

resource "aws_instance" "public" {
  ami                         =  "ami-0bd6906508e74f692"
  instance_type               =  "t2.micro"  
  subnet_id                   =  aws_subnet.pubsub.id
  key_name                    =  "new"
  vpc_security_group_ids      =  ["${aws_security_group.allow_all.id}"]
  associate_public_ip_address =  true
   user_data = <<-EOF
             #!/bin/bash 
             sudo -i
             sudo yum update
             yum install httpd -y
             systemctl start httpd
             systemctl enable httpd
             echo "Learning Terraform is Fun !!!">/var/www/html/index.html
             EOF 

}
resource "aws_instance" "private" {
  ami                         =  "ami-0bd6906508e74f692"
  instance_type               =  "t2.micro"  
  subnet_id                   =  aws_subnet.privsub.id
  key_name                    =  "new"
  vpc_security_group_ids      =  ["${aws_security_group.allow_all.id}"]
  
}

