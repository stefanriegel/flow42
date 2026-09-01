#!/bin/sh
set -eu

# Behavioural: exercise Git's NUL-delimited status and literal path handling in
# a disposable repository. Text assertions below only bind the shipped
# instructions to the behaviour demonstrated here.

root=$(CDPATH=''; export CDPATH; cd -- "$(dirname -- "$0")/.." && pwd)
tmp=$(mktemp -d "${TMPDIR:-/tmp}/flow42-ownership.XXXXXX")
trap 'find "$tmp" -depth -delete' EXIT HUP INT TERM
repo="$tmp/repo"

fail() {
  printf 'ownership failed: %s\n' "$1" >&2
  exit 1
}

require_path() {
  json_file=$1
  exact_path=$2
  diagnostic=$3
  jq -e --arg path "$exact_path" 'index($path) != null' "$json_file" >/dev/null ||
    fail "$diagnostic"
}

parse_status_paths() {
  jq -Rs '
    split("\u0000") | .[:-1] as $records |
    reduce range(0; $records | length) as $index
      ({paths: [], skip: false};
       if .skip then
         .skip = false
       else
         $records[$index] as $record |
         if $record | startswith("2 ") then
           .paths += [
             ($record | capture("(?s)^2(?: [^ ]+){8} (?<path>.*)$").path),
             $records[$index + 1]
           ] | .skip = true
         elif $record | startswith("1 ") then
           .paths += [
             ($record | capture("(?s)^1(?: [^ ]+){7} (?<path>.*)$").path)
           ]
         elif $record | startswith("? ") then
           .paths += [($record[2:])]
         else
           .
         end
       end) |
    .paths
  ' "$1"
}

is_owned() {
  candidate=$1
  case "$candidate" in
    '' | /* | ../* | */../* | */..)
      return 1
      ;;
    owned | owned/*)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

dirty_overlap_allowed() {
  before_identity=$1
  after_identity=$2
  explicitly_handed_off=$3
  test "$before_identity" = "$after_identity" ||
    test "$explicitly_handed_off" = true
}

validate_contract() {
  contract=$1
  grep -Fq 'git status --porcelain=v2 -z --untracked-files=all' "$contract" || {
    printf '%s\n' 'OWNERSHIP-NUL-STATUS' >&2
    return 1
  }
  grep -Fq "git diff --name-only -z \"\$base\" --" "$contract" || {
    printf '%s\n' 'OWNERSHIP-NUL-DIFF' >&2
    return 1
  }
  grep -Fq "git --literal-pathspecs add -- \"\$path\"" "$contract" || {
    printf '%s\n' 'OWNERSHIP-LITERAL-PATHSPEC' >&2
    return 1
  }
  grep -Eiq 'both endpoints of every rename' "$contract" || {
    printf '%s\n' 'OWNERSHIP-RENAME-ENDPOINTS' >&2
    return 1
  }
  grep -Eiq 'content (hash|identity)' "$contract" || {
    printf '%s\n' 'OWNERSHIP-DIRTY-IDENTITY' >&2
    return 1
  }
  tr '\n' ' ' <"$contract" |
    grep -Eiq 'block integration.*pre-existing dirty path|pre-existing dirty path.*block integration' || {
    printf '%s\n' 'OWNERSHIP-DIRTY-OVERLAP' >&2
    return 1
  }
  if grep -Eiq 'path snapshots? may be split on (a )?newline|ordinary pathspec interpretation' "$contract"; then
    printf '%s\n' 'OWNERSHIP-CONTRADICTORY-EXCEPTION' >&2
    return 1
  fi
}

git init -q "$repo"
git -C "$repo" config user.name 'Flow42 ownership fixture'
git -C "$repo" config user.email 'ownership@example.invalid'

space_path='owned/space name.txt'
tab_path=$(printf 'owned/tab\tname.txt')
utf8_path='owned/Grüße.txt'
newline_path=$(printf 'outside/line\nquote"name.txt')
leading_path='-leading.txt'
rename_source=$(printf 'outside/rename\tsource.txt')
rename_target=$(printf 'owned/rename\ntarget.txt')
deleted_path='owned/delete me.txt'
dirty_path='owned/already dirty.txt'
literal_path='owned/[literal].txt'
lookalike_path='owned/l.txt'

mkdir -p "$repo/owned" "$repo/outside"
for path in "$space_path" "$tab_path" "$utf8_path" "$leading_path" \
  "$rename_source" "$deleted_path" "$dirty_path" "$literal_path" \
  "$lookalike_path"; do
  printf 'baseline %s\n' "$path" >"$repo/$path"
done
git -C "$repo" add --all
git -C "$repo" commit -qm baseline
base=$(git -C "$repo" rev-parse HEAD)

printf '%s\n' coordinator >>"$repo/$dirty_path"
git -C "$repo" status --porcelain=v2 -z --untracked-files=all >"$tmp/pre-status"
parse_status_paths "$tmp/pre-status" >"$tmp/pre-paths.json"
require_path "$tmp/pre-paths.json" "$dirty_path" OWNERSHIP-PRE-DIRTY-MISSING
pre_dirty_hash=$(git -C "$repo" hash-object -- "$dirty_path")

printf '%s\n' worker >>"$repo/$dirty_path"
printf '%s\n' worker >>"$repo/$space_path"
printf '%s\n' worker >>"$repo/$tab_path"
printf '%s\n' worker >>"$repo/$utf8_path"
printf '%s\n' worker >>"$repo/$leading_path"
printf '%s\n' worker >>"$repo/$literal_path"
printf '%s\n' worker >>"$repo/$lookalike_path"
git -C "$repo" mv -- "$rename_source" "$rename_target"
git -C "$repo" rm -q -- "$deleted_path"
printf '%s\n' worker >"$repo/$newline_path"

git -C "$repo" status --porcelain=v2 -z --untracked-files=all >"$tmp/post-status"
parse_status_paths "$tmp/post-status" >"$tmp/post-paths.json"
for path in "$space_path" "$tab_path" "$utf8_path" "$newline_path" \
  "$leading_path" "$rename_source" "$rename_target" "$deleted_path" \
  "$dirty_path" "$literal_path" "$lookalike_path"; do
  require_path "$tmp/post-paths.json" "$path" OWNERSHIP-NUL-EXACT-PATH
done

git -C "$repo" status --short >"$tmp/line-status"
jq -Rsc 'split("\n")[:-1]' "$tmp/line-status" >"$tmp/line-paths.json"
if jq -e --arg path "$newline_path" 'index($path) != null' "$tmp/line-paths.json" >/dev/null; then
  fail OWNERSHIP-LINE-COLLECTOR-CHARACTERIZATION
fi

is_owned 'owned/x' || fail OWNERSHIP-EXACT-PREFIX
if is_owned 'owned-other/x' || is_owned "$newline_path" || is_owned "$rename_source" ||
  is_owned "$leading_path" || is_owned '../owned/x' || is_owned '/owned/x'; then
  fail OWNERSHIP-FAIL-CLOSED-PREFIX
fi
is_owned "$rename_target" || fail OWNERSHIP-RENAME-TARGET

post_dirty_hash=$(git -C "$repo" hash-object -- "$dirty_path")
test "$pre_dirty_hash" != "$post_dirty_hash" || fail OWNERSHIP-DIRTY-IDENTITY
require_path "$tmp/post-paths.json" "$dirty_path" OWNERSHIP-DIRTY-COLLISION
if dirty_overlap_allowed "$pre_dirty_hash" "$post_dirty_hash" false; then
  fail OWNERSHIP-DIRTY-OVERLAP-NOT-BLOCKED
fi
dirty_overlap_allowed "$pre_dirty_hash" "$post_dirty_hash" true ||
  fail OWNERSHIP-EXPLICIT-DIRTY-HANDOFF

git -C "$repo" reset -q
git -C "$repo" --literal-pathspecs add -- "$literal_path"
git -C "$repo" diff --cached --name-only -z >"$tmp/staged"
jq -Rs 'split("\u0000")[:-1]' "$tmp/staged" >"$tmp/staged.json"
test "$(jq 'length' "$tmp/staged.json")" -eq 1 || fail OWNERSHIP-PATHSPEC-COLLISION
require_path "$tmp/staged.json" "$literal_path" OWNERSHIP-LITERAL-PATHSPEC

git -C "$repo" reset -q
git -C "$repo" --literal-pathspecs add -- "$leading_path"
git -C "$repo" diff --cached --name-only -z >"$tmp/leading-staged"
jq -Rs 'split("\u0000")[:-1]' "$tmp/leading-staged" >"$tmp/leading-staged.json"
test "$(jq 'length' "$tmp/leading-staged.json")" -eq 1 || fail OWNERSHIP-LEADING-DASH
require_path "$tmp/leading-staged.json" "$leading_path" OWNERSHIP-LEADING-DASH

git -C "$repo" diff --name-only -z "$base" -- >"$tmp/tracked"
jq -Rs 'split("\u0000")[:-1]' "$tmp/tracked" >"$tmp/tracked.json"
require_path "$tmp/tracked.json" "$deleted_path" OWNERSHIP-DELETE

validate_contract "$root/core/OWNERSHIP.md"

cp "$root/core/OWNERSHIP.md" "$tmp/mutated-newline.md"
printf '%s\n' 'As an exception, path snapshots may be split on newline.' >>"$tmp/mutated-newline.md"
if validate_contract "$tmp/mutated-newline.md" >/dev/null 2>&1; then
  fail OWNERSHIP-MUTATION-NEWLINE-ACCEPTED
fi

cp "$root/core/OWNERSHIP.md" "$tmp/mutated-pathspec.md"
printf '%s\n' 'As an exception, recovery may stage names with ordinary pathspec interpretation.' >>"$tmp/mutated-pathspec.md"
if validate_contract "$tmp/mutated-pathspec.md" >/dev/null 2>&1; then
  fail OWNERSHIP-MUTATION-PATHSPEC-ACCEPTED
fi

echo 'ownership ok: NUL paths, rename endpoints, dirty identity, literal pathspecs'
