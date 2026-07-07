terraform {
  required_providers {
    dynatrace = {
      source  = "dynatrace-oss/dynatrace"
      version = "~> 1.98"
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

resource "null_resource" "dynatrace_config_export" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = <<EOT
set -e

mkdir -p ${var.backup_dir}

export DYNATRACE_TARGET_FOLDER="${var.backup_dir}/$(date +'%Y%m%d-%H%M%S')"

PROVIDER_BIN=$(find .terraform/providers/registry.terraform.io/dynatrace-oss/dynatrace -type f -name "terraform-provider-dynatrace*" | head -n 1)

"$PROVIDER_BIN" -export -ref -id -flat
EOT
  }
}

output "backup_location" {
  value = var.backup_dir
}
