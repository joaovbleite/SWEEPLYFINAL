#!/bin/sh
# Script to add, commit, and push all changes to GitHub
echo "Adding all changes..."
git add -A
echo "Committing changes..."
git commit -m "$1"
echo "Pushing to GitHub..."
git push origin main
echo "All done!"
