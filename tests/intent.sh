#!/bin/sh
# shellcheck disable=SC2016
set -eu

root=$(CDPATH=''; export CDPATH; cd -- "$(dirname -- "$0")/.." && pwd)
candidate=${1:-"$root/skills/intent/SKILL.md"}
tmp=$(mktemp -d "${TMPDIR:-/tmp}/flow42-intent-test.XXXXXX")
trap 'rm -rf "$tmp"' EXIT HUP INT TERM

require_phrase() {
  phrase=$1
  printf '%s\n' "$intent_text" | grep -F -q "$phrase" || {
    echo "intent contract missing: $phrase" >&2
    intent_contract_failed=1
  }
}

check_intent_contract() {
  intent_contract_failed=0
  intent_text=$(tr '\n' ' ' <"$1" | tr -s ' ')
  line_count=$(wc -l <"$1" | tr -d ' ')

  test "$line_count" -ge 15 && test "$line_count" -le 60 || {
    echo "intent skill violates 15-60 line house style: $line_count" >&2
    intent_contract_failed=1
  }
  test "$(grep -c '^# ' "$1")" -eq 1 || {
    echo 'intent skill must have exactly one H1' >&2
    intent_contract_failed=1
  }
  if grep -E -q '^##|^[-*] ' "$1"; then
    echo 'intent skill must remain imperative prose without subheadings or bullets' >&2
    intent_contract_failed=1
  fi

  require_phrase '^[a-z0-9][a-z0-9-]{0,62}$'
  require_phrase 'Create a lowercase work ID'
  require_phrase 'reject unsafe or colliding paths'
  require_phrase 'every work-item template'
  require_phrase 'using native harness file operations'
  require_phrase 'revision-1 creation event'
  require_phrase 'problem, desired outcome, users, constraints, non-goals, acceptance signals, assumptions, and risks'
  require_phrase 'research public facts when useful'
  require_phrase 'Reread the completed artifact before advancing'
  require_phrase 'intent capture has no gate before specification'
  require_phrase 'transition directly from `draft-intent` to `drafting-spec`'
  require_phrase 'incrementing the revision'
  require_phrase 'atomically updating status'
  require_phrase 'appending history'
  require_phrase 'rereading both'

  require_phrase 'objective stop condition after initial inspection and every answer'
  require_phrase 'no unresolved question can materially change outcome, risk, confidentiality, or cost'
  require_phrase 'headless or automated run'
  require_phrase 'do not choose the recommendation, infer an answer, or advance'
  require_phrase 'single durable source'
  require_phrase 'After each answer, atomically update and reread `intent.md`'
  require_phrase 'Give each unresolved material question a stable identifier'
  require_phrase 'Append a resolved consequential choice to `decisions.md`'
  require_phrase 'Keep mutable lifecycle state only in `status.yml`'
  require_phrase 'refer to question identifiers instead of copying question text into blockers or next actions'
  require_phrase '`history.jsonl` records transitions rather than interview content'
  require_phrase 'resume from the first unresolved material question'
  require_phrase 'If status is blocked for that question, ask and durably record its answer before clearing the blocker'
  require_phrase 'If status remains `draft-intent` after an interruption, ask it directly'
  require_phrase 'State each decision neutrally'
  require_phrase 'credible alternatives and tradeoffs on equal footing'
  require_phrase 'recommended answer is non-binding'
  require_phrase 'Never treat silence, lack of objection, or the recommendation itself as consent'
  require_phrase 'data minimization'
  require_phrase 'Never request or persist secrets, credentials, private records, or raw personal or customer data'
  require_phrase 'trivial-change fast path'
  require_phrase 'ask no questions and complete the intent directly'

  test "$intent_contract_failed" -eq 0
}

check_intent_contract "$candidate"

mutation=0
for marker in \
  'objective stop condition' \
  'headless or automated run' \
  'single durable source' \
  'resume from the first unresolved material' \
  'non-binding' \
  'data minimization' \
  'trivial-change fast path'; do
  mutation=$((mutation + 1))
  mutated="$tmp/mutation-$mutation.md"
  sed "s/$marker/removed-contract-$mutation/g" "$candidate" >"$mutated"
  if check_intent_contract "$mutated" >/dev/null 2>&1; then
    echo "intent adversarial mutation survived: $marker" >&2
    exit 1
  fi
done

echo 'intent contract ok: bounded interview, durable resume, consent, confidentiality, fast path'
