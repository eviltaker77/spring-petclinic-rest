resource "aws_instance" "jenkins" {
  ami           = "ami-0e86e20dae9224db8"
  instance_type = "t2.large"
  key_name      = "aws-keypair"

  tags = {
    Name = "jenkins"
  }

  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]

  root_block_device {
    volume_size = 30
    volume_type = "gp2"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("aws-keypair.pem")
    host        = self.public_ip
  }

  provisioner "file" {
    source      = "ansible/jenkins.yml"
    destination = "/home/ubuntu/jenkins.yml"
  }

  provisioner "file" {
    source      = "ansible/docker.yml"
    destination = "/home/ubuntu/docker.yml"
  }

  provisioner "file" {
    source      = "ansible/kubernetes_minikube.yml"
    destination = "/home/ubuntu/kubernetes_minikube.yml"
  }

  provisioner "file" {
    source      = "plugins.txt"
    destination = "/home/ubuntu/plugins.txt"
  }

  provisioner "file" {
    source      = "jcasc.yaml"
    destination = "/home/ubuntu/jcasc.yaml"
  }

  provisioner "file" {
    source      = "ansible/docker-compose.yml"
    destination = "/home/ubuntu/docker-compose.yml"
  }

  provisioner "remote-exec" {
    inline = [
      "until cloud-init status --wait; do echo 'Waiting for cloud-init...'; sleep 5; done",
      "sudo apt update",
      "sudo apt install software-properties-common -y",
      "sudo apt-add-repository --yes --update ppa:ansible/ansible",
      "sudo apt install ansible -y",
      "ansible --version",
      "ansible-playbook --version",
      "export ANSIBLE_HOST_KEY_CHECKING=False",
      "ansible-playbook /home/ubuntu/jenkins.yml",
      "ansible-playbook /home/ubuntu/docker.yml",
      "ansible-playbook /home/ubuntu/kubernetes_minikube.yml"
    ]
  }
}

resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-sg"
  description = "Security group for Jenkins"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 8080
    to_port     = 8083
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8001
    to_port     = 8001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9966
    to_port     = 9966
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
