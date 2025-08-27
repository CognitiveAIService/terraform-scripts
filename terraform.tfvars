# terraform.tfvars

# -->>>>*Do NOT commit this file to a public Git repository if it contains sensitive information.*<<<-----

# Provide the actual values for your project here.
# Terraform will automatically use these values when you run `plan` or `apply`.
#
# NOTE: Replace the placeholder values below with your real GCP information.

# You can find this in the GCP Console under "Billing".
gcp_billing_account = "012345-67890A-BCDEF1"

# You can find this in the GCP Console under "IAM & Admin" -> "Manage Resources".
gcp_org_id          = "123456789012"

# Choose a unique, lowercase prefix for your application.
project_prefix      = "my-english-app"
