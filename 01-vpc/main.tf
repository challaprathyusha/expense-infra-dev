module "expense_dev" {
    #source = "../terraform-aws-vpc-module"
    #referring vpc module from github
    #terraform downloads vpc module from github when we initialize the terraform 
    source = "git::https://github.com/challaprathyusha/terraform-aws-vpc-module.git?ref=main"
    project_name = var.project_name
    common_tags = var.common_tags
    public_subnet_cidrs = var.public_subnet_cidrs
    private_subnet_cidrs = var.private_subnet_cidrs
    database_subnet_cidrs = var.database_subnet_cidrs
    is_peering_required = var.is_peering_required
    environment = var.environment
}