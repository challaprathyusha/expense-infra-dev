variable "project_name" {
    type = string
    default = "expense"
  
}

variable "environment" {
    type = string
    default = "dev"
  
}

variable "common_tags" {
    type = map
    default = {
        Project = "Expense"
        Terraform = "true"
        Environment = "dev"
    }

}

variable "zone_name" {
    type = string
    default = "expensesnote.site"
  
}