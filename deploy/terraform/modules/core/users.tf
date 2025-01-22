resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!#$%&*-_?"
}

resource "routeros_system_user_group" "terraform" {
  name    = "terraform"
  policy  = ["api", "!ftp", "!local", "!password", "!policy", "read", "!reboot", "rest-api", "!romon", "!sensitive", "!sniff", "!ssh", "!telnet", "!test", "!web", "!winbox", "write"]
  comment = "terraform_conf"
}

resource "routeros_system_user" "terraform" {
  name     = "terraform"
  address  = "10.70.0.0/16"
  group    = routeros_system_user_group.terraform.name
  password = random_password.password.result
  comment  = "terraform_conf"
}

output "terraform_auth" {
  description = "Router os auth for terraform deployments"
  value = {
    username = routeros_system_user.terraform.name
    password = routeros_system_user.terraform.password
  }
  sensitive = true
}

