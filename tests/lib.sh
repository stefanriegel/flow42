#!/bin/sh
# shellcheck disable=SC2034
set -eu
root=$(CDPATH=''; export CDPATH; cd -- "$(dirname -- "$0")/.." && pwd)
fail() { printf '%s: %s\n' "${TEST_NAME:-test}" "$1" >&2; exit 1; }
