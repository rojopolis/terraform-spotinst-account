# spotinst-account
[Spotinst](https://spotinst.com/) has a nice [Terraform provider](https://www.terraform.io/docs/providers/spotinst/index.html), however it currently requires a manual step of associating a Spotinst account with an AWS (or other cloud provider) account.

This module attempts to automate this missing step to eliminate automation gap.

## Does
*  Create required AWS IAM policies and roles.
*  Create Spotinst account.
*  Delete Spotinst account on terraform destroy.
*  Set cloud credentials in spotinst account to allow access to your AWS account.

## Does not
* Create Spotinst Organization or root account.

## Environment
| Variable | Description |
|----------|-----------------------------------------|
| SPOTINST_ACCOUNT | Account ID of root Spotinst account. |
| SPOTINST_TOKEN | Spotinst API token. |

## Inputs
| Variable | Description |
|----------|-----------------------------------------|
| name | Name of the spotinst account to create. |

## Outputs
| Output | Description |
|------------------|-----------------------------------------------------------|
| spotinst_account | Data structure representing the created Spotinst account. |

## External dependencies
* python3

## Example
```terraform
module "spotinst_account" {
    source = "../"
    name = "rj-test-22"
}

output "spotinst_account" {
    value = module.spotinst_account.spotinst_account
}
```