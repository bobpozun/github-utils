#!/bin/bash
# squash-history.sh
# WARNING: This script will delete all git history and force-push a single commit to your remote!
# Use with caution. Make sure you have backups if needed.

set -e

# Usage: squash-history.sh [path/to/.env]
ENV_FILE=".env"
if [ ! -z "$1" ]; then
  ENV_FILE="$1"
fi

# Load overrides from .env file
if [ -f "$ENV_FILE" ]; then
  export $(grep -v '^#' "$ENV_FILE" | grep GH_REPO_REMOTE | xargs || true)
  export $(grep -v '^#' "$ENV_FILE" | grep GH_REPO_BRANCH | xargs || true)
else
  echo "$ENV_FILE not found!"
  exit 1
fi

# Infer remote (default: origin, else first remote) if not set
if [ -z "$GH_REPO_REMOTE" ]; then
  if git remote | grep -q '^origin$'; then
    GH_REPO_REMOTE="origin"
  else
    GH_REPO_REMOTE=$(git remote | head -n1)
  fi
fi
# Infer branch from current checked out branch if not set
if [ -z "$GH_REPO_BRANCH" ]; then
  GH_REPO_BRANCH=$(git rev-parse --abbrev-ref HEAD)
fi

branch_name="squashed-$GH_REPO_BRANCH"
echo "Creating orphan branch: $branch_name"
git checkout --orphan "$branch_name"

rm -rf .git/index
# Remove all staged files (if any)
git add -A
git commit -m "Initial commit (history squashed)"

echo "Deleting all other local branches except $branch_name"
for b in $(git branch | grep -v "$branch_name"); do
    git branch -D "$b"
done

echo "Force pushing to $GH_REPO_REMOTE $GH_REPO_BRANCH (overwriting all history)"
git push --force "$GH_REPO_REMOTE" "$branch_name:$GH_REPO_BRANCH"

echo "History squashed. Only one commit remains on $GH_REPO_BRANCH."
