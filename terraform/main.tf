resource "aws_key_pair" "key-pair" {
  key_name   = "${var.name}-key-pair"
  public_key = file(var.pubkey_path)
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

data "aws_availability_zones" "az" {
  state = "available"
}

resource "random_shuffle" "az" {
  input        = data.aws_availability_zones.az.names
  result_count = 1
}

resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"

  tags = { Name = var.name }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = var.name
  }
}

resource "aws_subnet" "main" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = random_shuffle.az.result[0]
  map_public_ip_on_launch = true

  tags = {
    Name = var.name
  }
}

resource "aws_default_route_table" "r" {
  default_route_table_id = aws_vpc.vpc.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = var.name
  }
}

resource "aws_route_table" "rt" {
  count  = 0
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = var.name
  }
}

resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow all inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "All from world"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.name
  }
}

resource "aws_instance" "master" {
  ami             = data.aws_ami.ubuntu.id
  instance_type   = "t3a.large"
  key_name        = aws_key_pair.key-pair.id
  subnet_id       = aws_subnet.main.id
  security_groups = [aws_security_group.allow_all.id]
  root_block_device {
    volume_type = "gp3"
    volume_size = 20
    tags        = { Name = var.name }
  }

  tags = {
    Name = "${var.name}-master"
    Role = "master"
  }
}

resource "aws_instance" "minion" {
  ami             = data.aws_ami.ubuntu.id
  instance_type   = "t3a.large"
  key_name        = aws_key_pair.key-pair.id
  subnet_id       = aws_subnet.main.id
  security_groups = [aws_security_group.allow_all.id]
  root_block_device {
    volume_type = "gp3"
    volume_size = 20
    tags        = { Name = var.name }
  }

  tags = {
    Name = "${var.name}-minion"
    Role = "minion"
  }
}

resource "local_file" "hosts-file" {
  content = templatefile(
    "${path.module}/inventory.tpl",
    {
      master_ip = aws_instance.master.public_ip
      agent_ips = aws_instance.minion.*.public_ip
    }
  )
  filename        = "${path.module}/../hosts.ini"
  file_permission = "0400"
}
