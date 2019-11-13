provider "aws" {
    version = "~> 2.35"
}

provider "external" {
    version = "~> 1.2"
}

provider "null" {
    version = "~> 2.1"
}

provider "random" {
    version = "~> 2.2"
}

module "spotinst_account" {
    source = "../"
    name = "rj-test-22"
}

output "spotinst_account" {
    value = module.spotinst_account.spotinst_account
}