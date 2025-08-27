##################################################################################
# main.tf: Core Infrastructure Definitions
#
# This file contains the main set of resources to be created by Terraform.
# It defines the GCP projects, enables APIs, sets up Firebase, creates
# service accounts, and assigns permissions.
##################################################################################

# --- Provider & Random Suffix ---

# Generate a random suffix for project IDs to ensure they are globally unique.
resource "random_id" "project_suffix" {
  byte_length = 4
}

# --- Project Creation ---

# Loop through each environment defined in variables.tf and create a GCP project.
resource "google_project" "project" {
  for_each = toset(var.environments)

  name            = "${var.project_prefix}-${each.key}"
  project_id      = "${var.project_prefix}-${each.key}-${random_id.project_suffix.hex}"
  billing_account = var.gcp_billing_account
  org_id          = var.gcp_org_id
}

# --- API Enablement ---

# Enable the necessary APIs for each project to use Firebase and manage IAM.
resource "google_project_service" "apis" {
  for_each = google_project.project

  project                    = each.value.project_id
  service                    = "firebase.googleapis.com"
  disable_dependent_services = false
}

resource "google_project_service" "cloud_resource_manager_api" {
  for_each = google_project.project

  project = each.value.project_id
  service = "cloudresourcemanager.googleapis.com"
}

resource "google_project_service" "iam_api" {
  for_each = google_project.project

  project = each.value.project_id
  service = "iam.googleapis.com"
}

# --- Firebase Setup ---

# Create the Firebase Project within the corresponding GCP project.
resource "google_firebase_project" "firebase_project" {
  for_each = google_project.project
  provider = google-beta # Firebase resources often require the beta provider
  project  = each.value.project_id

  # Ensure this runs only after the Firebase API is enabled.
  depends_on = [google_project_service.apis]
}

# Set up the default Firebase Hosting site for each project.
resource "google_firebase_hosting_site" "hosting_site" {
  for_each = google_firebase_project.firebase_project
  provider = google-beta
  project  = each.key
  site_id  = each.key # Use the environment name (e.g., "dev") as the site ID
}

# --- Service Account & Permissions for CI/CD ---

# Create a dedicated service account for CI/CD in each project.
resource "google_service_account" "cicd_service_account" {
  for_each = google_project.project

  project      = each.value.project_id
  account_id   = "github-actions-deployer"
  display_name = "GitHub Actions Deployer"
}

# Grant the 'Firebase Admin' role to the service account.
resource "google_project_iam_member" "firebase_admin_role" {
  for_each = google_project.project

  project = each.value.project_id
  role    = "roles/firebase.admin"
  member  = "serviceAccount:${google_service_account.cicd_service_account[each.key].email}"
}

# Grant the 'API Keys Admin' role to the service account.
resource "google_project_iam_member" "api_keys_admin_role" {
  for_each = google_project.project

  project = each.value.project_id
  role    = "roles/apikeys.admin"
  member  = "serviceAccount:${google_service_account.cicd_service_account[each.key].email}"
}

# --- Service Account Key Generation ---

# Generate a JSON key for the service account to be used in GitHub Actions.
resource "google_service_account_key" "cicd_service_account_key" {
  for_each = google_service_account.cicd_service_account

  service_account_id = each.value.name
}
