terraform {
  backend "s3" {
    encrypt = true
    bucket  = "demo-awsbucket-terraform"
    key     = "terraform/state.tfstate"
    region  = "ap-southeast-1"
  }
}
