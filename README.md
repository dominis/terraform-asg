# Generic terraform ASG module

## This module is not production ready

module "test-asg" {
  source                      = "github.com/dominis/terraform-asg"
  region                      = "us-west-1"
  vpc_id                      = "vpc-asd3sadf"
  availability_zones          = "us-west-1a,us-west-1c"
  public_subnets              = "subnet-asdfasdf,subnet-asfadsf"
  private_subnets             = "subnet-asd44sdf,subnet-as33dsf"
  ami_id                      = "ami-123123123"
  maximum_number_of_instances = "10"
  minimum_number_of_instances = "2"
  rolling_update_batch_size   = "2"
}
