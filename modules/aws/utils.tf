module "key_pair" {
  source = "terraform-aws-modules/key-pair/aws"

  key_name   = "${var.tfuser}-keypair-${random_string.random_append.result}"
  public_key = var.public_ssh_key
}

# Random string appended to the name of most 
# resources that negates name conflicts in AWS
resource "random_string" "random_append" {
  length  = 6
  special = false
}
