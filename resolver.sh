#!/bin/bash

#base=$1

echo "$BASE"
echo "$GH_TOKEN"

echo "Install poetry"
curl -sSL https://install.python-poetry.org | python3 -
echo "Poetry version"
echo "$(~/.local/share/pypoetry/venv/bin/poetry --version)"

#echo "-> start"
#echo "listing branches"
#echo "$(git branch --list)"
#echo "status"
#git status
#echo "list remote branches"
#echo "$(git ls-remote --heads origin)"
#echo "test string"
#echo "refs/heads/$BASE"

if ! git ls-remote --heads origin | grep -wq "refs/heads/$BASE"; then
  echo "base branch '$BASE' does not exist"
  exit 1
fi

if [[ $(git branch --show-current) = "$BASE" ]]; then
  echo "cannot run conflict resolution from base branch '$BASE'"
  exit 1
fi

# start rebase
#git fetch

#echo "listing branches"
#echo "$(git branch --list)"
#current=$(git branch --show-current)
#echo "current branch $current"
#git fetch
#git checkout -b "$BASE" origin/"$BASE"
#git pull
#git checkout "$current"
#git rebase "$BASE"

echo "-- configure git creds --"
git config user.name github-actions
git config user.email github-actions@github.com
echo "-- configured credentials --"

git fetch
#git rebase origin/main
git rebase "origin/$BASE"


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
echo "Pushing resolved conflicts"
git push -f origin
