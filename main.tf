module "rg" {
  source   = "./modules/resource_group"
  rg_name  = var.rg_name
  location = var.location
  tags = var.tags
}
