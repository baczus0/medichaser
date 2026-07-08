#!/usr/bin/env bash
set -euo pipefail

if ! aws sts get-caller-identity --profile medichaser &>/dev/null; then
  echo "AWS profile 'medichaser' is not configured or invalid."
  exit 1
fi

eval "$(aws configure export-credentials --profile medichaser --format env)"

cd terraform/lightsail
SERVER_IP="$(terraform output -raw public_ip)"

ssh -t ubuntu@"$SERVER_IP" '
tmux attach -t medichaser || true
bash
'