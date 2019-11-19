variable "cmk_alias" {
  type = string
}

data "aws_kms_alias" "cmk" {
  name = var.cmk_alias
}

data "aws_iam_policy_document" "enc-ebs" {
  statement {
    actions   = ["kms:CreateGrant"]
    resources = [data.aws_kms_alias.cmk.arn]
    condition {
      test     = "Bool"
      variable = "kms:GrantIsForAWSResource"
      values   = [true]
    }
  }

  statement {
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:GenerateDataKeyWithoutPlainText",
      "kms:ReEncrypt"
    ]

    resources = [data.aws_kms_alias.cmk.arn]
  }
}

resource "aws_iam_policy" "enc_ebs" {
  policy = data.aws_iam_policy_document.enc-ebs.json
}

output "policy_arn" {
  value = aws_iam_policy.enc_ebs.arn
}
