#!/bin/bash

base=$1

#echo "-> start"
#echo "listing branches"
#echo "$(git branch --list)"
#echo "status"
#git status
#echo "list remote branches"
#echo "$(git ls-remote --heads origin)"
#echo "test string"
#echo "refs/heads/$base"

if ! git ls-remote --heads origin | grep -wq "refs/heads/$base"; then
  echo "base branch '$base' does not exist"
  exit 1
fi

if [[ $(git branch --show-current) = "$base" ]]; then
  echo "cannot run conflict resolution from base branch '$base'"
  exit 1
fi

# start rebase
#git fetch

#echo "listing branches"
#echo "$(git branch --list)"
#current=$(git branch --show-current)
#echo "current branch $current"
#git fetch
#git checkout -b "$base" origin/"$base"
#git pull
#git checkout "$current"
#git rebase "$base"

git fetch
#git rebase origin/main
git rebase "origin/$base"


echo "GIT DIFF"
echo "$(git diff)"
echo "-----"

# 1. first check to exit if more than poetry is conflicting
conflict_files=$(git diff --name-only --diff-filter=U --relative)
echo "Conflicting files: ${conflict_files}"

if [ "$conflict_files" != "poetry.lock" ]; then
  echo "conflicts resolution is supported for 'poetry.lock' only"
  git rebase --abort
  exit 1
fi

# 2. keep the local poetry.lock
git checkout --theirs poetry.lock

# 3. rewrite poetry lock file
echo "Refreshing poetry.lock"
poetry lock --no-update

echo "Add modified poetry lock to index"
git add poetry.lock
git -c core.editor=true rebase --continue

# 4. commit and push changes
#git commit -m "resolve poetry.lock conflict"
git config user.name github-actions
git config user.email github-actions@github.com
git push -f origin
