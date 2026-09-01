# Installation

Flow42 is distributed as a single skill through the community skills CLI, not
a per-harness marketplace plugin. It requires `git` and `jq`, and Orca with
orchestration enabled. `gh` or `glab` are needed only for Forge work.

## Install

```sh
npx skills add stefanriegel/flow42 --skill flow42
```

This works the same way for a Claude Code target and a Codex target — the
skills CLI resolves the harness itself. `orca skills install` performs the
same operation through Orca's UI, and is the recommended path when you are
already working inside Orca.

## Verify the install

```sh
npx skills list
```

or the harness-native equivalent (`skills installed`). Confirm `flow42` is
listed at the version you expect, then start a fresh agent session — an
already-running session does not pick up a new install.

## Update

```sh
npx skills add stefanriegel/flow42 --skill flow42
```

at the tag you want (see [Migration](MIGRATION.md) for the v2 → v3 path), or
run the skill's own `update` stage from inside a repository, which reports the
installed version and refreshes it through this same mechanism. If your
runtime pins skill versions through Orca Settings, update there instead.

## Uninstall

Use the skills CLI's or harness's native removal command for the `flow42`
skill; there is no separate marketplace entry or plugin cache to clean up
beyond that.

## Enable Orca orchestration

Flow42 requires a ready Orca runtime. In Orca, enable orchestration under
**Settings → Experimental**, then confirm it with:

```sh
orca status --json
```

`runtime.state` must report `ready`. Without it, every stage blocks at its
first preflight check rather than falling back silently.
