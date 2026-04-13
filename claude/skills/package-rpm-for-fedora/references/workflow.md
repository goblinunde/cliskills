# Fedora RPM packaging workflow

## Contents

1. Inspect the environment
2. Choose the packaging route
3. Build from source
4. Repackage from `.deb`
5. Repackage from binary `.tar.gz`
6. Validate the RPM output

## Inspect the environment

Start every task by confirming:

- target distribution and release
- target architecture
- whether the package is source-first or artifact-first
- whether the workspace already contains packaging files, local patches, or vendor customizations

Useful commands:

```bash
cat /etc/os-release
uname -m
rpm --eval '%{_arch}'
rpm --eval '%{_topdir}'
```

Run the packaged checker first:

```bash
sh SKILL_DIR/scripts/check_toolchain.sh source
sh SKILL_DIR/scripts/check_toolchain.sh repack-deb
sh SKILL_DIR/scripts/check_toolchain.sh repack-binary
```

Use `source` for upstream code builds, `repack-deb` for `.deb` conversions, and `repack-binary` for binary archive conversions.

## Choose the packaging route

Use this routing table:

| Input | Preferred route | Reason |
| --- | --- | --- |
| Upstream source repository or source tarball | Native RPM from source | Most maintainable; easiest to carry patches forward |
| Only a vendor `.deb` | Repackage from `.deb` | Reuse vendor payload while adapting to Fedora |
| Only a vendor binary `.tar.gz` | Repackage from binary archive | Fastest path when no source package exists |
| Existing RPM recipe + new upstream version | Update prior route | Preserve the established packaging method |

When both source and binary artifacts are available, prefer the source route unless the user explicitly asks for a rapid binary repack.

## Build from source

Use this route when upstream supports Linux generally but does not ship a Fedora RPM.

1. Create or verify the RPM build tree.
2. Capture the exact upstream version or commit.
3. Identify Debian-only assumptions, hard-coded install paths, bundled libraries, and service integration points.
4. Write or update the `.spec`.
5. Carry local compatibility changes as explicit patches instead of hand-editing the unpacked sources without documentation.
6. Build with `rpmbuild -ba`.

Starter commands:

```bash
rpmdev-setuptree
spectool -g -R SPECS/example.spec
rpmbuild -ba SPECS/example.spec
```

When the upstream project already uses `make`, `cmake`, `meson`, `cargo`, or similar tooling, encode that build logic in `%build` and `%install`. Avoid telling the user to build once manually and copy files into the RPM tree unless the upstream project truly has no install target.

Adapt these common incompatibilities:

- replace `/usr/local` with Fedora macros such as `%{_bindir}`, `%{_libdir}`, `%{_datadir}`, `%{_unitdir}`, and `%{_sysconfdir}`
- replace Debian package names in dependency checks with Fedora package names
- move init scripts or systemd units into the correct Fedora locations
- fix ownership, permissions, desktop files, icons, and `ldconfig` handling
- add `%check` when upstream has a usable test target

## Repackage from `.deb`

Use this route when the vendor only publishes a Debian package.

Inspect the payload first:

```bash
dpkg-deb -I vendor-package.deb
dpkg-deb -c vendor-package.deb
```

Choose the least fragile path:

1. Use `alien -r -g vendor-package.deb` when `alien` is available and the package layout is simple.
2. Use `dpkg-deb -x` and `dpkg-deb -e` plus a hand-edited `.spec` when maintainer scripts, file ownership, dependencies, or service layout need Fedora-specific changes.
3. Use `fpm` when the payload is straightforward and you need a fast conversion, then inspect and refine the result rather than trusting the first build blindly.

Manual extraction path:

```bash
mkdir -p /tmp/pkg-root /tmp/pkg-control
dpkg-deb -x vendor-package.deb /tmp/pkg-root
dpkg-deb -e vendor-package.deb /tmp/pkg-control
```

After extraction:

- inspect postinst/prerm logic and translate only what Fedora actually needs
- rewrite dependency names
- decide whether scriptlets belong in `%post`, `%preun`, or `%postun`
- normalize file locations under Fedora macros
- build with `rpmbuild -bb`

Do not blindly copy Debian maintainer scripts into RPM scriptlets. Translate the intent, not the syntax.

## Repackage from binary `.tar.gz`

Use this route when the vendor ships a binary archive but not a source package.

Inspect the archive layout before writing the `.spec`:

```bash
tar -tzf vendor-binary.tar.gz | head
```

Decide whether the archive already has a sane install root. If it does not:

- stage the files into a clean build root
- move binaries, libraries, shared data, desktop entries, and systemd units into Fedora-compatible locations
- create symlinks only when the runtime layout requires them

Use `fpm` only for very simple payloads. For anything involving services, desktop integration, shared libraries, users/groups, or `%config` files, write a real `.spec`.

## Validate the RPM output

Always inspect the built RPM before calling the job finished.

Useful checks:

```bash
rpm -qpl path/to/package.rpm
rpm -qpR path/to/package.rpm
rpm -K path/to/package.rpm
```

Use these checks when available:

- `rpmlint path/to/package.rpm path/to/package.spec`
- install test on a matching host or container
- smoke-test the installed binary or service

Before finishing, confirm:

- the package name, version, release, and architecture are correct
- dependencies match Fedora package names
- service files, desktop files, icons, and configs land in the expected directories
- the package can be rebuilt with the documented procedure
