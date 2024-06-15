#store vpc id in ssm parameter store
resource "aws_ssm_parameter" "vpc_id" {
  name  = "/${var.project_name}/${var.environment}/vpc_id"
  type  = "String"
  value = module.expense_dev.vpc_id
}

#store public subnet ids in ssm parameter store
resource "aws_ssm_parameter" "public_subnet_ids" {
  name = "/${var.project_name}/${var.environment}/public_subnet_ids"
  type = "StringList"
  #converting string to stringlist
  #terraform format list notation is ["id1","id2"]
  #aws ssm parameter format list notation is id1,id2
  #so we use StringList here instead of list(string)
  value = join(",",module.expense_dev.public_subnet_ids)
  
}

#store private subnet ids in ssm parameter store
resource "aws_ssm_parameter" "private_subnet_ids" {
  name = "/${var.project_name}/${var.environment}/private_subnet_ids"
  type = "StringList"
  value = join(",",module.expense_dev.private_subnet_ids)
  
}

#store db subnet ids in ssm parameter store
resource "aws_ssm_parameter" "database_subnet_ids" {
  name = "/${var.project_name}/${var.environment}/database_subnet_ids"
  type = "StringList"
  value = join(",",module.expense_dev.database_subnet_ids)
  
}

#store db subnet group id in ssm parameter store
resource "aws_ssm_parameter" "db_subnet_group_id" {
  name = "/${var.project_name}/${var.environment}/db_subnet_group_id"
  type = "String"
  value = module.expense_dev.db_subnet_group_id
  
}

#store db subnet group name in ssm parameter store
resource "aws_ssm_parameter" "db_subnet_group_name" {
  name = "/${var.project_name}/${var.environment}/db_subnet_group_name"
  type = "String"
  value = module.expense_dev.db_subnet_group_name
  
}
