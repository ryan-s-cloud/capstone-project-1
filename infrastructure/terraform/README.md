# terraform files to provision EC2 resources for the project

**Usage:**

1. Edit the credentials.tf file and add the AWS credentials
```ssh
provider "aws" {
  region = "us-east-1"
  access_key = ""   <== fill this
  secret_key = ""   <== fill this
  # only needed for restricted accounts
  token = ""        <== optional, fill this only if you have a restricted account
}
```
2. Create SSH key if you don't have one
```sh
ssh-keygen -t rsa -b 4096
```
3. Initialize terraform
```sh
terraform init
```
4. Have terraform validate your configuration
```sh
terraform validate
```
5. Have terraform provision the AWS infrastructure
```sh
terraform apply -auto-approve
```
...... once done with the project ....

6. Have terraform delete the provisioned AWS resources
```sh
terraform destroy -auto-approve
```
