########################################################################
### Terraform Deployment Information
########################################################################

resource "time_static" "deployment" {}

locals {
  terraform_tags = {
    managed_by = "Terraform"
    # terraform_deployed_date = formatdate("YYYY-MM-DD - HH:mm:ss", timeadd(time_static.deployment.rfc3339, "-3h"))
    terraform_deployed_date = formatdate("YYYY-MM-DD - hh:mm:ss", time_static.deployment.rfc3339)
  }
  tags = merge(var.tags, local.terraform_tags)
}
