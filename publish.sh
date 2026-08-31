#!/bin/bash
# Build the site and publish it to both repos:
#   1. this repo (source + the generated docs/)
#   2. ../ChaoChunHsu.github.io, which is what GitHub Pages actually serves
#
# Usage: ./publish.sh "commit message"
set -euo pipefail

MSG="${1:-}"
if [ -z "$MSG" ]; then
  echo "usage: ./publish.sh \"commit message\"" >&2
  exit 1
fi

LIVE_REPO="../ChaoChunHsu.github.io"
if [ ! -d "$LIVE_REPO/.git" ]; then
  echo "error: $LIVE_REPO is not a git checkout" >&2
  exit 1
fi

# Build. No -D: drafts must not reach production.
hugo --cleanDestinationDir

# Mirror docs/ into the live repo. rsync --delete (not cp) so that pages
# removed from the site actually disappear instead of lingering as orphans.
rsync -a --delete --exclude '.git' --exclude 'CNAME' docs/ "$LIVE_REPO/"

git add -A
git commit -m "$MSG" || echo "nothing to commit in source repo"
git push

cd "$LIVE_REPO"
git add -A
git commit -m "$MSG" || echo "nothing to commit in live repo"
git push

echo
echo "published: https://chaochunhsu.github.io/"
