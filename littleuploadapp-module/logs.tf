resource "aws_cloudwatch_log_group" "ecs" {
    name = "ecs/littleupload"
    retention_in_days = 1
}