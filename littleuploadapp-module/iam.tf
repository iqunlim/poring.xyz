
# Policy Document so that the lambda or anything else I need to access the bucket can put files
data "aws_iam_policy_document" "S3AppPolicy" {
    statement {
        actions = [
            "s3:GetObject",
            "s3:PutObject"
        ]
        resources = [aws_s3_bucket.filebucket.arn]
    }
}

# Policy Document for Lambda Execution. ALL LAMBDAS will need this to function!
# TODO: This is currently not attaching! Something must be wrong.... 
data "aws_iam_policy_document" "BasicLambdaExecutionRole" {
    statement {
        actions = ["logs:CreateLogGroup"]
        resources = ["arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:*"]
    }
    statement {
        actions = [
            "logs:CreateLogStream",
            "logs:PutLogEvents"
        ]
        resources = ["arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:*"] # log-group:/aws/lambda/Get-Signed-S3-${var.production ? "Prod" : "Dev"}
    }
}

## AssumeRole for the lambda
data "aws_iam_policy_document" "LambdaAllow" {
    statement {
        principals {
            type = "Service"
            identifiers = ["lambda.amazonaws.com"]
        }
        actions = ["sts:AssumeRole"]
    }
}

# Turn the documents in to attachable policies with ARNs
resource "aws_iam_policy" "S3AppPolicy" {
    name = "S3AppPolicy"
    path = "/fileserver/"
    description = "Requirements for a fileserver to function"
    policy = data.aws_iam_policy_document.S3AppPolicy.json

    tags = {
        Terraform = "True"
    }
}

resource "aws_iam_policy" "BasicLambdaExecutionRole" {
    name = "BasicLambdaExecutionRole"
    path = "/fileserver/"
    description = "All Lambdas require a version of this"
    policy = data.aws_iam_policy_document.BasicLambdaExecutionRole.json
}

# Create the Lambda role

resource "aws_iam_role" "FileserverLambdaRole" {
    name = "FileserverLambdaRole"
    assume_role_policy = data.aws_iam_policy_document.LambdaAllow.json
    managed_policy_arns = [aws_iam_policy.S3AppPolicy.arn, aws_iam_policy.BasicLambdaExecutionRole.arn]

    tags = {
        Terraform = "True"
    }
}

resource "aws_iam_role" "ecs_role" {
    name = "ecs_role" 
    assume_role_policy  = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

data "aws_iam_policy_document" "ecs_service_elb" {
  statement {
    effect = "Allow"

    actions = [
      "ec2:Describe*"
    ]

    resources = [
      "*"
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
      "elasticloadbalancing:DeregisterTargets",
      "elasticloadbalancing:Describe*",
      "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
      "elasticloadbalancing:RegisterTargets"
    ]

    resources = [
      aws_lb.web_ecs_load_balancer.arn
    ]
  }
}

data "aws_iam_policy_document" "ecs_service_standard" {

  statement {
    effect = "Allow"

    actions = [
      "ec2:DescribeTags",
      "ecs:DeregisterContainerInstance",
      "ecs:DiscoverPollEndpoint",
      "ecs:Poll",
      "ecs:RegisterContainerInstance",
      "ecs:StartTelemetrySession",
      "ecs:UpdateContainerInstancesState",
      "ecs:Submit*",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "*"
    ]
  }
}

data "aws_iam_policy_document" "ecs_service_scaling" {

  statement {
    effect = "Allow"

    actions = [
      "application-autoscaling:*",
      "ecs:DescribeServices",
      "ecs:UpdateService",
      "cloudwatch:DescribeAlarms",
      "cloudwatch:PutMetricAlarm",
      "cloudwatch:DeleteAlarms",
      "cloudwatch:DescribeAlarmHistory",
      "cloudwatch:DescribeAlarms",
      "cloudwatch:DescribeAlarmsForMetric",
      "cloudwatch:GetMetricStatistics",
      "cloudwatch:ListMetrics",
      "cloudwatch:PutMetricAlarm",
      "cloudwatch:DisableAlarmActions",
      "cloudwatch:EnableAlarmActions",
      "iam:CreateServiceLinkedRole",
      "sns:CreateTopic",
      "sns:Subscribe",
      "sns:Get*",
      "sns:List*"
    ]
    resources = [
      "*"
    ]
  }
}

resource "aws_iam_policy" "ecs_service_elb" {
  name = "dev-to-elb"
  path = "/"
  description = "Allow access to the service elb"

  policy = data.aws_iam_policy_document.ecs_service_elb.json
}

resource "aws_iam_policy" "ecs_service_standard" {
  name = "dev-to-standard"
  path = "/"
  description = "Allow standard ecs actions"

  policy = data.aws_iam_policy_document.ecs_service_standard.json
}

resource "aws_iam_policy" "ecs_service_scaling" {
  name = "dev-to-scaling"
  path = "/"
  description = "Allow ecs service scaling"

  policy = data.aws_iam_policy_document.ecs_service_scaling.json
}

resource "aws_iam_role_policy_attachment" "ecs_service_elb" {
  role = aws_iam_role.ecs_role.name
  policy_arn = aws_iam_policy.ecs_service_elb.arn
}

resource "aws_iam_role_policy_attachment" "ecs_service_standard" {
  role = aws_iam_role.ecs_role.name
  policy_arn = aws_iam_policy.ecs_service_standard.arn
}

resource "aws_iam_role_policy_attachment" "ecs_service_scaling" {
  role = aws_iam_role.ecs_role.name
  policy_arn = aws_iam_policy.ecs_service_scaling.arn
}

resource "aws_iam_role_policy_attachment" "s3_for_ecs" {
    role = aws_iam_role.ecs_role.name
    policy_arn = aws_iam_policy.S3AppPolicy.arn
}