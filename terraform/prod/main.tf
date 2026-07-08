terraform {
  required_providers {
    dynatrace = {
      source  = "dynatrace-oss/dynatrace"
      version = "~> 1.99"
    }

    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }
}

provider "dynatrace" {}

variable "backup_dir" {
  default = "dynatrace_backup"
}

locals {
  timestamp = formatdate("YYYYMMDD-hhmmss", timestamp())
  export_dir = "${var.backup_dir}/${local.timestamp}"
}

resource "null_resource" "dynatrace_config_export" {
  triggers = {
    always_run = timestamp()
  }

 provisioner "local-exec" {
   environment = {
     DYNATRACE_TARGET_FOLDER = local.export_dir
   }
    command = <<EOT
set -e

mkdir -p $DYNATRACE_TARGET_FOLDER

export DYNATRACE_TARGET_FOLDER="${var.backup_dir}/$(date +'%Y%m%d-%H%M%S')"

PROVIDER_BIN=$(find .terraform/providers/registry.terraform.io/dynatrace-oss/dynatrace -type f -name "terraform-provider-dynatrace*" | head -n 1)

"$PROVIDER_BIN" -export
EOT
  }
}

output "export_dir" {
  value = local.export_dir
}

output "timestamp" {
  value = local.timestamp
}
