#!/bin/bash

# Simple script to remind about committing changes
# Usage: ./commit-reminder.sh [file_path]

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${YELLOW}REMINDER: Don't forget to commit your changes!${NC}"
echo -e "${GREEN}----------------------------------------${NC}"

# Check if a file path was provided
if [ -n "$1" ]; then
  echo -e "You just edited: ${YELLOW}$1${NC}"
  echo -e "Run: ${GREEN}git add $1${NC}"
else
  echo -e "Run: ${GREEN}git status${NC} to see modified files"
  echo -e "Then: ${GREEN}git add <files>${NC} to stage changes"
fi

echo -e "Then: ${GREEN}git commit -m \"Your descriptive message\"${NC}"
echo -e "And:  ${GREEN}git push${NC} to update GitHub"
echo -e "${GREEN}========================================${NC}" 