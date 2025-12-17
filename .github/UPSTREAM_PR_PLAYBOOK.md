# Upstream PR Automation Playbook

This playbook describes how to automate PR creation from your fork to upstream sonic-net/* repositories.

## Overview

Since Devin's `git_create_pr` tool can only target repositories in its allowlist, this workflow provides an alternative approach using GitHub Actions with a Personal Access Token (PAT) to create PRs to upstream repositories.

## Setup Instructions

### Step 1: Create a Personal Access Token (PAT)

1. Go to GitHub Settings > Developer settings > Personal access tokens > Tokens (classic)
2. Click "Generate new token (classic)"
3. Give it a descriptive name (e.g., "Upstream PR Automation")
4. Select the `public_repo` scope (required for creating PRs on public repos)
5. Click "Generate token" and copy the token

### Step 2: Add the Token as a Repository Secret

1. Go to your fork's repository settings (e.g., `github.com/your-username/sonic-buildimage/settings`)
2. Navigate to Secrets and variables > Actions
3. Click "New repository secret"
4. Name: `UPSTREAM_PR_TOKEN`
5. Value: Paste your PAT
6. Click "Add secret"

### Step 3: Copy the Workflow File

Copy `.github/workflows/create-upstream-pr.yml` to your fork. The workflow is already configured for sonic-buildimage but can be customized for other repos.

## Usage

### Method 1: Automatic Trigger (Push)

Push to a branch matching one of these patterns:
- `devin/**` (e.g., `devin/1234-my-feature`)
- `feature/**` (e.g., `feature/new-capability`)
- `fix/**` (e.g., `fix/bug-123`)
- `upstream/**` (e.g., `upstream/my-contribution`)

The workflow will automatically create a PR to the upstream repo's `master` branch.

### Method 2: Manual Trigger (Workflow Dispatch)

1. Go to Actions > "Create Upstream PR"
2. Click "Run workflow"
3. Fill in the optional parameters:
   - **source_branch**: Branch in your fork (defaults to current branch)
   - **target_branch**: Target branch in upstream (defaults to `master`)
   - **upstream_repo**: Upstream repository (defaults to `sonic-net/sonic-buildimage`)
   - **pr_title**: Custom PR title (auto-generated from branch name if empty)
   - **pr_body**: Custom PR description
   - **draft**: Create as draft PR

## Adapting for Other sonic-net/* Repositories

### Quick Setup for a New Fork

1. Fork the upstream repository (e.g., `sonic-net/sonic-mgmt`)
2. Copy the workflow file to `.github/workflows/create-upstream-pr.yml`
3. Update the default `upstream_repo` value in the workflow:

```yaml
upstream_repo:
  description: 'Upstream repository'
  required: false
  default: 'sonic-net/sonic-mgmt'  # Change this
  type: string
```

4. Update the repository check in the `if` condition:

```yaml
if: github.repository != 'sonic-net/sonic-mgmt'  # Change this
```

5. Add the `UPSTREAM_PR_TOKEN` secret to the new fork

### Common sonic-net Repositories

| Repository | Default upstream_repo value |
|------------|----------------------------|
| sonic-buildimage | `sonic-net/sonic-buildimage` |
| sonic-mgmt | `sonic-net/sonic-mgmt` |
| sonic-swss | `sonic-net/sonic-swss` |
| sonic-sairedis | `sonic-net/sonic-sairedis` |
| sonic-utilities | `sonic-net/sonic-utilities` |
| sonic-platform-common | `sonic-net/sonic-platform-common` |
| sonic-gnmi | `sonic-net/sonic-gnmi` |
| sonic-frr | `sonic-net/sonic-frr` |

### Template for Other Repos

Here's a minimal template you can copy and customize:

```yaml
name: Create Upstream PR

on:
  workflow_dispatch:
    inputs:
      source_branch:
        description: 'Source branch in your fork'
        required: false
        type: string
      target_branch:
        description: 'Target branch in upstream repo'
        required: false
        default: 'master'
        type: string
      pr_title:
        description: 'PR title'
        required: false
        type: string
  push:
    branches:
      - 'devin/**'
      - 'feature/**'

jobs:
  create-upstream-pr:
    runs-on: ubuntu-latest
    if: github.repository != 'sonic-net/YOUR-REPO-NAME'
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
          
      - name: Create PR
        env:
          GH_TOKEN: ${{ secrets.UPSTREAM_PR_TOKEN }}
        run: |
          SOURCE_BRANCH="${GITHUB_REF#refs/heads/}"
          TARGET_BRANCH="${{ inputs.target_branch || 'master' }}"
          UPSTREAM_REPO="sonic-net/YOUR-REPO-NAME"
          FORK_OWNER="${{ github.repository_owner }}"
          PR_TITLE="${{ inputs.pr_title }}"
          
          if [[ -z "${PR_TITLE}" ]]; then
            PR_TITLE=$(echo "${SOURCE_BRANCH}" | sed 's|.*/||' | sed 's/^[0-9]*-//' | sed 's/-/ /g')
          fi
          
          # Check if PR already exists
          EXISTING=$(gh pr list --repo "${UPSTREAM_REPO}" --head "${FORK_OWNER}:${SOURCE_BRANCH}" --json url --jq '.[0].url' 2>/dev/null || echo "")
          
          if [[ -n "${EXISTING}" ]]; then
            echo "PR already exists: ${EXISTING}"
          else
            gh pr create \
              --repo "${UPSTREAM_REPO}" \
              --head "${FORK_OWNER}:${SOURCE_BRANCH}" \
              --base "${TARGET_BRANCH}" \
              --title "${PR_TITLE}" \
              --body "PR from fork"
          fi
```

## Troubleshooting

### "Resource not accessible by integration"

This error means the `GITHUB_TOKEN` doesn't have permission to create PRs on the upstream repo. Make sure you've added the `UPSTREAM_PR_TOKEN` secret with a PAT that has `public_repo` scope.

### "A]ready exists"

The workflow checks for existing PRs before creating new ones. If a PR already exists from your fork branch, it will skip creation and report the existing PR URL.

### "Not found" or 404 errors

- Verify the upstream repository name is correct
- Ensure your PAT hasn't expired
- Check that the source branch exists and has been pushed to your fork

### Branch not triggering automatic workflow

Make sure your branch name matches one of the configured patterns:
- `devin/**`
- `feature/**`
- `fix/**`
- `upstream/**`

Or add your own pattern to the workflow's `push.branches` list.

## Alternative: Using gh CLI Directly

If you prefer not to use GitHub Actions, you can create PRs manually using the `gh` CLI:

```bash
# Authenticate with your PAT
echo "YOUR_PAT" | gh auth login --with-token

# Create PR from your fork to upstream
gh pr create \
  --repo sonic-net/sonic-buildimage \
  --head your-username:your-branch \
  --base master \
  --title "Your PR Title" \
  --body "Your PR description"
```

## Security Considerations

- The `UPSTREAM_PR_TOKEN` secret is only accessible to workflows in your fork
- Use a PAT with minimal required scopes (`public_repo` only)
- Consider setting an expiration date on your PAT
- Regularly rotate your PAT for security

## Support

For issues with this workflow, please open an issue in your fork or contact the maintainer.
