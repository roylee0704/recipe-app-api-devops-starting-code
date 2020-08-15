#!/bin/bash 
# its a shebang that tells linux this is a bash script


# Why here?
# - you gonna be creating templates for configuration and scripts that we pass in to resources in AWS.
# - We gonna reference this directory by our Terraform.
#
# this is the script you run when you first start your bastion instance. Since you do not want to 
# keep repeating the installation process of dependencies used by administrators, hence the script 
# to automatically run for you each time bastion instance is spawned.




# update yum package manager with the latest packages
sudo yum update -y 


sudo amazon-linux-extras install -y docker
sudo systemctl enable docker.service
sudo systemctl start docker.service

# usermod command to add our ec2-user(default username of linux image) to the docker-group
# this allows users to run and manage docker through that account.
sudo usermod -aG docker ec2-user