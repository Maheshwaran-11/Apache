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

resource "aws_internet_gateway" "tigw" {
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
      gateway_id = aws_nat_gateway.tnat.id
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
             echo "<!DOCTYPE html>
<html lang="en">

<head>
  <meta charset="UTF-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <meta Terraform</title>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css">
  <style>
    @import url('https://fonts.googleapis.com/css2?family=Pacifico&display=swap');

    body {
      margin: 0;
      box-sizing: border-box;
    }

    .container {
      line-height: 150%;
    }

    .header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding: 15px;
      background-color: #e9e9e9;
    }

    .header h1 {
      color: #222222;
      font-size: 30px;
      font-family: 'Pacifico', cursive;
    }

    .header .social a {
      padding: 0 5px;
      color: #222222;
    }

    .left {
      float: left;
      width: 180px;
      margin: 0;
      padding: 1em;
    }

    .content {
      margin-left: 190px;
      border-left: 1px solid #d4d4d4;
      padding: 1em;
      overflow: hidden;
    }

    ul {
      list-style-type: none;
      margin: 0;
      padding: 0;
      font-family: sans-serif;
    }

    li a {
      display: block;
      color: #000;
      padding: 8px 16px;
      text-decoration: none;
    }

    li a.active {
      background-color: #84e4e2;
      color: white;
    }

    li a:hover:not(.active) {
      background-color: #29292a;
      color: white;
    }

    table {
      font-family: arial, sans-serif;
      border-collapse: collapse;
      width: 100%;
      margin: 30px 0;
    }

    td,
    th {
      border: 1px solid #dddddd;
      padding: 8px;
    }

    tr:nth-child(1) {
      background-color: #84e4e2;
      color: white;
    }

    tr td i.fas {
      display: block;
      font-size: 35px;
      text-align: center;
    }

    .footer {
      padding: 55px 20px;
      background-color: #2e3550;
      color: white;
      text-align: center;
    }
  </style>
</head>

<body>
  <div class="container">
    <header class="header">
      <h1Welcome to Kirikalan Magic show</h1>
      <div class="social">
        <a href="#"><i class="fab fa-facebook"></i></a>
        <a href="#"><i class="fab fa-instagram"></i></a>
        <a href="#"><i class="fab fa-twitter"></i></a>
      </div>
    </header>
    <aside class="left">
      <img src="./assets/html/mr-camel.jpg" width="160px" />
      <ul>
        <li><a class="active" href="#home">Home</a></li>
        <li><a href="#career">Career</a></li>
        <li><a href="#contact">Contact</a></li>
        <li><a href="#about">About</a></li>
      </ul>
      <br><br>
      <p>"Do something important in life. I convert green grass to code."<br>- Mr Camel</p>
    </aside>
    <main class="content">
      <h2>About Me</h2>
      <p>I don't look like some handsome horse, but I am a real desert king. I can servive days without water.</p>
      <h2>My Career</h2>
      <p>I work as a web developer for a company that makes websites for camel businesses.</p>
      <hr><br>
      <h2>How Can I Help You?</h2>
      <table>
        <tr>
          <th>SKILL 1</th>
          <th>SKILL 2</th>
          <th>SKILL 3</th>
        </tr>
        <tr>
          <td><i class="fas fa-broom"></i></td>
          <td><i class="fas fa-archive"></i></td>
          <td><i class="fas fa-trailer"></i></td>
        </tr>
        <tr>
          <td>Cleaning kaktus in your backyard</td>
          <td>Storing some fat for you</td>
          <td>Taking you through the desert</td>
        </tr>
        <tr>
      </table>
      <form>
        <label>Email: <input type="text" name="email"></label><br>
        <label> Mobile: <input type="text" name="mobile"> </label><br>
        <textarea name="comments" rows="4">Enter your message</textarea><br>
        <input type="submit" value="Submit" /><br>
      </form>
    </main>
    <footer class="footer">&copy; Copyright Mr. Camel</footer>
  </div>
</body>

</html>">/var/www/html/index.html
             EOF 

}
resource "aws_instance" "private" {
  ami                         =  "ami-0bd6906508e74f692"
  instance_type               =  "t2.micro"  
  subnet_id                   =  aws_subnet.privsub.id
  key_name                    =  "new"
  vpc_security_group_ids      =  ["${aws_security_group.allow_all.id}"]
  
}

