resource "aws_instance" "myweb" {
  ami             = "ami-013f17f36f8b1fefb"
  instance_type   = "t2.micro"
  security_groups = ["${aws_security_group.myweb.name}"]
  key_name        = "terraform_ec2_key"

  user_data = <<-EOF
          sudo apt update
          sudo apt install npm -y
          curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -
          sudo apt install nodejs -y
          sudo apt install nginx -y
          mkdir /home/ubuntu/app
          cd app
          git init
          git clone https://anish-kapuskar:anishk7895@github.com/Spring2021-DevOps/Uber-React.git
          cd Uber-React
          npm update
          npm install
          npm run build
          sudo cp -a build/. /usr/share/nginx/html/
          sudo systemctl restart nginx
     EOF

  tags = {
    Name = "myweb"
  }
}

resource "aws_key_pair" "terraform_ec2_key" {
  key_name   = "terraform_ec2_key"
  public_key = "${file("../devops-neu-key.pub")}"
}

resource "aws_security_group" "myweb" {
  name        = "myweb"
  description = "Web Security Group"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5000
    to_port     = 5000
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

