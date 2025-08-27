##################################################################################
# variables.tf: Input Variable Definitions
#
# This file declares the variables that need to be provided when running
# the Terraform scripts. Default values can be set here.
##################################################################################

# --- Provider Configuration ---
# This block configures Terraform itself and the required providers.
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.13"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

provider "google" {
  # This tells Terraform to use the credentials you've configured in your
  # local gcloud CLI. Run `gcloud auth application-default login` first.
}


# --- Project Configuration Variables ---

variable "gcp_billing_account" {
  description = "The ID of the GCP billing account to associate with the new projects."
  type        = string
  # Example: "012345-67890A-BCDEF1"
}

variable "gcp_org_id" {
  description = "The ID of the GCP organization where projects will be created."
  type        = string
  # Example: "123456789012"
}

variable "project_prefix" {
  description = "A unique prefix for your project names to avoid naming conflicts."
  type        = string
  default     = "webapp"
}

variable "environments" {
  description = "A list of all the deployment environments to create."
  type        = list(string)
  default     = ["dev", "qa", "staging", "prod"]
}
