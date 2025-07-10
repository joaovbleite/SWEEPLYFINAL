# SWEEPLYPRO

## GitHub Integration

This repository is set up with automatic GitHub integration. To push your changes to GitHub, you can use the provided script:

```bash
./git-push-all.sh "Your commit message here"
```

This script will:
1. Add all changed files
2. Commit the changes with your provided message
3. Push the changes to GitHub

## Alias Setup

For convenience, an alias has been added to your .zshrc file. After restarting your terminal or running `source ~/.zshrc`, you can use:

```bash
gpa "Your commit message here"
```

This alias will perform the same actions as the script.

