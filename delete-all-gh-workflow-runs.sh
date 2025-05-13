#!/bin/bash
# delete-all-gh-workflow-runs.sh
# Deletes all GitHub Actions workflow runs for a given repository using the GitHub CLI
# Requires: gh CLI installed and authenticated, and GITHUB_TOKEN in the specified .env file

set -e

export PAGER=cat

# Usage: delete-all-gh-workflow-runs.sh [path/to/.env]
ENV_FILE=".env"
if [ ! -z "$1" ]; then
  ENV_FILE="$1"
fi

# Load GITHUB_TOKEN from .env file
if [ -f "$ENV_FILE" ]; then
  export $(grep -v '^#' "$ENV_FILE" | grep GITHUB_TOKEN | xargs)
else
  echo "$ENV_FILE not found!"
  exit 1
fi

if [ -z "$GITHUB_TOKEN" ]; then
  echo "GITHUB_TOKEN not found in $ENV_FILE!"
  exit 1
fi
# Infer GH_REPO_OWNER and GH_REPO_NAME from git config unless set in environment
if [ -z "$GH_REPO_OWNER" ] || [ -z "$GH_REPO_NAME" ]; then
  GIT_URL=$(git config --get remote.origin.url)
  GIT_URL=${GIT_URL%.git}
  if [[ "$GIT_URL" =~ github.com[:/](.+)/(.+) ]]; then
    GH_REPO_OWNER="${BASH_REMATCH[1]}"
    GH_REPO_NAME="${BASH_REMATCH[2]}"
  else
    echo "Could not infer GH_REPO_OWNER and GH_REPO_NAME from git config!"
    exit 1
  fi
fi

export GH_TOKEN="$GITHUB_TOKEN"

echo "Deleting all workflow runs for $GH_REPO_OWNER/$GH_REPO_NAME..."

# List all workflow IDs
gh api repos/$GH_REPO_OWNER/$GH_REPO_NAME/actions/workflows --paginate --jq '.workflows[].id' | while read wid; do
  # List all run IDs for this workflow
  gh api repos/$GH_REPO_OWNER/$GH_REPO_NAME/actions/workflows/$wid/runs --paginate --jq '.workflow_runs[].id' | while read runid; do
    echo "Deleting run $runid for workflow $wid"
    gh api -X DELETE repos/$GH_REPO_OWNER/$GH_REPO_NAME/actions/runs/$runid || true
  done
done

echo "All workflow runs deleted."
