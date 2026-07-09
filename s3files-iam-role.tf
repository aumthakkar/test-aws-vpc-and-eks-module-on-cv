resource "aws_iam_role" "my_s3files_iam_role" {
  count = var.create_efs_csi_driver ? 1 : 0

  name = "${var.name_prefix}-efs-iam-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = "S3Files_IAM_Role"
        Principal = {
          Service = "elasticfilesystem.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "${var.name_prefix}-efs-iam-role"
  }
}

resource "aws_iam_role_policy" "my_s3files_iam_policy" {
  count = var.create_efs_csi_driver ? 1 : 0

  name = "${var.name_prefix}-s3files-iam-policy"
  role = aws_iam_role.my_s3files_iam_role[count.index].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject",
          "s3:GetObjectAttributes",
          "s3:DeleteObject"
        ]
        Effect   = "Allow"
        Resource = [
          aws_s3_bucket.my_s3files_data_bucket[count.index].arn,
          "${aws_s3_bucket.my_s3files_data_bucket[count.index].arn}/*"
        ]
      },
    ]
  })
}

