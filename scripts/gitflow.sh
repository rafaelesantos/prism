#!/usr/bin/env bash
#
# GitFlow helper — create branches following the project convention.
#
# Usage:
#   ./scripts/gitflow.sh feature <name>     — create feature/<name> from develop
#   ./scripts/gitflow.sh release <version>  — create release/<version> from develop
#   ./scripts/gitflow.sh hotfix <version>   — create hotfix/<version> from main
#   ./scripts/gitflow.sh finish-release     — merge current release/* to main and develop
#   ./scripts/gitflow.sh finish-hotfix      — merge current hotfix/* to main and develop

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

command="${1:-}"
name="${2:-}"

ensure_clean() {
    if ! git diff --quiet || ! git diff --cached --quiet; then
        echo "Error: working tree is dirty. Commit or stash changes first."
        exit 1
    fi
}

case "$command" in
    feature)
        [ -z "$name" ] && echo "Usage: $0 feature <name>" && exit 1
        ensure_clean
        git fetch origin
        git checkout develop 2>/dev/null || git checkout -b develop origin/develop 2>/dev/null || {
            echo "Creating develop from main..."
            git checkout main
            git checkout -b develop
            git push -u origin develop
        }
        git pull origin develop --ff-only 2>/dev/null || true
        git checkout -b "feature/$name"
        echo "Created feature/$name from develop"
        ;;

    release)
        [ -z "$name" ] && echo "Usage: $0 release <version>" && exit 1
        ensure_clean
        git fetch origin
        git checkout develop
        git pull origin develop --ff-only
        git checkout -b "release/$name"
        echo "Created release/$name from develop"
        echo "When ready, open a PR from release/$name → main"
        ;;

    hotfix)
        [ -z "$name" ] && echo "Usage: $0 hotfix <version>" && exit 1
        ensure_clean
        git fetch origin
        git checkout main
        git pull origin main --ff-only
        git checkout -b "hotfix/$name"
        echo "Created hotfix/$name from main"
        echo "When ready, open a PR from hotfix/$name → main"
        ;;

    finish-release)
        ensure_clean
        branch=$(git branch --show-current)
        if [[ ! "$branch" =~ ^release/ ]]; then
            echo "Error: not on a release/* branch (current: $branch)"
            exit 1
        fi
        version="${branch#release/}"

        echo "Merging $branch → main..."
        git checkout main
        git pull origin main --ff-only
        git merge --no-ff "$branch" -m "chore(release): merge $branch into main"

        echo "Tagging v$version..."
        git tag "$version" -m "Release v$version"

        echo "Merging $branch → develop..."
        git checkout develop
        git pull origin develop --ff-only
        git merge --no-ff "$branch" -m "chore(release): merge $branch into develop"

        echo "Cleaning up..."
        git branch -d "$branch"

        echo ""
        echo "Done. Push with:"
        echo "  git push origin main develop $version"
        echo "  git push origin --delete $branch"
        ;;

    finish-hotfix)
        ensure_clean
        branch=$(git branch --show-current)
        if [[ ! "$branch" =~ ^hotfix/ ]]; then
            echo "Error: not on a hotfix/* branch (current: $branch)"
            exit 1
        fi
        version="${branch#hotfix/}"

        echo "Merging $branch → main..."
        git checkout main
        git pull origin main --ff-only
        git merge --no-ff "$branch" -m "fix(hotfix): merge $branch into main"

        echo "Tagging v$version..."
        git tag "$version" -m "Hotfix v$version"

        echo "Merging $branch → develop..."
        git checkout develop
        git pull origin develop --ff-only
        git merge --no-ff "$branch" -m "fix(hotfix): merge $branch into develop"

        echo "Cleaning up..."
        git branch -d "$branch"

        echo ""
        echo "Done. Push with:"
        echo "  git push origin main develop $version"
        echo "  git push origin --delete $branch"
        ;;

    *)
        echo "Prism GitFlow"
        echo ""
        echo "Usage:"
        echo "  $0 feature <name>       Create feature branch from develop"
        echo "  $0 release <version>    Create release branch from develop"
        echo "  $0 hotfix <version>     Create hotfix branch from main"
        echo "  $0 finish-release       Merge current release/* to main + develop"
        echo "  $0 finish-hotfix        Merge current hotfix/* to main + develop"
        echo ""
        echo "Branch model:"
        echo "  main      ← production (protected, auto-releases on merge)"
        echo "  develop   ← integration (receives feature merges)"
        echo "  feature/* ← new work (from develop)"
        echo "  release/* ← release prep (from develop → main)"
        echo "  hotfix/*  ← urgent fixes (from main → main + develop)"
        exit 1
        ;;
esac
