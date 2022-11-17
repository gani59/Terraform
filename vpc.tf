#
# VPC Resources
#  * VPC
#  * Subnets
#  * Internet Gateway
#  * Route Table
#

resource "aws_vpc" "percipient-citizen" {
  cidr_block = "10.0.0.0/16"

  tags = tomap({
    "Name"                                      = "terraform-eks-percipient-citizen-node",
    "kubernetes.io/cluster/${var.cluster-name}" = "shared",
  })
}

resource "aws_subnet" "percipient-citizen" {
  count = 2

  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = "10.0.${count.index}.0/24"
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.percipient-citizen.id

  tags = tomap({
    "Name"                                      = "terraform-eks-percipient-citizen-node",
    "kubernetes.io/cluster/${var.cluster-name}" = "shared",
  })
}

resource "aws_internet_gateway" "percipient-citizen" {
  vpc_id = aws_vpc.percipient-citizen.id

  tags = {
    Name = "terraform-eks-percipient-citizen"
  }
}

resource "aws_route_table" "percipient-citizen" {
  vpc_id = aws_vpc.percipient-citizen.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.percipient-citizen.id
  }
}

resource "aws_route_table_association" "percipient-citizen" {
  count = 2

  subnet_id      = aws_subnet.percipient-citizen.*.id[count.index]
  route_table_id = aws_route_table.percipient-citizen.id
}
