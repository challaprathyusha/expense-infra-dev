#resource block to import public key into aws
resource "aws_key_pair" "deployer" {
  key_name   = "openvpn"
  public_key = file("~/.ssh/openvpn.pub")
#we can directly paste the public key as below or we can give the location of the key as above
# public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDjzt6RSY4UvgW7V6rQ1SyiHvOkb62mhro8wmhTD4KEbVgkKmHABj7dGNtRNCnN/CDKLZFSIQ2eh+1TxK3JyLyaCbixi9jRrcstmnCI0EX6oPEkmjqvZ8nDXtShuJ3NELtKNLagYMDDFjri7BLFMdedfBoH7QQN+8qon7SIQCWkLr4pOBOAKjsWEBlsAF5sFR9M+Jk3Qled5ZT5cGDubk95yGcci8Gh17J3KcZdi/ZKsZE8JjB6Lt/Xx7QQy9c2Vsqxfa+6pOcBYOoDwPs+pDiS6kQACfFnRNDa09IFTOpxsmnGer53HTMqGiQtGL8hnI0apE+cNx62pJXnlc2N35F91ITPxDxnZJjnPLfMJgW8dpwV/lcrh/5O00eB1YSRyn19CVJJSV3jh3ajGl3waJtQA1VM+yBTimaY3hQoRYKxtFN8plqGwvkCyDXKDvvR6VtOlQ6PhjWOC8hchhPDUFtmPucbIm/dE8PFa/XJzlWJaKySrsrpJ0/6ePSjD1ZttHE= 91630@PrathyuPavan"
}

module "vpn" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  ami = data.aws_ami.ami_info.id
  name = "${var.project_name}-${var.environment}-vpn"
  key_name = aws_key_pair.deployer.key_name
  instance_type          = "t3.micro"
  vpc_security_group_ids = [data.aws_ssm_parameter.vpn_sg_id.value]
  #convert stringlist to list(string) and get the first element
  subnet_id              = local.subnet_id_vpn

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-vpn"
    }
  )
}