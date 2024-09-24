/* These are the default values, but we can adjust anything we want
when executing the Ci/CD Pibeline from jenkins file 
using TF_VAR_"varname" = value
Ex : TF_VAR_env_prefix = 'test' */

variable vpc_cidr_block {
    default = "10.0.0.0/16"
}
variable subnet_cidr_block {
    default = "10.0.10.0/24"
}
variable avail_zone {
    default = "eu-west-3a"
}
variable env_prefix {
    default = "dev"
}
// my ip and also jnekins ip to connect to EC2#################
variable my_ip {
    default = "212.124.154.110/32"
}
variable jenkins_ip {
    default = "139.59.140.177/32"
}
variable instance_type {
    default = "t2.micro"
}
variable region {
    default = "eu-west-3"
}
