########################################################################
### Application Security Group
########################################################################
module "asg" {
  source = "../../modules/asg"

  for_each = local.application_security_groups

  asg_name = each.value.name
  rg_name  = module.rg.rg_name
  location = module.rg.location
  tags     = local.tags
}
