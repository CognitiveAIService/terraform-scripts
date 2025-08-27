##################################################################################
# outputs.tf: Output Definitions
#
# This file specifies what data should be displayed on the command line
# after Terraform successfully applies the configuration. This is useful for
# retrieving generated values like project IDs or sensitive keys.
##################################################################################

output "service_account_keys" {
  description = "The JSON keys for the CI/CD service accounts. Add these to GitHub secrets."
  value = {
    for env, key in google_service_account_key.cicd_service_account_key :
    env => base64decode(key.private_key)
  }
  sensitive = true # Marks the output as sensitive to prevent it from being shown in logs.
}

output "firebase_project_ids" {
  description = "The globally unique IDs of the created Firebase projects."
  value = {
    for env, project in google_project.project :
    env => project.project_id
  }
}

output "hosting_urls" {
  description = "The default hosting URLs for each environment's Firebase project."
  value = {
    for env, project in google_firebase_project.firebase_project :
    env => "https://${project.project_id}.web.app"
  }
}
