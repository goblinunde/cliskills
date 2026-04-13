# Spec editing rules

## Contents

1. Start from Fedora conventions
2. Edit the required sections
3. Handle patches cleanly
4. Translate maintainer scripts carefully
5. Verify install and file ownership

## Start from Fedora conventions

Prefer a native `.spec` over ad hoc shell commands. Use macros instead of hard-coded paths whenever possible:

- `%{_bindir}`
- `%{_sbindir}`
- `%{_libdir}`
- `%{_libexecdir}`
- `%{_datadir}`
- `%{_unitdir}`
- `%{_sysconfdir}`
- `%{_localstatedir}`

Keep the `.spec` readable and maintainable. If the package requires multiple compatibility patches, store them explicitly in `SOURCES/` and apply them with `%autosetup` or `%patch`.

## Edit the required sections

Review at least these sections when adapting software for Fedora:

- `Name`, `Version`, `Release`, `Summary`, `License`, `URL`, `Source`
- `BuildRequires` and `Requires`
- `%prep`
- `%build`
- `%install`
- `%check`
- `%files`

Pay special attention to:

- Fedora dependency names instead of Debian dependency names
- correct license tagging and `%license` entries
- `%doc` entries for release notes or manuals that should not affect runtime behavior
- executable permissions, library ownership, and configuration file markers

## Handle patches cleanly

When upstream source needs Fedora-specific changes:

1. carry the change as a patch file
2. describe the patch briefly in the `.spec`
3. keep the patch minimal and forward-portable

Typical patch targets:

- non-standard install destinations
- Debian-specific package checks
- hard-coded interpreters or shell paths
- service units or desktop integration
- compiler or linker flags that break on Fedora toolchains

Avoid shipping a `.spec` that depends on undocumented manual edits inside the unpacked source tree.

## Translate maintainer scripts carefully

When converting from `.deb`, inspect maintainer scripts and translate only what RPM needs.

Common translations:

- service reload or daemon-reload handling
- icon cache or desktop database refresh
- shared library cache refresh
- user/group creation when the package truly requires a dedicated account

Avoid copying `postinst` or `prerm` line-for-line. Convert the intent to RPM scriptlets and use standard Fedora helpers where appropriate.

## Verify install and file ownership

Before building or delivering the package, confirm:

- `%files` matches the real install tree
- config files that users may edit are marked appropriately
- directories are owned by the correct package or an existing system package
- no file is installed under an arbitrary vendor path when a Fedora macro exists
- service units, tmpfiles, sysusers, and desktop assets live in their standard locations
