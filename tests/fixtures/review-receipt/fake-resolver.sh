#!/bin/sh
set -eu

root=$(CDPATH=''; export CDPATH; cd -- "$(dirname -- "$0")" && pwd)
kind=$1
reference=$2

case "$kind:$reference" in
  authenticated-forge:forge:review/42) file=resolved-forge.json ;;
  authenticated-forge:forge:review/time-mismatch) file=resolved-forge-time-mismatch.json ;;
  trusted-orchestrator:orca:review/42) file=resolved-orchestrator.json ;;
  trusted-orchestrator:orca:review/unauthenticated) file=resolved-unauthenticated.json ;;
  local-independent-pass:local:review/42) file=resolved-local.json ;;
  local-independent-pass:local:security/42) file=resolved-local-security.json ;;
  local-independent-pass:local:review/not-distinct) file=resolved-local-not-distinct.json ;;
  *) exit 4 ;;
esac
cat "$root/$file"
