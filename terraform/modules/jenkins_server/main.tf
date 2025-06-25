resource "aws_security_group" "jenkins-sg" {
    name = "jenkins-sg"
    description = "security group for jenkins server"

    ingress {
        description = "allwoing inbound traffic to jenkins"
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "allowing ssh for jenkins server"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        description = "allowing outbound traffic from jenkins server"
        from_port = 0
        to_port = 0 
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

}

resource "aws_instance" "jenkins-server" {
    ami = var.amiid
    instance_type = var.instance_type
    key_name = var.keyname
    associate_public_ip_address = true
    vpc_security_group_ids = [aws_security_group.jenkins-sg.id]
    tags = {
        Name = "jenkins-server"
    }

    provisioner "remote-exec" {
        connection {
          host = self.public_ip
          type = "ssh"
          user = "ubuntu"
          private_key = "${file("./cd-project.pem")}"
        }

        inline = [
            #update the server 
            "sudo apt update -y",

            #install java
            "sudo apt install openjdk-17-jre -y",
            "java -version",

            #install aws cli
            "sudo apt install unzip -y",
            "curl 'https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip' -o 'awscliv2.zip'",
            "unzip awscliv2.zip",
            "sudo ./aws/install",

            #install jenkins
            "sudo apt update -y",
            "sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key",
            "echo \"deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/\" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null",
            "sudo apt-get update -y",
            "sudo apt-get install -y jenkins",
            "sudo systemctl start jenkins",
            "sudo systemctl enable jenkins",

            #install docker
            "sudo apt-get update -y",
            "sudo apt-get install -y ca-certificates curl",
            "sudo install -m 0755 -d /etc/apt/keyrings",
            "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo tee /etc/apt/keyrings/docker.asc",
            "sudo chmod a+r /etc/apt/keyrings/docker.asc",
            "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
            "sudo apt-get update -y",
            "sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin",
            "sudo usermod -aG docker ubuntu",
            "sudo chmod 777 /var/run/docker.sock",
            "docker --version",

         ]
      
    }
}