# This file is a simple example of building a VPC from scratch in terraform
# The default VPC is probably fine and this is being used for learning more than necessity

# Main Resource

resource "aws_vpc" "littleupload-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default" # This may be set with dedicated if required
  enable_dns_hostnames = true
  tags = {
    Name      = "littleupload-vpc"
    Terraform = "True"
  }
}

# Subnets

# Let's start by getting all of the available AZ's for the region

data "aws_availability_zones" "available" {
  state = "available"
}

# We have them, now lets make 1 subnet per AZ 

resource "aws_subnet" "public" {

  count  = length(data.aws_availability_zones.available.names)
  vpc_id = aws_vpc.littleupload-vpc.id
  # This function takes the main CIDR block and splits it up in to /24 subnets (8+the base 16, iterated by count.index)
  cidr_block        = cidrsubnet(aws_vpc.littleupload-vpc.cidr_block, 8, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name      = "public_subnet_${count.index}"
    Terraform = "True"
  }
}

# If this needed private subnets, you could copy the above here and not associate them with a route table with an IGW

# Next, let's set an Internet Gateway for the public subnets

resource "aws_internet_gateway" "MAIN" {
  vpc_id = aws_vpc.littleupload-vpc.id

  tags = {
    Name      = "MAIN"
    Terraform = "True"
  }
}

# Route Table 

resource "aws_route_table" "MAIN" {
  vpc_id = aws_vpc.littleupload-vpc.id

  # Default outbound route to send all outbound traffic to the IGW
  # the route of vpc CIDR block to local is automatically added to the route table
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.MAIN.id
  }

  tags = {
    Name      = "MAIN"
    Terraform = "True"
  }
}

# Now let's attach the subnets to the route table 

resource "aws_route_table_association" "public-1" {

  count = length(aws_subnet.public) 
  subnet_id = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.MAIN.id

}

# This gets the basic VPC with 1 subnet of CIDR block /24 per AZ connected to the internet 

# Let's add some extra things that this application needs 

# S3 Gateway endpoint to connect to S3 buckets within the VPC and not have to go to the internet
resource "aws_vpc_endpoint" "s3" {
    vpc_id = aws_vpc.littleupload-vpc.id
    service_name = "com.amazonaws.${var.region}.s3"
    route_table_ids = [aws_route_table.MAIN.id]
    tags = {
        Name = "S3-Endpoint"
        Terraform = "True"
    }
}

# API Interface Endpoint here. These cost $7.20/month($0.01/hr) PER SUBNET/AZ!!!! to maintain 
#     compared to the free Gateway Endponts of dynamodb and S3
# You must set "api_interface_endpoint=true in the module to utilize this"
resource "aws_vpc_endpoint" "api_gateway" {
    count = var.api_interface_endpoint ? 1 : 0 # Format of [boolean value] ? [do if true] : [do if false]
    vpc_id = aws_vpc.littleupload-vpc.id
    service_name = "com.amazonaws.us-east-2.execute-api"
    vpc_endpoint_type = "Interface"
    # It is VERY likely that I will only associate this to one subnet, but for the example ill attach it to all 3
    subnet_ids = aws_subnet.public.*.id # You can use the * to get a string array of all IDs. Very handy.
}