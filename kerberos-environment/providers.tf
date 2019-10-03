provider "aws" {
  region = "${var.REGION}"
}

provider "template" {
  version = "~> 2.1"  
}