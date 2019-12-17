provider "aws" {
  region = "${var.REGION}"
}

provider "template" {
  version = "~> 2.1"  
}

provider "local" {
  version = "~> 1.4"  
}