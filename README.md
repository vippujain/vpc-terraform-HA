# vpc-terraform-HA

This will generate a custom VPC on AWS (us-east-2) region with two public subnet and two private subnet. This will ensure high availability design.

For changing CIDR, refer variables.tf.

<h1> Steps Run the script </h1>

1) Install terraform on your machine

2) Install AWS cli

3) Configure AWS Cred (access key and secret key)

4) Go into the clone directory

5) Run terraform init (to get all dependencies)

6) Run terraform plan (to see what gonna be configure on AWS)

7) Run terraforom apply (all resources would be created on AWS-us-east-2)

8) Run terrafrom destroy (to remove all resources completely from AWS)
