terraform {
  required_providers {
    aws = {
      configuration_aliases = [aws]
      source                = "hashicorp/aws"
      version               = "> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.1.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.2"
    }
  }
  required_version = ">= 0.14"
}
