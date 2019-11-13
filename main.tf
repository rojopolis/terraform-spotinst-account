locals {
    cmd = "${path.module}/scripts/spotinst-account"
    account_id = data.external.account.result["account_id"]
    external_id = "spotinst:aws:extid:${random_id.external_id.hex}"
    name = var.name
}

resource "random_id" "external_id" {
  byte_length = 8
}

resource "aws_iam_role" "spotinst"{
    name = "SpotinstRole-${random_id.external_id.hex}"
    provisioner "local-exec" {
        # Without this set-cloud-credentials fails 
        command = "sleep 10"
    }
    assume_role_policy = <<-EOT
        {
            "Version": "2012-10-17",
            "Statement": [
                {
                "Effect": "Allow",
                "Principal": {
                    "AWS": "arn:aws:iam::922761411349:root"
                },
                "Action": "sts:AssumeRole",
                "Condition": {
                    "StringEquals": {
                    "sts:ExternalId": "${local.external_id}"
                    }
                }
                }
            ]
        }
    EOT
}

resource "aws_iam_policy" "spotinst" {
  name        = "Spotinst-Policy-${random_id.external_id.hex}"
  path        = "/"
  description = "Allow Spotinst to manage resources"

  policy = templatefile("${path.module}/spotinst_policy.json", {})
}

resource "aws_iam_role_policy_attachment" "spotinst" {
  role       = "${aws_iam_role.spotinst.name}"
  policy_arn = "${aws_iam_policy.spotinst.arn}"
}

resource "null_resource" "account" {
    provisioner "local-exec" {
        interpreter = ["/bin/bash", "-c"]
        command = "${local.cmd} create ${var.name}"
    }

    provisioner "local-exec" {
        when = "destroy"
        interpreter = ["/bin/bash", "-c"]
        command = <<-EOT
            ID=$(${local.cmd} get --filter=name=${var.name} --attr=account_id) &&\
            ${local.cmd} delete "$ID"
        EOT
    }
}

data "external" "account" {
    depends_on = [null_resource.account]
    program = [
        local.cmd,
        "get",
        "--filter=name=${var.name}"
    ]
}

resource "null_resource" "account_assoiation" {
    depends_on = [aws_iam_role.spotinst]
    provisioner "local-exec" {
        interpreter = ["/bin/bash", "-c"]
        command = "${local.cmd} set-cloud-credentials ${local.account_id} ${aws_iam_role.spotinst.arn} ${local.external_id}"
    } 
}