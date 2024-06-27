resource "aws_iam_policy" "push_image" {
  name        = "${aws_ecr_repository.this.name}-push"
  description = "Allow push image to ${aws_ecr_repository.this.name} repository"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "GetAuthorizationToken",
        Effect = "Allow",
        Action = [
          "ecr:GetAuthorizationToken"
        ],
        Resource = "*"
      },
      {
        Sid    = "AllowPull",
        Effect = "Allow",
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:DescribeImages"
        ],
        Resource = aws_ecr_repository.this.arn
      },
      {
        Sid    = "AllowPush",
        Effect = "Allow",
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ],
        Resource = aws_ecr_repository.this.arn
      }
    ]
  })
}
