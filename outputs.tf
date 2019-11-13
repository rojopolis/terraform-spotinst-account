output "spotinst_account" {
    description = <<-EOT
        Data structure representing the created Spotinst account.
    EOT
    value = data.external.account.result
}