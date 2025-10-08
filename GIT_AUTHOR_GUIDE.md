# 🔧 Git Author Configuration Guide

A comprehensive guide to managing Git commit authors and fixing attribution issues.

## 📋 Table of Contents

- [Understanding Git Author Information](#understanding-git-author-information)
- [Quick Setup](#quick-setup)
- [Fixing Author Information](#fixing-author-information)
- [Common Scenarios](#common-scenarios)
- [Troubleshooting](#troubleshooting)
- [Best Practices](#best-practices)

## 🎯 Understanding Git Author Information

Every Git commit contains two pieces of author information:

1. **Author Name**: Your display name (e.g., "shivam2003-dev")
2. **Author Email**: Your email address (e.g., "user@example.com")

GitHub uses the **email address** to link commits to your GitHub account. If the email doesn't match any GitHub account, it may show a different username or "GitHub User".

### How GitHub Links Commits

```
Git Commit Email → GitHub Account Email → GitHub Username
```

If the emails don't match, your commits may appear under a different name!

## 🚀 Quick Setup

### Check Current Configuration

```bash
# Check your current name
git config user.name

# Check your current email
git config user.email

# View all git config
git config --list
```

### Set Configuration (Local Repository)

```bash
# Set name for current repository only
git config user.name "your-github-username"

# Set email for current repository only
git config user.email "your-email@example.com"
```

### Set Configuration (Global - All Repositories)

```bash
# Set name globally
git config --global user.name "your-github-username"

# Set email globally
git config --global user.email "your-email@example.com"
```

### Using GitHub's No-Reply Email

GitHub provides a no-reply email to keep your personal email private:

```bash
git config user.email "your-username@users.noreply.github.com"
```

**Find your no-reply email**:
1. Go to GitHub.com
2. Settings → Emails
3. Look for "Keep my email addresses private"
4. Copy the email shown: `123456+username@users.noreply.github.com`

## 🔨 Fixing Author Information

### Fix the Most Recent Commit

If you just made a commit with wrong author info:

```bash
# Update git config first
git config user.name "correct-username"
git config user.email "correct-email@example.com"

# Amend the last commit with new author
git commit --amend --reset-author --no-edit

# Force push to update remote
git push origin main --force
```

### Fix a Specific Old Commit

To fix a specific commit in history (interactive rebase):

```bash
# Start interactive rebase from the commit BEFORE the one you want to fix
# Replace <commit-hash> with the parent commit hash
git rebase -i <commit-hash>^

# In the editor that opens, change 'pick' to 'edit' for the commit you want to fix
# Save and close the editor

# Now amend the commit
git commit --amend --reset-author --no-edit

# Continue the rebase
git rebase --continue

# Force push the changes
git push origin main --force
```

### Fix Multiple Commits

To fix all commits by a specific author:

```bash
# Replace OLD_EMAIL, CORRECT_NAME, and CORRECT_EMAIL
git filter-branch --env-filter '
OLD_EMAIL="old@example.com"
CORRECT_NAME="your-github-username"
CORRECT_EMAIL="correct@example.com"

if [ "$GIT_COMMITTER_EMAIL" = "$OLD_EMAIL" ]
then
    export GIT_COMMITTER_NAME="$CORRECT_NAME"
    export GIT_COMMITTER_EMAIL="$CORRECT_EMAIL"
fi
if [ "$GIT_AUTHOR_EMAIL" = "$OLD_EMAIL" ]
then
    export GIT_AUTHOR_NAME="$CORRECT_NAME"
    export GIT_AUTHOR_EMAIL="$CORRECT_EMAIL"
fi
' --tag-name-filter cat -- --branches --tags

# Force push all branches
git push origin --force --all
git push origin --force --tags
```

⚠️ **Warning**: `git filter-branch` rewrites history. Use with caution!

### Modern Alternative: git filter-repo

For more complex history rewriting, use `git filter-repo`:

```bash
# Install git-filter-repo
pip install git-filter-repo

# Create a mailmap file (mailmap.txt)
# Format: Correct Name <correct@email.com> <old@email.com>
echo "John Doe <john@users.noreply.github.com> <john@work.com>" > mailmap.txt

# Apply the mailmap
git filter-repo --mailmap mailmap.txt

# Force push
git push origin --force --all
```

## 📖 Common Scenarios

### Scenario 1: Wrong Email from Work Computer

**Problem**: Commits show "work-username" instead of personal GitHub account.

**Solution**:
```bash
# Check current email
git config user.email
# Output: you@company.com

# Fix it
git config user.email "your-github-username@users.noreply.github.com"

# Amend last commit
git commit --amend --reset-author --no-edit
git push origin main --force
```

### Scenario 2: Multiple Commits with Wrong Author

**Problem**: Last 5 commits have wrong author info.

**Solution**:
```bash
# Set correct config
git config user.name "correct-name"
git config user.email "correct@email.com"

# Interactive rebase for last 5 commits
git rebase -i HEAD~5

# In editor: change 'pick' to 'edit' for all commits
# Then for each commit:
git commit --amend --reset-author --no-edit
git rebase --continue

# Force push
git push origin main --force
```

### Scenario 3: First Commit with Wrong Author

**Problem**: The very first commit has wrong author.

**Solution**:
```bash
# Rebase from the beginning (using --root)
git rebase -i --root

# Change 'pick' to 'edit' for the first commit
# Then:
git commit --amend --reset-author --no-edit
git rebase --continue
git push origin main --force
```

### Scenario 4: Already Pushed to Shared Repository

**Problem**: Need to fix commits already pushed and others may have pulled.

**Important**: Coordinate with team members! Rewriting shared history can cause issues.

**Solution**:
```bash
# 1. Notify your team
# 2. Fix the commits locally (using methods above)
# 3. Force push
git push origin main --force

# 4. Team members need to reset their local branches:
# git fetch origin
# git reset --hard origin/main
```

## 🐛 Troubleshooting

### Problem: Commits Still Show Wrong Author on GitHub

**Possible Causes**:
1. Email doesn't match any GitHub account
2. Email privacy settings on GitHub
3. Cache delay on GitHub (can take a few minutes)

**Solutions**:

1. **Verify email matches GitHub**:
   - Go to GitHub Settings → Emails
   - Check which emails are verified
   - Use one of those emails

2. **Use GitHub's no-reply email**:
   ```bash
   git config user.email "username@users.noreply.github.com"
   ```

3. **Check if email is verified**:
   - Unverified emails won't link to your account
   - Add and verify email on GitHub first

### Problem: "fatal: bad revision 'HEAD~5'"

**Cause**: Not enough commits in history.

**Solution**: Reduce the number:
```bash
# Check number of commits
git log --oneline | wc -l

# Use appropriate number
git rebase -i HEAD~2  # If you only have 3 commits
```

### Problem: Merge Conflicts During Rebase

**Solution**:
```bash
# Fix conflicts in files
# Then add resolved files
git add .

# Continue rebase
git rebase --continue

# Or abort if needed
git rebase --abort
```

### Problem: "refusing to update checked out branch"

**Cause**: Trying to push to a checked-out branch on remote.

**Solution**:
```bash
# Push to a different branch first, then merge
git push origin main:temp-branch
# Or use --force carefully
git push origin main --force
```

## ✨ Best Practices

### 1. Set Global Config Once

Set your global config to avoid issues:

```bash
git config --global user.name "your-github-username"
git config --global user.email "your-github-email@example.com"
```

### 2. Use Different Configs for Work and Personal

Create separate configs:

```bash
# Work projects
cd ~/work/project
git config user.email "you@company.com"

# Personal projects
cd ~/personal/project
git config user.email "you@users.noreply.github.com"
```

### 3. Use .gitconfig with Conditional Includes

Edit `~/.gitconfig`:

```ini
# Default (personal)
[user]
    name = your-github-username
    email = you@users.noreply.github.com

# Work-specific
[includeIf "gitdir:~/work/"]
    path = ~/.gitconfig-work
```

Then create `~/.gitconfig-work`:

```ini
[user]
    name = Your Name
    email = you@company.com
```

### 4. Verify Before Committing

Check your config before important commits:

```bash
# Quick check
git config user.name && git config user.email

# See what will be used for next commit
git var GIT_AUTHOR_IDENT
```

### 5. Use Pre-commit Hooks

Create `.git/hooks/pre-commit`:

```bash
#!/bin/bash

# Get configured email
EMAIL=$(git config user.email)

# Check if it's a work directory
if [[ $(pwd) == *"work"* ]] && [[ $EMAIL != *"company.com"* ]]; then
    echo "❌ Error: Using personal email in work repository!"
    echo "Current email: $EMAIL"
    echo "Run: git config user.email 'you@company.com'"
    exit 1
fi

# Check if it's a personal directory
if [[ $(pwd) == *"personal"* ]] && [[ $EMAIL == *"company.com"* ]]; then
    echo "❌ Error: Using work email in personal repository!"
    echo "Current email: $EMAIL"
    echo "Run: git config user.email 'you@users.noreply.github.com'"
    exit 1
fi

exit 0
```

Make it executable:
```bash
chmod +x .git/hooks/pre-commit
```

### 6. Use SSH Keys for GitHub

Instead of personal access tokens:

```bash
# Generate SSH key
ssh-keygen -t ed25519 -C "your_email@example.com"

# Add to ssh-agent
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# Copy public key and add to GitHub
cat ~/.ssh/id_ed25519.pub

# Change remote to SSH
git remote set-url origin git@github.com:username/repo.git
```

### 7. Protect Your Tokens

Never commit tokens or passwords:

```bash
# Use credential helper
git config --global credential.helper store

# Or for macOS
git config --global credential.helper osxkeychain

# Or for Windows
git config --global credential.helper wincred
```

## 🔍 Verification Commands

### Check Author of Recent Commits

```bash
# Last 10 commits with author info
git log -10 --format="%h %an <%ae> - %s"

# All commits by author
git log --author="username" --format="%h %an <%ae> - %s"

# Show full details of last commit
git log -1 --format=full
```

### Check Before Pushing

```bash
# See what will be pushed
git log origin/main..HEAD --format="%h %an <%ae> - %s"

# Dry run push
git push --dry-run origin main
```

## 📚 Additional Resources

### Official Documentation

- [Git Config Documentation](https://git-scm.com/docs/git-config)
- [GitHub Email Settings](https://github.com/settings/emails)
- [Git Filter-Branch](https://git-scm.com/docs/git-filter-branch)

### Tools

- [git-filter-repo](https://github.com/newren/git-filter-repo) - Modern history rewriting
- [BFG Repo-Cleaner](https://rtyley.github.io/bfg-repo-cleaner/) - Fast alternative
- [GitHub CLI](https://cli.github.com/) - Manage GitHub from terminal

### Tutorials

- [Changing Author Info](https://docs.github.com/en/github/committing-changes-to-your-project/changing-a-commit-message)
- [Git Rebase Tutorial](https://www.atlassian.com/git/tutorials/rewriting-history/git-rebase)

## 🎯 Quick Reference Card

```bash
# CHECK
git config user.name                          # Current name
git config user.email                         # Current email
git log -1 --format="%an <%ae>"              # Last commit author

# SET
git config user.name "name"                   # Local name
git config user.email "email"                 # Local email
git config --global user.name "name"          # Global name
git config --global user.email "email"        # Global email

# FIX LAST COMMIT
git commit --amend --reset-author --no-edit   # Fix author
git push origin main --force                  # Update remote

# FIX OLD COMMIT
git rebase -i <commit>^                       # Start rebase
# (mark as 'edit')
git commit --amend --reset-author --no-edit   # Fix author
git rebase --continue                         # Continue
git push origin main --force                  # Update remote

# FIX ALL COMMITS (careful!)
git filter-branch --env-filter 'export GIT_AUTHOR_NAME="name"; export GIT_AUTHOR_EMAIL="email"' -- --all
git push origin --force --all
```

---

## ⚠️ Important Warnings

1. **Force pushing rewrites history** - Coordinate with team members
2. **Backup before rewriting history** - Create a backup branch
3. **Never rewrite public shared history** without team coordination
4. **Force push carefully** - Double-check the branch name
5. **Test on a branch first** - Try fixes on a test branch

## 💡 Tips

- Set up your git config correctly from the start
- Use GitHub's no-reply email for privacy
- Create different configs for work/personal projects
- Verify author info before pushing
- Keep your GitHub email verified
- Use SSH keys instead of passwords
- Never commit sensitive information (tokens, passwords)

---

**Last Updated**: October 8, 2025
**Version**: 1.0
**License**: MIT

For more information about this project, see [README.md](README.md)
