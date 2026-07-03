#!/usr/bin/env bash
set -euo pipefail

if ! aws sts get-caller-identity &>/dev/null; then
  echo "Not logged in to AWS. Run: aws login"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TF_DIR="$SCRIPT_DIR/terraform/lightsail"

eval "$(aws configure export-credentials --profile default --format env)"

cd "$TF_DIR"

terraform destroy -auto-approve