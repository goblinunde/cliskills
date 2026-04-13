---
name: package-rpm-for-fedora
description: 'Use when the user needs to build, repackage, or maintain a Fedora or RHEL-compatible `.rpm` from upstream source code, an existing `.deb`, or a vendor-provided binary `.tar.gz`; when software supports Linux but not Fedora out of the box; or when an existing RPM packaging workflow needs to be updated for a newer upstream release. Strong triggers include "Fedora rpm", "打 rpm 包", "spec 文件", "rpmbuild", "deb 转 rpm", "tar.gz 重打包", "适配 Fedora", "alien", "fpm", and "同步上游版本". Covers three routes: native RPM packaging from source, repackaging `.deb` or binary archives into RPM, and maintaining the packaging workflow as upstream versions continue to change. Do not use for Debian-only packaging, container image publishing, or generic Linux build troubleshooting when RPM output is not the main deliverable.'
---

# Fedora RPM Packaging

Match the user's language. Keep package names, macro names, paths, and exact commands verbatim.

Resolve `SKILL_DIR` to this skill directory before running bundled scripts.

Run `sh SKILL_DIR/scripts/check_toolchain.sh source` for source builds, `sh SKILL_DIR/scripts/check_toolchain.sh repack-deb` for `.deb` repackaging, or `sh SKILL_DIR/scripts/check_toolchain.sh repack-binary` for binary archive repackaging before promising a packaging route.

Read:

- `references/workflow.md` for route selection and end-to-end packaging steps
- `references/spec-rules.md` before creating or editing a `.spec`
- `references/upstream-update.md` when rebasing local packaging work onto a new upstream release or when the checkout is dirty

## Route the task

1. Choose `source` when upstream source is available and Fedora-native packaging is required.
2. Choose `repack-deb` when the user only has a `.deb` and wants a Fedora-compatible RPM.
3. Choose `repack-binary` when the user only has a vendor `.tar.gz` or similar binary archive.
4. Choose `update` when the user already has a prior packaging recipe and wants to move it to a newer upstream version.

If the user starts with `update`, still resolve whether the underlying maintenance route is `source`, `repack-deb`, or `repack-binary`.

## Follow the core rules

- Detect the host, target release, and architecture before writing the commands.
- Prefer native Fedora filesystem macros and dependency names over Debian paths or generic `/usr/local` installs.
- Treat the `.spec` as an editable build artifact. Modify sections, macros, dependencies, scriptlets, patches, and file lists whenever local compatibility requires it.
- Replace Debian-specific maintainer scripts and package assumptions with Fedora-compatible behavior.
- Keep the workflow reproducible: record the upstream version, source URL, checksums, patches, and local compatibility deltas.
- Reuse an existing packaging recipe when upstream publishes a new `.deb` or binary archive.
- When the worktree already contains uncommitted or untracked changes, do not `git pull`; follow `references/upstream-update.md`.

## Deliver the result

- State which route you chose and why.
- Produce or update the `.spec` whenever native RPM packaging or manual repackaging is involved.
- List the required packages or tools for the chosen route.
- Include the verification commands you actually used or would use next.
- State whether the result is a quick repack, a Fedora-native package, or a maintained recipe for future version bumps.
