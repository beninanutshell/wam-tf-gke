/***************************************************
  Provider Google
****************************************************/

terraform {

  required_version = ">= 1.0.0, < 2.0.0"
  experiments      = [module_variable_optional_attrs]
  required_providers {
    google = {
      version = ">= 3.69.0, < 4"
      source  = "hashicorp/google"
    }
    google-beta = {
      version = ">= 3.69.0, < 4"
      source  = "hashicorp/google-beta"
    }
    random = {
      version = ">= 3.1.0, < 4"
      source  = "hashicorp/random"
    }
  }
}

/***************************************************
  Backend GCS
****************************************************/
/*
terraform {
  backend "gcs" {
    bucket = "hprod-matthieu-eu-74f9-tfstate"
    prefix = "terraform/gcp-node-pool"
  }
}
*/