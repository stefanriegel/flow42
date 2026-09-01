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
           if ($index + 1) >= ($records | length) then
             error("missing porcelain-v2 rename/copy endpoint")
           else
             .paths += [
               ($record | capture("(?s)^2(?: [^ ]+){8} (?<path>.*)$").path),
               $records[$index + 1]
             ] | .skip = true
           end
         elif $record | startswith("1 ") then
           .paths += [
             ($record | capture("(?s)^1(?: [^ ]+){7} (?<path>.*)$").path)
           ]
         elif $record | startswith("u ") then
           .paths += [
             ($record | capture("(?s)^u(?: [^ ]+){9} (?<path>.*)$").path)
           ]
         elif $record | startswith("? ") then
           .paths += [($record[2:])]
         else
           error("unexpected porcelain-v2 record: \($record)")
         end
       end) |
    .paths
  ' "$1"
}

parse_diff_name_status_paths() {
  jq -Rs '
    split("\u0000") | .[:-1] as $records |
    reduce range(0; $records | length) as $index
      ({paths: [], skip: 0};
       if .skip > 0 then
         .skip -= 1
       else
         $records[$index] as $status |
         if $status | test("^[RC][0-9]+$") then
           if ($index + 2) >= ($records | length) then
             error("missing name-status rename/copy endpoint")
           else
             .paths += [$records[$index + 1], $records[$index + 2]] |
             .skip = 2
           end
         elif $status | test("^[ADMRTUXB]$") then
           if ($index + 1) >= ($records | length) then
             error("missing name-status path")
           else
             .paths += [$records[$index + 1]] |
             .skip = 1
           end
         else
           error("unexpected name-status record: \($status)")
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
  grep -Fq "git diff --name-status -z --find-renames \"\$base\" --" "$contract" || {
    printf '%s\n' 'OWNERSHIP-NUL-RENAME-DIFF' >&2
    return 1
  }
  grep -Fq "git --literal-pathspecs add -- \"\$path\"" "$contract" || {
    printf '%s\n' 'OWNERSHIP-LITERAL-PATHSPEC' >&2
    return 1
  }
  grep -Eiq 'both endpoints of every rename|both the source and destination of every rename' "$contract" || {
    printf '%s\n' 'OWNERSHIP-RENAME-ENDPOINTS' >&2
    return 1
  }
  tr '\n' ' ' <"$contract" |
    grep -Eiq 'ordinary tracked.*rename.*unmerged.*untracked' || {
    printf '%s\n' 'OWNERSHIP-PORCELAIN-RECORD-TYPES' >&2
    return 1
  }
  tr '\n' ' ' <"$contract" |
    grep -Eiq 'unknown record type.*fail closed|fail closed.*unknown record type' || {
    printf '%s\n' 'OWNERSHIP-UNKNOWN-RECORD' >&2
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

git -C "$repo" diff --name-status -z --find-renames "$base" -- >"$tmp/tracked-name-status"
parse_diff_name_status_paths "$tmp/tracked-name-status" >"$tmp/tracked-paths.json"
require_path "$tmp/tracked-paths.json" "$deleted_path" OWNERSHIP-DELETE

git -C "$repo" add --all
git -C "$repo" commit -qm 'worker committed changes'
git -C "$repo" status --porcelain=v2 -z --untracked-files=all >"$tmp/committed-status"
test ! -s "$tmp/committed-status" || fail OWNERSHIP-COMMITTED-STATUS-NOT-CLEAN

git -C "$repo" diff --name-only -z --find-renames "$base" -- >"$tmp/committed-name-only"
jq -Rs 'split("\u0000")[:-1]' "$tmp/committed-name-only" >"$tmp/committed-name-only.json"
require_path "$tmp/committed-name-only.json" "$rename_target" OWNERSHIP-NAME-ONLY-TARGET
if jq -e --arg path "$rename_source" 'index($path) != null' "$tmp/committed-name-only.json" >/dev/null; then
  fail OWNERSHIP-NAME-ONLY-CHARACTERIZATION
fi

git -C "$repo" diff --name-status -z --find-renames "$base" -- >"$tmp/committed-name-status"
parse_diff_name_status_paths "$tmp/committed-name-status" >"$tmp/committed-paths.json"
require_path "$tmp/committed-paths.json" "$rename_source" OWNERSHIP-COMMITTED-RENAME-SOURCE
require_path "$tmp/committed-paths.json" "$rename_target" OWNERSHIP-COMMITTED-RENAME-TARGET
if is_owned "$rename_source" && is_owned "$rename_target"; then
  fail OWNERSHIP-COMMITTED-CROSS-BOUNDARY-RENAME-NOT-BLOCKED
fi

conflict_repo="$tmp/conflict-repo"
conflict_path=$(printf 'owned/conflict\nGrüße.txt')
git init -q "$conflict_repo"
git -C "$conflict_repo" config user.name 'Flow42 conflict fixture'
git -C "$conflict_repo" config user.email 'ownership-conflict@example.invalid'
mkdir -p "$conflict_repo/owned"
printf '%s\n' baseline >"$conflict_repo/$conflict_path"
git -C "$conflict_repo" add --all
git -C "$conflict_repo" commit -qm baseline
conflict_base_branch=$(git -C "$conflict_repo" symbolic-ref --short HEAD)
git -C "$conflict_repo" checkout -q -b worker-side
printf '%s\n' worker >"$conflict_repo/$conflict_path"
git -C "$conflict_repo" commit -qam worker
git -C "$conflict_repo" checkout -q "$conflict_base_branch"
printf '%s\n' coordinator >"$conflict_repo/$conflict_path"
git -C "$conflict_repo" commit -qam coordinator
if git -C "$conflict_repo" merge worker-side >"$tmp/conflict-merge.log" 2>&1; then
  fail OWNERSHIP-CONFLICT-FIXTURE-DID-NOT-CONFLICT
fi
git -C "$conflict_repo" status --porcelain=v2 -z --untracked-files=all >"$tmp/conflict-status"
parse_status_paths "$tmp/conflict-status" >"$tmp/conflict-paths.json"
require_path "$tmp/conflict-paths.json" "$conflict_path" OWNERSHIP-UNMERGED-PATH

printf 'x unsupported\0' >"$tmp/unknown-status"
if parse_status_paths "$tmp/unknown-status" >"$tmp/unknown-paths.json" 2>/dev/null; then
  fail OWNERSHIP-UNKNOWN-STATUS-ACCEPTED
fi

printf 'Z\0owned/unsupported\0' >"$tmp/unknown-name-status"
if parse_diff_name_status_paths "$tmp/unknown-name-status" >"$tmp/unknown-diff-paths.json" 2>/dev/null; then
  fail OWNERSHIP-UNKNOWN-NAME-STATUS-ACCEPTED
fi

printf 'R100\0outside/truncated\0' >"$tmp/truncated-name-status"
if parse_diff_name_status_paths "$tmp/truncated-name-status" >"$tmp/truncated-diff-paths.json" 2>/dev/null; then
  fail OWNERSHIP-TRUNCATED-NAME-STATUS-ACCEPTED
fi

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

echo 'ownership ok: NUL paths, committed rename endpoints, dirty identity, literal pathspecs'
