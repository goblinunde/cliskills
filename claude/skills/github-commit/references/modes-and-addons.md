# Commit modes and optional add-ons

## Contents

1. Default concise mode
2. Chinese mode
3. Rich commit mode
4. Push mode
5. Optional repository add-ons
6. Safety rules

## Default concise mode

This is the default unless the user explicitly asks otherwise.

Use:

- a single subject line
- a complete shell sequence
- no add-on repository maintenance

Template:

```bash
git status --short
git add path/to/file1 path/to/file2
git commit -m "feat: add github commit skill"
```

Use a short subject that reflects the actual change. Prefer an English imperative subject unless the user explicitly requests Chinese.

## Chinese mode

Activate only when the prompt includes `中文` or an equivalent explicit instruction.

Template:

```bash
git status --short
git add path/to/file1 path/to/file2
git commit -m "新增 GitHub 提交技能"
```

Keep the subject short even in Chinese mode unless rich mode is also requested.

## Rich commit mode

Activate only when the prompt includes `丰富`, `详细`, `完整说明`, or an equivalent explicit instruction.

Use multiple `-m` flags:

```bash
git status --short
git add path/to/file1 path/to/file2
git commit \
  -m "feat: add github commit skill" \
  -m "Default output now favors a concise one-line commit message." \
  -m "Chinese, rich message bodies, README updates, .gitignore changes, workflows, and push commands are enabled only when explicitly requested."
```

If the user also asks for Chinese, write both the subject and body in Chinese.

## Push mode

Activate only when the user explicitly asks to push or submit to GitHub.

Template:

```bash
git status --short
git add path/to/file1 path/to/file2
git commit -m "feat: add github commit skill"
git push origin "$(git branch --show-current)"
```

Do not add `git push` by default.

## Optional repository add-ons

Only perform these when explicitly requested.

### `.gitignore`

Create or update `.gitignore` before staging. Append only missing lines; do not replace an existing file:

```bash
touch .gitignore
grep -qxF 'node_modules/' .gitignore || printf 'node_modules/\n' >> .gitignore
grep -qxF 'dist/' .gitignore || printf 'dist/\n' >> .gitignore
grep -qxF '.env' .gitignore || printf '.env\n' >> .gitignore
git add .gitignore
```

### GitHub Actions / workflow

Create or update workflow files only when the prompt explicitly asks for `workflow`, `action`, or `GitHub Actions`. If the workflow already exists, inspect it and patch only the missing job, step, or trigger instead of replacing the whole file:

```bash
mkdir -p .github/workflows
test -f .github/workflows/ci.yml || cat > .github/workflows/ci.yml <<'EOF'
name: CI
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
EOF
git add .github/workflows/ci.yml
```

### `README.md`

Update `README.md` only when the prompt explicitly asks for README or documentation changes. Patch the relevant section only, then stage it explicitly:

```bash
git add README.md
```

## Safety rules

- Do not invent extra repo-cleanup tasks just because they are commonly useful.
- Do not silently rewrite unrelated docs, workflows, or ignore rules.
- When the repo is dirty, prefer explicit path-based staging.
- When the user asks for "完整的提交代码", provide the full shell sequence, not just the commit message text.
