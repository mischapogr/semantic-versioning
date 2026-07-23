# Running semantic-release locally (Linux Mint)

`semantic-release` normally runs in CI, but you can run it **locally in dry-run
mode** to preview the next version and release notes before pushing. This never
publishes anything as long as you keep `--dry-run`.

## 1. Install Node.js (npx ships with npm)

`semantic-release@24` requires **Node.js >= 20.8.1**. Linux Mint's default
`apt` package (`nodejs`) is usually too old, so use one of these:

### Option A — nvm (recommended, per-user, no sudo)

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
# open a new terminal (or: source ~/.bashrc)
nvm install --lts
node -v      # v20+ (v24 works)
npm -v
npx -v       # bundled with npm
```

### Option B — NodeSource apt repo (system-wide)

```bash
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt-get install -y nodejs
node -v && npm -v
```

### Option C — Mint's own repo (only if it's new enough)

```bash
sudo apt update && sudo apt install -y nodejs npm
node -v      # must be >= 20.8.1, otherwise use Option A or B
```

You do **not** install semantic-release itself — `npx --yes` fetches it on
demand (matching the CI workflows).

## 2. Preview the next version — no token needed

This mirrors the CI dry-run but loads only the analysis plugins, so it needs no
GitHub token. Run it on a release branch (`main`/`master`):

```bash
npx --yes \
  -p semantic-release@24 \
  -p @semantic-release/commit-analyzer \
  -p @semantic-release/release-notes-generator \
  semantic-release --dry-run --no-ci \
  --branches "$(git branch --show-current)" \
  --plugins @semantic-release/commit-analyzer @semantic-release/release-notes-generator
```

Example output when there is nothing new to release:

```
ℹ  Found git tag v1.0.0 associated with version 1.0.0 on branch main
ℹ  Found 0 commits since last release
ℹ  There are no relevant changes, so no new version is released.
```

Add a conventional commit and re-run to see a bump:

```bash
git commit --allow-empty -m "feat: demo change"
# re-run the command above -> "The next release version is 1.1.0"
```

- `--dry-run` — analyse only; never tags, pushes, or publishes.
- `--no-ci`  — allow running outside a CI environment.
- `--plugins …` — overrides `.releaserc.json` so the GitHub plugin (which needs
  a token) is skipped for a pure version preview.

## 3. Full dry-run against the real config — token required

The project's `.releaserc.json` includes `@semantic-release/github`, whose
`verifyConditions` step authenticates with GitHub. Without a token this fails:

```
✘  ENOGHTOKEN No GitHub token specified.
```

To run the complete configuration (still dry-run, publishes nothing), export a
GitHub Personal Access Token with `repo` scope first:

```bash
export GITHUB_TOKEN=ghp_your_pat_here      # or GH_TOKEN
npx --yes \
  -p semantic-release@24 \
  -p @semantic-release/commit-analyzer \
  -p @semantic-release/release-notes-generator \
  -p @semantic-release/github \
  semantic-release --dry-run --no-ci
```

## ⚠️ Do not run a real release locally

Dropping `--dry-run` makes semantic-release create the Git tag, push it, and cut
a GitHub Release. Leave real releases to the `release.yml` workflow (triggered by
pushes to `main`/`master`); only ever use `--dry-run` on your machine.
