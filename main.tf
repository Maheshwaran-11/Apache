 provisioner "remote-exec" {
    inline = [
             sudo -i
             yum install httpd -y
             systemctl start httpd
             systemctl enable httpd
             echo "Learning Terraform is Fun !!!">/var/www/html/index.html
    ]
 }
