provider "aws" {
  region = "${var.region}"
}

provider "template" {
  version = "~> 2.1"  
}