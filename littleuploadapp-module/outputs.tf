
# temp output for testing
output "vpc_id" {
    description = "The VPC created with this application"
    value = aws_vpc.littleupload-vpc.id
}

# TODO: Required outputs here