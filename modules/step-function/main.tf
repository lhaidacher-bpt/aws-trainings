resource "aws_sfn_state_machine" "this" {
  name     = var.name
  role_arn = var.iam_admin_role_arn
  type     = "STANDARD"

  // TODO Implementierung
  definition = <<EOF
{
  <ADD SFN DEFINITION>
}
EOF

  tags = var.tags
}