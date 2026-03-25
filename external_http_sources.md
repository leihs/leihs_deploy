# External HTTP/HTTPS Sources

Hostnames contacted during a leihs deploy (apt repos, package managers, build tools).

## APT package repositories (on target server)

| Host | Purpose |
|------|---------|
| `https://apt.postgresql.org` | PostgreSQL (pgdg) apt repo |
| `https://mise.jdx.dev` | mise apt repo + GPG key (when system Ruby doesn't match required version) |
| `https://packages.adoptium.net` | Temurin/OpenJDK 21 apt repo (fallback when `openjdk-21-jdk` not in distro) |

Standard Debian/Ubuntu mirrors (`deb.debian.org`, `security.debian.org`) are also used for base packages but are typically configured locally.

## Ruby gems (on target server)

| Host | Purpose |
|------|---------|
| `https://rubygems.org` | Primary gem source (database, legacy, container-test) |
| `https://rails-assets.org` | Gem source for legacy Rails app |
| `https://github.com` | Git-sourced gem: `leihs/axlsx` in legacy Gemfile |
| `https://cache.ruby-lang.org` | Ruby binary downloads via mise/ruby-build |

## Clojure / JVM build (local, before deployment)

| Host | Purpose |
|------|---------|
| `https://repo1.maven.org` | Maven Central — default artifact repo for Clojure deps |
| `https://repo.clojars.org` | Clojars — default secondary repo for `clj` |
| `https://github.com` | Git dep: `DrTom/accountant` in admin `deps.edn` |

## npm (local, before deployment)

| Host | Purpose |
|------|---------|
| `https://registry.npmjs.org` | Default npm registry (no override configured) |

## Python / Ansible setup (local, before deployment)

| Host | Purpose |
|------|---------|
| `https://pypi.org` | pip install of ansible + deps (`ansible-requirements.txt`) |
| `https://galaxy.ansible.com` | Ansible Galaxy (for collection installs) |
