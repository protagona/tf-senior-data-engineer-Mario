terraform {
  required_version = ">= 1.0"
  backend "s3" {
  }
}

provider "aws" {
  default_tags {
    tags = {
      Project         = "sr-de-test-${var.candidate}",
      #ProvisionedDate = timestamp(),
      Candidate       = var.candidate
    }
  }

}
