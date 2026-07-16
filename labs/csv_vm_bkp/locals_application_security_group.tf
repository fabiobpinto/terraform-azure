locals {
  asg_csv = csvdecode(file("${path.module}/data/02-application_security_group.csv"))

  application_security_groups = {
    for asg in local.asg_csv :
    asg.name => {
      name = asg.name
    }
  }
}
