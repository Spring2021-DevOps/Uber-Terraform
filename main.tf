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
    Name = "private subnet"
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


resource "aws_security_group" "app-server-sg" {
  name        = "app-server-sg"
  description = "App Security Group"
  vpc_id      = aws_vpc.main.id

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
    cidr_blocks = ["0.0.0.0/0"]
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
  vpc_id      = aws_vpc.main.id

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


################################################################################################

resource "aws_instance" "app-server" {
  ami             = "ami-013f17f36f8b1fefb"
  instance_type   = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.app-server-sg.id}"]
  key_name        = "terraform_ec2_key"

  subnet_id = aws_subnet.public.id
  user_data = "${data.template_file.webapp.rendered}"

  tags = {
    Name = "app-server"
  }
}

################################################################################################

resource "aws_instance" "db-server" {
  ami             = "ami-013f17f36f8b1fefb"
  instance_type   = "t2.micro"

  vpc_security_group_ids = ["${aws_security_group.db-server-sg.id}"]
  
  key_name        = "terraform_ec2_key"

  subnet_id = aws_subnet.private.id

  user_data = "${file("install_mongo.sh")}" 

  tags = {
    Name = "db-server"
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
  tags = {
    Name = "webapp IP"
  }
}

resource "aws_eip" "db-eip" {
  instance = aws_instance.db-server.id
  vpc      = true
    tags = {
    Name = "database IP"
  }
}


#################################################################################################

data "template_file" "webapp" {
  template = "${file("./scripts/auto_deploy.tpl")}"

  vars = {
    git_username = "${var.git_username}"
    git_password = "${var.git_password}"
    some_address = "${var.some_address}"
    db_host = "${aws_eip.db-eip.private_ip}"
  }
}

##################################################################################################

