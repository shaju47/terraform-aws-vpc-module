resource "aws_vpc" "this" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = {
    Name = var.vpc_name
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.vpc_name}-igw"
  }
}

resource "aws_subnet" "public" {
  for_each = toset(var.availability_zones)

  cidr_block        = var.public_subnet_cidrs[var.az_index_map[each.key]]
  vpc_id            = aws_vpc.this.id
  availability_zone = each.key

  tags = {
    Name = "${var.vpc_name}-public-${each.key}"
  }
}

resource "aws_subnet" "private" {
  for_each = toset(var.availability_zones)

  cidr_block        = var.private_subnet_cidrs[var.az_index_map[each.key]]
  vpc_id            = aws_vpc.this.id
  availability_zone = each.key

  tags = {
    Name = "${var.vpc_name}-private-${each.key}"
  }
}

resource "aws_eip" "nat" {
  for_each = toset(var.availability_zones)
  domain   = "vpc"
}

resource "aws_nat_gateway" "this" {
  for_each = toset(var.availability_zones)

  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.public[each.key].id

  depends_on = [aws_internet_gateway.this]

  tags = {
    Name = "${var.vpc_name}-nat-${each.key}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name = "${var.vpc_name}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  for_each = aws_nat_gateway.this

  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = each.value.id
  }

  tags = {
    Name = "${var.vpc_name}-private-rt-${each.key}"
  }
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.key].id
}
