# Upstream update playbook

## Contents

1. Preserve local packaging work safely
2. Update source-based packaging
3. Update `.deb` or binary repackaging
4. Revalidate after the version bump

## Preserve local packaging work safely

When the workspace already has uncommitted or untracked changes, do not run `git pull` directly.

Prefer a local branch plus a local checkpoint commit:

```bash
git switch -c my-local-work
git add -A
git commit -m "WIP: keep local changes"
git fetch origin
git rebase origin/main
```

If the rebase stops on conflicts:

```bash
git add <conflict-file>
git rebase --continue
```

Use `stash` only when a temporary checkpoint is acceptable and include untracked files:

```bash
git stash push -u -m "WIP before pull"
git pull --rebase origin main
git stash pop
```

Use the branch-plus-commit path by default because it is easier to audit and recover.

## Update source-based packaging

When the RPM is built from source:

1. compare the new upstream tag or commit against the current package version
2. fetch upstream changes without discarding local packaging work
3. rebase or replay packaging commits and Fedora-specific patches
4. update `Version`, `Release`, `Source`, checksums, and patch metadata in the `.spec`
5. rebuild and re-run package verification

Keep Fedora-specific patches explicit so they can be refreshed or dropped one by one as upstream changes.

## Update `.deb` or binary repackaging

When the upstream vendor only ships a new `.deb` or binary archive, reuse the previous packaging route first.

Typical update steps:

1. download the new vendor artifact
2. inspect layout changes and dependency changes
3. update the version, release, checksums, and source artifact name
4. reuse the prior `.spec` or conversion command
5. adjust only the parts that changed in the payload

Do not rewrite the whole packaging recipe if the previous route still matches the new artifact.

## Revalidate after the version bump

After any upstream update:

- rebuild the RPM
- inspect payload and dependencies again
- rerun smoke tests for binaries or services
- note whether the old patch set still applies cleanly or needs a new compatibility patch
