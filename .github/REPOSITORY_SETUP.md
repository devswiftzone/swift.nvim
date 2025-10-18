# Repository Setup Guide

This guide explains how to configure your GitHub repository for professional open source development with branch protection, automated workflows, and project management.

## 📋 Table of Contents

1. [Branch Protection Rules](#1-branch-protection-rules)
2. [GitHub Projects Setup](#2-github-projects-setup)
3. [Required Secrets](#3-required-secrets)
4. [Labels Configuration](#4-labels-configuration)
5. [Additional Settings](#5-additional-settings)

---

## 1. Branch Protection Rules

### Configure Main Branch Protection

1. Go to your repository on GitHub
2. Navigate to **Settings** → **Branches**
3. Click **Add branch protection rule**
4. Configure as follows:

#### Branch Name Pattern
```
main
```

#### Protection Rules

**✅ Require a pull request before merging**
- ✅ Require approvals: **1**
- ✅ Dismiss stale pull request approvals when new commits are pushed
- ✅ Require review from Code Owners
- ⬜ Restrict who can dismiss pull request reviews (optional)
- ✅ Allow specified actors to bypass required pull requests (you can add yourself here)

**✅ Require status checks to pass before merging**
- ✅ Require branches to be up to date before merging
- Select required status checks:
  - `Lint`
  - `Documentation Check`
  - `Test (ubuntu-latest, stable)`
  - `Test (macos-latest, stable)`

**✅ Require conversation resolution before merging**

**✅ Require signed commits** (optional, but recommended)

**✅ Require linear history** (optional, prevents merge commits)

**✅ Include administrators** (apply rules to admins too)

**⬜ Allow force pushes** (keep disabled for safety)

**⬜ Allow deletions** (keep disabled for safety)

#### Lock branch
**⬜ Lock branch** (keep disabled to allow PRs)

5. Click **Create** or **Save changes**

### Visual Guide

```
Settings → Branches → Add branch protection rule

Branch name pattern: main

[✓] Require a pull request before merging
    Required approvals: 1
    [✓] Dismiss stale pull request approvals
    [✓] Require review from Code Owners

[✓] Require status checks to pass before merging
    [✓] Require branches to be up to date
    Status checks:
      - Lint
      - Documentation Check
      - Test (ubuntu-latest, stable)
      - Test (macos-latest, stable)

[✓] Require conversation resolution before merging
[✓] Require signed commits
[✓] Include administrators
[✗] Allow force pushes
[✗] Allow deletions
```

---

## 2. GitHub Projects Setup

### Create a New Project

1. Go to **Projects** tab in your repository
2. Click **New project** or go to https://github.com/orgs/devswiftzone/projects
3. Choose **Board** template
4. Name it: **swift.nvim Development**

### Configure Project Columns

Create the following columns:

1. **📋 Backlog** - New issues and ideas
2. **🔍 Triage** - Issues being reviewed
3. **📝 To Do** - Ready to work on
4. **🚧 In Progress** - Currently being worked on
5. **👀 In Review** - Pull requests under review
6. **✅ Done** - Completed items

### Automation Settings

For each column, configure automation:

#### 📋 Backlog
- Preset: **To do**
- Automation: Items are added here when created

#### 🔍 Triage
- No automation (manual)

#### 📝 To Do
- No automation (manual)

#### 🚧 In Progress
- Automation: Move here when PR is opened or issue assigned

#### 👀 In Review
- Automation: Move here when PR is ready for review

#### ✅ Done
- Automation: Move here when PR is merged or issue is closed

### Link Repository to Project

1. In your project, click **Settings** (⚙️)
2. Under **Manage access**, add your repository
3. Enable **Auto-add items** for:
   - ✅ Issues
   - ✅ Pull requests

### Configure Workflow

The `.github/workflows/issue-to-project.yml` file automatically adds new issues and PRs to your project.

**Important**: You need to create a `PROJECT_TOKEN`:

1. Go to **Settings** → **Developer settings** → **Personal access tokens** → **Fine-grained tokens**
2. Generate new token with:
   - Repository access: `devswiftzone/swift.nvim`
   - Permissions:
     - **Projects**: Read and Write
     - **Issues**: Read
     - **Pull Requests**: Read
3. Copy the token
4. Go to repository **Settings** → **Secrets and variables** → **Actions**
5. Click **New repository secret**
6. Name: `PROJECT_TOKEN`
7. Value: (paste your token)
8. Click **Add secret**

---

## 3. Required Secrets

### Create GitHub Secrets

Go to **Settings** → **Secrets and variables** → **Actions** → **New repository secret**

#### Required Secrets:

1. **`PROJECT_TOKEN`**
   - Description: Personal access token for GitHub Projects automation
   - Scope: Read/Write Projects, Read Issues/PRs
   - How to create: See [GitHub Projects Setup](#2-github-projects-setup) above

#### Optional Secrets (for future use):

2. **`CODECOV_TOKEN`** (if you add code coverage)
   - Get from: https://codecov.io

3. **`SLACK_WEBHOOK`** (for notifications)
   - Get from your Slack workspace

---

## 4. Labels Configuration

### Create Standard Labels

Go to **Issues** → **Labels** → **New label**

Create the following labels:

#### Type Labels
| Label | Color | Description |
|-------|-------|-------------|
| `bug` | `#d73a4a` | Something isn't working |
| `enhancement` | `#a2eeef` | New feature or request |
| `documentation` | `#0075ca` | Improvements or additions to documentation |
| `question` | `#d876e3` | Further information is requested |
| `good first issue` | `#7057ff` | Good for newcomers |
| `help wanted` | `#008672` | Extra attention is needed |

#### Priority Labels
| Label | Color | Description |
|-------|-------|-------------|
| `priority: critical` | `#b60205` | Critical priority |
| `priority: high` | `#d93f0b` | High priority |
| `priority: medium` | `#fbca04` | Medium priority |
| `priority: low` | `#0e8a16` | Low priority |

#### Status Labels
| Label | Color | Description |
|-------|-------|-------------|
| `status: blocked` | `#000000` | Blocked by another issue |
| `status: in progress` | `#ededed` | Currently being worked on |
| `status: needs review` | `#fbca04` | Needs code review |
| `status: awaiting response` | `#fef2c0` | Waiting for response |

#### Feature Labels
| Label | Color | Description |
|-------|-------|-------------|
| `feature: lsp` | `#1d76db` | LSP integration |
| `feature: debugger` | `#e99695` | Debugger functionality |
| `feature: formatter` | `#c5def5` | Code formatting |
| `feature: linter` | `#bfdadc` | Linting functionality |
| `feature: build` | `#d4c5f9` | Build system |
| `feature: xcode` | `#5319e7` | Xcode integration |

#### Special Labels
| Label | Color | Description |
|-------|-------|-------------|
| `breaking change` | `#d73a4a` | Breaking API changes |
| `dependencies` | `#0366d6` | Pull requests that update a dependency |
| `duplicate` | `#cfd3d7` | This issue or pull request already exists |
| `invalid` | `#e4e669` | This doesn't seem right |
| `wontfix` | `#ffffff` | This will not be worked on |
| `code-of-conduct` | `#d73a4a` | Code of Conduct violation |

### Bulk Create Labels Script

You can use this script to create all labels at once:

```bash
#!/bin/bash

# Save as create-labels.sh and run: bash create-labels.sh devswiftzone swift.nvim

REPO_OWNER=$1
REPO_NAME=$2
GITHUB_TOKEN=$3  # Your personal access token

labels=(
  "bug|d73a4a|Something isn't working"
  "enhancement|a2eeef|New feature or request"
  "documentation|0075ca|Improvements or additions to documentation"
  "question|d876e3|Further information is requested"
  "good first issue|7057ff|Good for newcomers"
  "help wanted|008672|Extra attention is needed"
  "priority: critical|b60205|Critical priority"
  "priority: high|d93f0b|High priority"
  "priority: medium|fbca04|Medium priority"
  "priority: low|0e8a16|Low priority"
  "breaking change|d73a4a|Breaking API changes"
  "dependencies|0366d6|Pull requests that update a dependency"
)

for label in "${labels[@]}"; do
  IFS='|' read -r name color description <<< "$label"
  gh label create "$name" --color "$color" --description "$description" --repo "$REPO_OWNER/$REPO_NAME" || true
done
```

---

## 5. Additional Settings

### General Repository Settings

Go to **Settings** → **General**

#### Features

- ✅ **Issues** - Enable issue tracking
- ✅ **Projects** - Enable GitHub Projects
- ✅ **Discussions** - Enable discussions (optional, for community questions)
- ✅ **Wiki** - Disable (we use markdown docs)
- ⬜ **Sponsorships** - Enable if you want GitHub Sponsors

#### Pull Requests

- ✅ **Allow merge commits**
- ✅ **Allow squash merging** (recommended)
- ⬜ **Allow rebase merging**
- ✅ **Always suggest updating pull request branches**
- ✅ **Automatically delete head branches**

#### Archives

- ⬜ **Include Git LFS objects in archives**

### Collaborators & Teams

Go to **Settings** → **Collaborators and teams**

1. Add maintainers with **Maintain** or **Admin** role
2. Add contributors with **Write** role
3. Keep **Triage** role for community moderators

### Notifications

Go to **Settings** → **Notifications**

- ✅ **Email notifications** for all activity
- ✅ **Web notifications** for all activity

---

## 🚀 Quick Setup Checklist

Use this checklist to set up your repository:

- [ ] Push the community standards files (`git push`)
- [ ] Create `PROJECT_TOKEN` secret
- [ ] Configure branch protection for `main`
- [ ] Create GitHub Project board
- [ ] Link repository to project
- [ ] Create all required labels
- [ ] Configure repository settings (Features, Pull Requests)
- [ ] Add collaborators if needed
- [ ] Test by creating a test PR
- [ ] Verify CI workflows run successfully
- [ ] Verify issues are added to project automatically
- [ ] Update README with project link

---

## 📚 Additional Resources

- [GitHub Branch Protection](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches)
- [GitHub Projects](https://docs.github.com/en/issues/planning-and-tracking-with-projects)
- [GitHub Actions](https://docs.github.com/en/actions)
- [CODEOWNERS](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-code-owners)

---

## ❓ Troubleshooting

### Branch protection not working?
- Make sure you've pushed your commits
- Check that status checks are defined in CI workflow
- Verify you're not included in bypass list

### Issues not adding to project?
- Check `PROJECT_TOKEN` is valid
- Verify workflow has correct project URL
- Check workflow logs in Actions tab

### CI failing?
- Check workflow syntax in `.github/workflows/`
- Verify all required files exist
- Check Actions logs for detailed errors

---

**Need help?** Open an issue or contact: info@swiftzone.dev
