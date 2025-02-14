skip = false
include "root" {
  path           = find_in_parent_folders("root.hcl")
  expose         = true
  merge_strategy = "deep"
}

locals {
  name = "sample"

  user_data = <<-EOT
    #!/bin/bash
    echo "Hello Terraform!"
  EOT
}

terraform {
  source = "github.com/terraform-aws-modules/terraform-aws-ec2-instance?ref=v5.7.1"
}

inputs = {
  name = local.name

  ami                         = "ami-0a55ba1c20b74fc30"
  instance_type               = "c7gn.8xlarge"
  key_name                    = "automation"
  availability_zone           = "us-east-1a"
  subnet_id                   = "subnet-04b273f85656a3a8e"
  vpc_security_group_ids      = "subnet-04b273f85656a3a8e"
  associate_public_ip_address = true
  disable_api_stop            = false

  user_data_base64            = base64encode(local.user_data)
  user_data_replace_on_change = true

  root_block_device = [
    {
      encrypted   = true
      volume_type = "gp3"
      throughput  = 200
      volume_size = 200
    }
  ]
  tags = merge(
    include.root.locals.custom_tags,
  )
}
