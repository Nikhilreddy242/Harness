
# SES Receipt Rule Set
resource "aws_ses_receipt_rule_set" "main" {
  rule_set_name = var.rule_set_name
}

# SES Receipt Rule
resource "aws_ses_receipt_rule" "rule" {
  rule_set_name = aws_ses_receipt_rule_set.main.rule_set_name
  name          = var.receipt_rule_name
  enabled       = var.receipt_rule_enabled

  recipients = var.receipt_recipients


  tls_policy = var.receipt_tls_policy
}

# SES Email Identity (for verifying individual email addresses)
resource "aws_ses_email_identity" "email_identity" {
  for_each = toset( [
"john.roberts@regions.com",
"nikhil.vallapureddy@regions.com",
"ash.quakenbush@regions.com",
"zachery.zima@regions.com",
"jared.wallace2@regions.com"
] )
  email = each.key
}

resource "aws_iam_access_key" "ses" {
  user = aws_iam_user.smtp_user.name
}

resource "aws_iam_user" "smtp_user" {
  name = "SES_send_email"
}

resource "aws_iam_user_policy" "ses_send_email" {
  name = "ses_send_email"
  user = aws_iam_user.smtp_user.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "ses:SendEmail",
          "ses:SendRawEmail"
        ]
        Resource = "*"
        Condition = {
          StringLike = {
            "ses:Recipients" = [
              "*@regions.com"
            ]
          },
          BoolIfExists = {
            "aws:MultiFactorAuthPresent" = "true"
          }
        }
      }
    ]
  })
}




