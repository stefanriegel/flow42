#!/bin/sh
set -eu

root=$(CDPATH=''; export CDPATH; cd -- "$(dirname -- "$0")" && pwd)
kind=$1
reference=$2

case "$kind:$reference" in
  authenticated-forge:forge:review/42) file=resolved-forge.json ;;
  trusted-orchestrator:orca:review/42) file=resolved-orchestrator.json ;;
  trusted-orchestrator:orca:review/unauthenticated) file=resolved-unauthenticated.json ;;
  *) exit 4 ;;
esac
cat "$root/$file"
