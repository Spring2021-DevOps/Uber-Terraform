resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "uber vpc"
  }
}

##################################################################################

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "public subnet"
  }
}

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "public subnet"
  }
}

##################################################################################

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "uber igw"
  }
}

##################################################################################

resource "aws_route_table" "uber-rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "uber-rt"
  }
}

################################################################################################


resource "aws_route_table_association" "rt-a-1" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.uber-rt.id
}

resource "aws_route_table_association" "rt-a-2" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.uber-rt.id
}


################################################################################################

resource "aws_instance" "app-server" {
  ami             = "ami-013f17f36f8b1fefb"
  instance_type   = "t2.micro"
  security_groups = ["${aws_security_group.app-server-sg.name}"]
  key_name        = "terraform_ec2_key"

  subnet_id = aws_subnet.public.id

  user_data = <<-EOF
          sudo apt update
          sudo apt install npm -y
          curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -
          sudo apt install nodejs -y
          sudo apt install nginx -y
          mkdir /home/ubuntu/app
          cd /home/ubuntu/app
          git init
          git clone https://anish-kapuskar:anishk7895@github.com/Spring2021-DevOps/Uber-React.git
          cd /home/ubuntu/app/Uber-React
          npm update
          npm install
          npm run build
          sudo cp -a /home/ubuntu/app/Uber-React/build/. /usr/share/nginx/html/
          sudo systemctl restart nginx
     EOF

  tags = {
    Name = "app-server"
  }
}

################################################################################################

resource "aws_instance" "db-server" {
  ami             = "ami-013f17f36f8b1fefb"
  instance_type   = "t2.micro"
  security_groups = ["${aws_security_group.db-server-sg.name}"]
  key_name        = "terraform_ec2_key"

  subnet_id = aws_subnet.private.id

  user_data = "${file("install_mongo.sh")}" 

  tags = {
    Name = "app-server"
  }
}


################################################################################################

resource "aws_key_pair" "terraform_ec2_key" {
  key_name   = "terraform_ec2_key"
  public_key = "${file("../devops-neu-key.pub")}"
}

################################################################################################


resource "aws_eip" "app-eip" {
  instance = aws_instance.app-server.id
  vpc      = true
}

resource "aws_eip" "db-eip" {
  instance = aws_instance.db-server.id
  vpc      = true
}


#################################################################################################

resource "aws_security_group" "app-server-sg" {
  name        = "app-server-sg"
  description = "App Security Group"
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
    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "db-server-sg" {
  name        = "db-server-sg"
  description = "DB Security Group"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    from_port   = 27017
    to_port     = 27017
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