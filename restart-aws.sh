#!/usr/bin/env bash
set -euo pipefail

if ! aws sts get-caller-identity --profile medichaser &>/dev/null; then
  echo "AWS profile 'medichaser' is not configured or invalid."
  exit 1
fi

if [[ $# -lt 2 || "$1" != "-s" ]]; then
  echo "Usage: $0 -s <value1> [value2 ...]"
  exit 1
fi

shift

if [[ $# -lt 1 ]]; then
  echo "Error: at least one value for -s is required"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TF_DIR="$SCRIPT_DIR/terraform/lightsail"

eval "$(aws configure export-credentials --profile medichaser --format env)"

cd "$TF_DIR"
SERVER_IP="$(terraform output -raw public_ip)"

ssh-keygen -R "$SERVER_IP" >/dev/null 2>&1 || true

CMD=(
  python3.11
  /home/ubuntu/medichaser/medichaser.py
  find-appointment
  -i 15
  -n pushover
  -t "Medicover"
  -r 202
  -s "$@"
)

printf -v REMOTE_CMD "%q " "${CMD[@]}"

echo "Restarting medichaser..."
ssh -t ubuntu@"$SERVER_IP" \
  "tmux kill-session -t medichaser 2>/dev/null || true; tmux new-session -d -s medichaser '$REMOTE_CMD | tee -a medichaser.log'; tmux attach -t medichaser"
