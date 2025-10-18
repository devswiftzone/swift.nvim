#!/bin/bash
# Script to create GitHub labels for swift.nvim repository
# Usage: ./create-labels.sh [owner] [repo]
# Example: ./create-labels.sh devswiftzone swift.nvim
#
# Requires: GitHub CLI (gh) to be installed and authenticated
# Install: https://cli.github.com/

set -e

REPO_OWNER="${1:-devswiftzone}"
REPO_NAME="${2:-swift.nvim}"
REPO="$REPO_OWNER/$REPO_NAME"

echo "Creating labels for repository: $REPO"
echo "----------------------------------------"

# Check if gh is installed
if ! command -v gh &> /dev/null; then
    echo "Error: GitHub CLI (gh) is not installed."
    echo "Install it from: https://cli.github.com/"
    exit 1
fi

# Check if authenticated
if ! gh auth status &> /dev/null; then
    echo "Error: Not authenticated with GitHub CLI."
    echo "Run: gh auth login"
    exit 1
fi

# Function to create label
create_label() {
    local name=$1
    local color=$2
    local description=$3

    if gh label create "$name" \
        --color "$color" \
        --description "$description" \
        --repo "$REPO" 2>/dev/null; then
        echo "✓ Created: $name"
    else
        echo "⊘ Skipped: $name (already exists)"
    fi
}

echo ""
echo "Creating Type Labels..."
echo "----------------------------------------"
create_label "bug" "d73a4a" "Something isn't working"
create_label "enhancement" "a2eeef" "New feature or request"
create_label "documentation" "0075ca" "Improvements or additions to documentation"
create_label "question" "d876e3" "Further information is requested"
create_label "good first issue" "7057ff" "Good for newcomers"
create_label "help wanted" "008672" "Extra attention is needed"

echo ""
echo "Creating Priority Labels..."
echo "----------------------------------------"
create_label "priority: critical" "b60205" "Critical priority"
create_label "priority: high" "d93f0b" "High priority"
create_label "priority: medium" "fbca04" "Medium priority"
create_label "priority: low" "0e8a16" "Low priority"

echo ""
echo "Creating Status Labels..."
echo "----------------------------------------"
create_label "status: blocked" "000000" "Blocked by another issue"
create_label "status: in progress" "ededed" "Currently being worked on"
create_label "status: needs review" "fbca04" "Needs code review"
create_label "status: awaiting response" "fef2c0" "Waiting for response"

echo ""
echo "Creating Feature Labels..."
echo "----------------------------------------"
create_label "feature: lsp" "1d76db" "LSP integration"
create_label "feature: debugger" "e99695" "Debugger functionality"
create_label "feature: formatter" "c5def5" "Code formatting"
create_label "feature: linter" "bfdadc" "Linting functionality"
create_label "feature: build" "d4c5f9" "Build system"
create_label "feature: xcode" "5319e7" "Xcode integration"
create_label "feature: targets" "bfd4f2" "Target management"

echo ""
echo "Creating Special Labels..."
echo "----------------------------------------"
create_label "breaking change" "d73a4a" "Breaking API changes"
create_label "dependencies" "0366d6" "Pull requests that update a dependency"
create_label "duplicate" "cfd3d7" "This issue or pull request already exists"
create_label "invalid" "e4e669" "This doesn't seem right"
create_label "wontfix" "ffffff" "This will not be worked on"
create_label "code-of-conduct" "d73a4a" "Code of Conduct violation"
create_label "ci" "34d058" "Continuous Integration"
create_label "core" "0e8a16" "Core plugin functionality"
create_label "tests" "fef2c0" "Testing related changes"

echo ""
echo "----------------------------------------"
echo "✓ Label creation complete!"
echo ""
echo "View all labels at:"
echo "https://github.com/$REPO/labels"
