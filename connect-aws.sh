#!/usr/bin/env bash
set -euo pipefail

if ! aws sts get-caller-identity &>/dev/null; then
  echo "Not logged in to AWS. Run: aws login"
  exit 1
fi

eval "$(aws configure export-credentials --profile default --format env)"

cd terraform/lightsail
SERVER_IP="$(terraform output -raw public_ip)"

ssh -t ubuntu@"$SERVER_IP" '
tmux attach -t medichaser || true
bash
'