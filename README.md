# hello-world

A minimal **Gradle** "Hello, World!" application, containerised with Docker and
released with **semantic versioning driven by conventional-commit messages**.

The resolved version flows end-to-end:

```
conventional commits ──► semantic-release ──► vX.Y.Z tag / GitHub Release
                                                   │
                          gradle -PappVersion=X.Y.Z │ (build arg)
                                                   ▼
                     jar manifest (Implementation-Version)
                                                   ▼
                    App prints "Hello, World! (version X.Y.Z)"
```

## Project layout

```
.
├── build.gradle                 # version = -PappVersion (default 0.0.0-dev)
├── settings.gradle              # foojay toolchain resolver (auto JDK 17)
├── gradle.properties            # appVersion default
├── gradlew / gradle/wrapper/    # Gradle 8.10.2 wrapper
├── src/main/java/.../App.java    # prints greeting incl. version
├── src/test/java/.../AppTest.java
├── Dockerfile                   # multi-stage build -> temurin JRE runtime
├── .releaserc.json              # semantic-release config (conventional commits)
└── .github/workflows/
    ├── release.yml              # Semantic Versioning (push to main/master)
    └── ci.yml                   # build + Docker push (PR test / release)
```

## Build & run locally

```bash
# default dev version
./gradlew run

# pass a version, exactly like CI does
./gradlew build -PappVersion=1.4.2
java -jar build/libs/hello-world-1.4.2.jar
# -> Hello, World! (version 1.4.2)
```

## Build & run with Docker

The `VERSION` build arg is passed to Gradle as `-PappVersion`:

```bash
docker build --build-arg VERSION=2.3.0 -t hello-world:2.3.0 .
docker run --rm hello-world:2.3.0
# -> Hello, World! (version 2.3.0)
```

## Versioning — conventional commits

Versions are computed from commit messages since the last tag:

| Commit prefix                    | Release |
|----------------------------------|---------|
| `fix: ...`                       | patch (x.y.**Z**) |
| `feat: ...`                      | minor (x.**Y**.0) |
| `feat!: ...` / `BREAKING CHANGE:`| major (**X**.0.0) |
| `chore:`, `docs:`, `refactor:` … | no release |

Example:

```bash
git commit -m "feat: add greeting message"      # -> 1.0.0
git commit -m "fix: correct version formatting"  # -> 1.0.1
```

Preview the next version locally (dry-run, publishes nothing) — see
[docs/local-usage.md](docs/local-usage.md) for Linux Mint install steps and the
full command:

```bash
npx --yes -p semantic-release@24 \
  -p @semantic-release/commit-analyzer -p @semantic-release/release-notes-generator \
  semantic-release --dry-run --no-ci \
  --branches "$(git branch --show-current)" \
  --plugins @semantic-release/commit-analyzer @semantic-release/release-notes-generator
```

## GitHub workflows

### `release.yml` — Semantic Versioning
Runs on push to `main`/`master`. `semantic-release` analyses the commits and, if
warranted, creates the next `vX.Y.Z` **tag** and a published **GitHub Release**.

### `ci.yml` — CI
| Job              | Trigger                | Does |
|------------------|------------------------|------|
| `build`          | every push & PR        | `./gradlew build` (compile + test) |
| `docker-pr`      | pull request           | builds & **pushes a test image** tagged `<next-version>-pr.<n>.<sha>` and `pr-<n>` (version from a semantic-release dry-run) |
| `docker-release` | Release published      | builds & **pushes the release image** tagged `<release-version>` and `latest` |

### Required repository secrets

| Secret              | Purpose |
|---------------------|---------|
| `REGISTRY`          | Private registry host, e.g. `registry.example.com` |
| `REGISTRY_USERNAME` | Registry login user |
| `REGISTRY_PASSWORD` | Registry login password/token |
| `IMAGE_NAME`        | *(optional)* image path; defaults to `<owner>/<repo>` |
| `RELEASE_TOKEN`     | *(optional)* PAT (repo scope) — see note below |

> **Cross-workflow trigger note:** A Release created with the default
> `GITHUB_TOKEN` does **not** trigger other workflows (GitHub blocks recursive
> triggering), so `docker-release` won't auto-run. Provide a PAT as
> `RELEASE_TOKEN` to have the Release fire CI automatically.
