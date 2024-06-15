#########deployment process using terraform,autoscaling##############
#module to create backend server
module "backend" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  ami = data.aws_ami.ami_info.id
  name = "${var.project_name}-${var.environment}-${var.common_tags.Component}"

  instance_type          = "t3.micro"
  vpc_security_group_ids = [data.aws_ssm_parameter.backend_sg_id.value]
  #convert stringlist to list(string) and get the first element
  subnet_id              = local.subnet_id_backend

  tags = merge(
    var.common_tags,
    {
        Name = "${var.project_name}-${var.environment}-${var.common_tags.Component}"
    }
  )
}

#null resource doesn't create any resources in provider, it is useful to run triggers like local-exec,remote-exec,some file provisioners
#here we are using it to run remote-exec
#null resources are used to perform any configurations in the servers running in aws
resource "null_resource" "backend" {
#this will trigger everytime when instance is created
  triggers = {
    instance_id = module.backend.id 
  }
#connects to the backend server using vpn 
#terraform can ssh to the server running in private subnet using vpn
  connection {
      type = "ssh"
      user = "ec2-user"
      password = "DevOps321"
      host = module.backend.private_ip
    }

#copying file from local to backend server using file provisioner
provisioner "file" {
    source      = "${var.common_tags.Component}.sh"
    destination = "/tmp/${var.common_tags.Component}.sh"
  }
#now the script will run in the backend server which is going to pull ansible playbook from github and run that playbook 
provisioner "remote-exec" {
     inline = [
       "chmod +x /tmp/${var.common_tags.Component}.sh",
       "sudo sh /tmp/${var.common_tags.Component}.sh ${var.common_tags.Component} ${var.environment}"
     ]
   }
}

#resource block to stop the backend server 
resource "aws_ec2_instance_state" "backend" {
  instance_id = module.backend.id
  state       = "stopped"
  #stop the serever only when null resource provisioning is completed
  depends_on = [ null_resource.backend ]
}
#resource block to take the AMI of the backend server
resource "aws_ami_from_instance" "backend" {
  name               = "${var.project_name}-${var.environment}-${var.common_tags.Component}"
  source_instance_id =  module.backend.id
  depends_on = [ aws_ec2_instance_state.backend ]
}

#null resource and local exec to terminate the backend server which is in stopped state
resource "null_resource" "backend_delete" {
    triggers = {
      # this will be triggered everytime instance is created
      instance_id = module.backend.id 
    }

#local-exec provisioner to terminate the backend server in aws 
    provisioner "local-exec" {
        command = "aws ec2 terminate-instances --instance-ids ${module.backend.id}"
    } 

    depends_on = [ aws_ami_from_instance.backend ]
}

#resource block to create backend target group
resource "aws_lb_target_group" "backend" {
  name     = "${var.project_name}-${var.environment}-${var.common_tags.Component}"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = data.aws_ssm_parameter.vpc_id.value

  health_check {
    path                = "/health"
    port                = 8080
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }
}

#resource block to create launch template using the backend ami
resource "aws_launch_template" "backend" {
  name = "${var.project_name}-${var.environment}-${var.common_tags.Component}"

  image_id = aws_ami_from_instance.backend.id
  instance_initiated_shutdown_behavior = "terminate"
  instance_type = "t3.micro"
  vpc_security_group_ids = [data.aws_ssm_parameter.backend_sg_id.value]
  #sets the latest version to default
  update_default_version = true
  tag_specifications {
    resource_type = "instance"

    tags = merge(
      var.common_tags,
      {
      Name = "${var.project_name}-${var.environment}-${var.common_tags.Component}"
      }
    )
  }
}

#resource block to create auto scaling group by using above launch template
resource "aws_autoscaling_group" "backend" {
  name                      = "${var.project_name}-${var.environment}-${var.common_tags.Component}"
  max_size                  = 5
  min_size                  = 1
  health_check_grace_period = 60
  health_check_type         = "ELB"
  desired_capacity          = 1
  target_group_arns = [aws_lb_target_group.backend.arn]
  launch_template {
    id      = aws_launch_template.backend.id
    version = "$Latest"
  }
  vpc_zone_identifier       = split(",",data.aws_ssm_parameter.private_subnet_ids.value)

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
     triggers = ["launch_template"]
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-${var.environment}-${var.common_tags.Component}"
    propagate_at_launch = true
  }

  timeouts {
    delete = "15m"
  }

  tag {
    key                 = "Project"
    value               = "${var.project_name}"
    propagate_at_launch = true
  }
}

#resource block to create auto_scaling_policy based on CPU utilization metrics
resource "aws_autoscaling_policy" "backend" {

  name                   = "${var.project_name}-${var.environment}-${var.common_tags.Component}"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.backend.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 10.0
  }
}

#resource block to create listener rule for application load balancer
resource "aws_lb_listener_rule" "backend" {
  listener_arn = data.aws_ssm_parameter.app_alb_listener_arn.value
  priority     = 100 # less number will be first validated

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }

  condition {
    host_header {
      values = ["backend.app-${var.environment}.${var.zone_name}"]
    }
  }
}