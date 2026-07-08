#!/usr/bin/env bash
set -euo pipefail

if ! aws sts get-caller-identity --profile medichaser &>/dev/null; then
  echo "AWS profile 'medichaser' is not configured or invalid."
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TF_DIR="$SCRIPT_DIR/terraform/lightsail"

eval "$(aws configure export-credentials --profile medichaser --format env)"

cd "$TF_DIR"

terraform destroy -auto-approve