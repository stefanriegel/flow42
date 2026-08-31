#!/bin/sh
# shellcheck disable=SC2016
set -eu

root=$(CDPATH=''; export CDPATH; cd -- "$(dirname -- "$0")/.." && pwd)
candidate=${1:-"$root/skills/intent/SKILL.md"}
fixture_dir="$root/tests/fixtures/intent"
tmp=$(mktemp -d "${TMPDIR:-/tmp}/flow42-intent-test.XXXXXX")
trap 'rm -rf "$tmp"' EXIT HUP INT TERM

require_phrase() {
  phrase=$1
  printf '%s\n' "$intent_text" | grep -F -q "$phrase" || {
    echo "intent contract missing: $phrase" >&2
    intent_contract_failed=1
  }
}

require_paragraph_sequence() {
  label=$1
  first=$2
  second=$3
  third=$4

  awk -v first="$first" -v second="$second" -v third="$third" '
    BEGIN { RS = ""; found = 0 }
    {
      paragraph = $0
      gsub(/[[:space:]]+/, " ", paragraph)
      first_position = index(paragraph, first)
      second_position = index(paragraph, second)
      third_position = index(paragraph, third)
      if (first_position > 0 &&
          second_position > first_position &&
          third_position > second_position) {
        found = 1
      }
    }
    END { exit found ? 0 : 1 }
  ' "$intent_file" || {
    echo "intent contract relationship missing: $label" >&2
    intent_contract_failed=1
  }
}

reject_semantic_pattern() {
  label=$1
  pattern=$2
  if printf '%s\n' "$intent_text" | grep -E -i -q "$pattern"; then
    echo "intent contract forbids: $label" >&2
    intent_contract_failed=1
  fi
}

check_intent_inventory() {
  intent_contract_failed=0
  intent_file=$1
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

check_intent_semantics() {
  intent_contract_failed=0
  intent_file=$1
  intent_text=$(tr '\n' ' ' <"$1" | tr -s ' ')

  require_paragraph_sequence \
    'repository inspection precedes dependency-ordered single questions' \
    'Inspect the repository and existing work items' \
    'before asking' \
    'asking one question at a time'
  require_paragraph_sequence \
    'recommendation remains non-binding until the user explicitly answers' \
    'recommended answer is non-binding' \
    'explicitly ask the user to answer' \
    'Never treat silence, lack of objection, or the recommendation itself as consent'
  require_paragraph_sequence \
    'material uncertainty, not a question count, controls the stop condition' \
    'objective stop condition after initial inspection and every answer' \
    'stop interviewing only when every required intent section is evidence-backed' \
    'no unresolved question can materially change outcome, risk, confidentiality, or cost'
  require_paragraph_sequence \
    'headless runs persist uncertainty instead of selecting the recommendation' \
    'If a headless or automated run lacks an interactive answer channel' \
    'persist known unresolved material questions' \
    'do not choose the recommendation, infer an answer, or advance'
  require_paragraph_sequence \
    'headless unresolved material questions transition to blocked' \
    'do not choose the recommendation, infer an answer, or advance' \
    'Atomically transition to `blocked`' \
    'reread both'

  reject_semantic_pattern \
    'questions before repository inspection' \
    '(ask|question)[^.;]{0,96}before[[:space:]]+(repository[[:space:]]+)?(inspection|inspecting)'
  reject_semantic_pattern \
    'silence can become consent' \
    'as consent[[:space:]]+(unless|except|if|when|until)|silence[^.;]{0,80}(means|counts as|is|signals|implies)[[:space:]]+(user[[:space:]]+)?consent'
  reject_semantic_pattern \
    'fixed question count' \
    'stop[[:space:]]+after[[:space:]]+((one|two|three|four|five|six|seven|eight|nine|ten|[[:digit:]]+)[[:space:]]+questions?|a[[:space:]]+fixed[[:space:]]+question[[:space:]]+(count|limit|cap))|stop[^.;]{0,80}(even|despite|while)[^.;]{0,48}material[[:space:]]+(uncertainty|question|decision|branch)'
  reject_semantic_pattern \
    'headless recommendation choice' \
    'do not choose the recommendation, infer an answer, or advance[[:space:]]+(unless|except|if|when)|(in|for|when)[[:space:]]+(a[[:space:]]+)?(headless|automated)([[:space:]]+(mode|run))?[^.;]{0,80}(choose|select|accept|default to)[^.;]{0,48}(recommendation|recommended answer)'
  reject_semantic_pattern \
    'single-question rule with an exception' \
    'one question at a time[[:space:]]+(only|unless|except|for)'
  reject_semantic_pattern \
    'batched questions' \
    '(batch|ask|present|send|collect)[^.;]{0,64}(all|multiple|several)[^.;]{0,48}questions|questions[^.;]{0,48}(at once|together|in (a|one) batch)'

  test "$intent_contract_failed" -eq 0
}

check_intent_contract() {
  contract_failed=0
  check_intent_inventory "$1" || contract_failed=1
  check_intent_semantics "$1" || contract_failed=1
  test "$contract_failed" -eq 0
}

expect_reviewer_mutation_rejected() {
  fixture=$1
  fixture_name=${fixture##*/}
  fixture_name=${fixture_name%.sed}
  mutated="$tmp/$fixture_name.md"
  diagnostics="$tmp/$fixture_name.log"

  case "$fixture_name" in
    ask-before-inspection) expected='questions before repository inspection' ;;
    silence-as-consent) expected='silence can become consent' ;;
    fixed-question-count) expected='fixed question count' ;;
    headless-chooses-recommendation) expected='headless recommendation choice' ;;
    batch-questions) expected='batched questions' ;;
    *)
      echo "unknown intent reviewer fixture: $fixture_name" >&2
      exit 1
      ;;
  esac

  sed -f "$fixture" "$candidate" >"$mutated"
  if cmp -s "$candidate" "$mutated"; then
    echo "intent reviewer fixture did not mutate candidate: $fixture_name" >&2
    exit 1
  fi
  if ! check_intent_inventory "$mutated" >"$diagnostics" 2>&1; then
    echo "intent reviewer fixture no longer preserves the phrase inventory: $fixture_name" >&2
    exit 1
  fi
  if check_intent_contract "$mutated" >"$diagnostics" 2>&1; then
    echo "intent semantic reviewer mutation survived: $fixture_name" >&2
    exit 1
  fi
  if ! grep -F -q "intent contract forbids: $expected" "$diagnostics"; then
    echo "intent reviewer fixture failed for the wrong reason: $fixture_name" >&2
    sed -n '1,120p' "$diagnostics" >&2
    exit 1
  fi
  echo "ok intent reviewer mutation rejected: $fixture_name"
}

check_intent_contract "$candidate"

for fixture in "$fixture_dir"/*.sed; do
  test -f "$fixture" || {
    echo "intent reviewer fixtures missing: $fixture_dir" >&2
    exit 1
  }
  expect_reviewer_mutation_rejected "$fixture"
done

echo 'intent contract ok: bounded interview, durable resume, consent, confidentiality, fast path'
