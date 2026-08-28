---
name: update
description: Update an installed Flow42 plugin from its configured repository or immutable release using the active harness. Use when the user asks to update, upgrade, or refresh Flow42 itself.
---

# Update Flow42

Treat this as plugin maintenance, not a work-item lifecycle stage. Do not create
issues, comments, branches, commits, or Flow42 approval artifacts.

Detect the active harness and inspect its installed plugin/package listing. Read
the installed Flow42 version without printing credentials. Resolve the latest
immutable semantic-version release from the configured Flow42 repository and
report `installed -> available`. Never update from an untagged branch unless the
user explicitly requests a development checkout.

If already current, validate the installed bundle and stop. Otherwise use only
the harness-native update path. Released marketplaces are pinned to immutable
tags, so refreshing the existing marketplace alone cannot advance versions.
Move the pin to the resolved tag, then refresh the plugin:

- Claude Code: record the current marketplace source, remove only the `flow42`
  marketplace, add `stefanriegel/flow42#<resolved-tag>`, then run
  `claude plugin update flow42@flow42`. If add fails, restore the recorded source.
- Codex: record the current marketplace source, remove only the `flow42`
  marketplace, add `stefanriegel/flow42 --ref <resolved-tag>`, then run
  `codex plugin add flow42@flow42 --json`. If add fails, restore the recorded source.
- Pi: read the installed Flow42 source from `pi list`, then install
  `git:github.com/stefanriegel/flow42@<resolved-tag>` explicitly.

Do not edit harness cache directories or copy files into them. Do not uninstall
the plugin merely to force an update; replacing the pinned marketplace source is
the narrow required mutation. If the configured source is a local checkout,
direct the maintainer to that checkout's `scripts/install-local` instead of
replacing it with a release source.

After the update, verify the reported version, manifest, contract, templates,
and all 12 canonical skill directories. A version mismatch or missing component
is a failed update. Report the exact failed check and recovery command without
claiming success. On success, tell the user to restart the harness before using
the new instructions.
