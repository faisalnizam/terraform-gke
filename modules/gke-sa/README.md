## Module for creating service account for Kubernetes cluster nodes

### Input variables:
- `sa_name` - The name of the custom service account. This parameter is limited to a maximum of 28 characters.
- `sa_description` - The description of the custom service account.
- `service_account_roles` - Additional roles to be added to the service account.

### Output varialbes:
- `sa_email` - The email address of the custom service account.
