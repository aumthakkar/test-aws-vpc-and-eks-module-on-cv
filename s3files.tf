resource "aws_s3_bucket" "my_s3files_data_bucket" {
  count = var.create_efs_csi_driver ? 1 : 0

  bucket = "${var.name_prefix}-s3files-data-bucket"

  tags = {
    Name = "${var.name_prefix}-s3files-data-bucket"
  }
}

resource "aws_s3_bucket_versioning" "s3files_data_bucket_versioning" {
  count = var.create_efs_csi_driver ? 1 : 0

  bucket = aws_s3_bucket.my_s3files_data_bucket[count.index].id
  
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3files_file_system" "my_s3files_file_system" {
  count = var.create_efs_csi_driver ? 1 : 0

  bucket = aws_s3_bucket.s3files_data_bucket[count.index].arn
  role_arn = aws_iam_role.s3files_iam_role.arn

  tags = {
    Name = "${var.name_prefix}-s3files-file-system"
  }
  
}

resource "aws_s3files_mount_target" "s3files_mount_target" {
  count = var.create_efs_csi_driver ? 1 : 0

  file_system_id = aws_s3files_file_system.my_s3files_file_system
  subnet_id = aws_subnet.my_private_subnets[0].id

  security_groups = [
    aws_security_group.cluster_security_groups["efs_sg"].id
    ]

}


