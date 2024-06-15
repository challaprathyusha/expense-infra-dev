module "db" {
  source = "terraform-aws-modules/rds/aws"

  identifier = "${var.project_name}-${var.environment}-db"

  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = "db.t3.micro"
  #storage capacity for mysql
  allocated_storage = 5

# for HA we can set this as true,in free tier we are not using HA
# multi_az = true

  db_name  = "transactions" #default schema for expenses project
  username = "root"
  port     = "3306"

# iam_database_authentication_enabled = true

  vpc_security_group_ids = [data.aws_ssm_parameter.db_sg_id.value]

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-db"
    }
  )

  # DB subnet group
#  create_db_subnet_group = true
#  subnet_ids             = split(",",data.aws_ssm_parameter.database_subnet_ids.value)

#we are using db_subnet_group_name
  db_subnet_group_name = data.aws_ssm_parameter.db_subnet_group_name.value

  
  # DB parameter group
  family = "mysql8.0"

  # DB option group
  major_engine_version = "8.0"

  # Database Deletion Protection
  #if we set this to true, we wont be able to delete the database
# deletion_protection = true


  manage_master_user_password = false
  password = "ExpenseApp1"
  skip_final_snapshot = true

  parameters = [
    {
      name  = "character_set_client"
      value = "utf8mb4"
    },
    {
      name  = "character_set_server"
      value = "utf8mb4"
    }
  ]

  options = [
    {
      option_name = "MARIADB_AUDIT_PLUGIN"

      option_settings = [
        {
          name  = "SERVER_AUDIT_EVENTS"
          value = "CONNECT"
        },
        {
          name  = "SERVER_AUDIT_FILE_ROTATIONS"
          value = "37"
        },
      ]
    },
  ]
}

#creating route53 records using opensource module
module "records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "~> 2.0"

  zone_name = var.zone_name

  records = [
    {
      name    = "db-${var.environment}"
      type    = "CNAME"
      ttl     = 1
      allow_overwrite = true
      records = [
      module.db.db_instance_address
      ]
    }
  ]

}