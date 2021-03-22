**UBER Terraform**
To build the infrastructure and run the application and database :
- Configure AWS credentials using CLI `aws configure`
- In the root directory, run `terraform init` to initialise the directory
- `terraform plan` to verify the resources created
- `terraform apply` to create the infrastructure
- `ssh -i <path to ssh key> ubuntu@<public ip>`
- `terraform destroy` to delete the infrastructure

