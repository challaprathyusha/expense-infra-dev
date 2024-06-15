locals {
   subnet_id_vpn = element(split(",",data.aws_ssm_parameter.public_subnet_ids.value),0)
}