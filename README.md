# GitHub Utils

Reusable scripts for managing GitHub Actions workflow runs and repository history.

## Prerequisites
- [GitHub CLI (`gh`)](https://cli.github.com/) installed and authenticated
- Bash shell
- A GitHub personal access token with `repo` and `workflow` permissions
- `.env` file with at least `GITHUB_TOKEN` set (see `.env.example`)

## Scripts

### 1. Delete All GitHub Actions Workflow Runs
Deletes all workflow runs for the current repository.

**Usage:**
```sh
./delete-all-gh-workflow-runs.sh [path/to/.env]
```
- `GITHUB_TOKEN` must be set in the provided `.env` file.
- The script will automatically infer the repository owner and name from your current git remote. You can override by exporting `GH_REPO_OWNER` and `GH_REPO_NAME` in your shell.

### 2. Squash Git History
Squashes all commits on a branch into a single commit and force-pushes to the remote.

**Usage:**
```sh
./squash-history.sh [path/to/.env]
```
- `GH_REPO_REMOTE` and `GH_REPO_BRANCH` are inferred automatically (remote defaults to `origin` if present, otherwise first remote; branch defaults to the currently checked out branch).
- You can override these by exporting them or setting them in your `.env` file.

## Environment Variables
See `.env.example` for all available variables and override options.

## Safety Notice
- These scripts perform destructive actions (deleting workflow runs, force-pushing branches). Use with care!
- Always ensure you are operating on the intended repository and branch.

---

MIT License
