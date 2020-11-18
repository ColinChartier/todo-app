#!/usr/bin/env bash

set -eu -o pipefail

# This script is a utility to download another repository quickly.
# It's meant to be called in a RUN REPEATABLE directive, combined with && for the rest of the actions.
# docker-compose example usage:
# RUN REPEATABLE curl (script url) | bash -s github.com/org/repo /backend master && \
#                docker-compose build && \
#                ( cd /backend && docker-compose build; )
# EXPOSE WEBISTE localhost:3000 /
# EXPOSE WEBSITE localhost:8080 /api
#
# Note: LayerCI must be installed on the repository you're trying to clone for this to be able to clone.
# Note: The token expires after 30 minutes, so subsequent RUN git fetch will fail without updating the upstream.

if [ "$#" != 3 ]; then
  echo "Usage: download-backend.sh [github.com/org/repo.git] [dest] [checkout ref, e.g., master]"
  exit 1
fi
REPO="$1"
DEST="$2"
REF="$3"

CLONE_URL="https://$GIT_CLONE_USER@github.com/$REPO"

if [ -d "$DEST" ]; then
  cd "$DEST"
  git remote remove origin 2>/dev/null || true
else
  rm -rf "$DEST"
  mkdir -p "$DEST"
  cd "$DEST"
  git init
fi
git remote add origin "$CLONE_URL"
git fetch
git reset --hard "$REF"
git clean -f -d
echo "[download-backend.sh]: Successfully checked out ref $REF in $REPO"
echo "[download-backend.sh]: Destination: $DEST"
