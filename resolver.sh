#!/bin/bash

#base=$1

echo "---"
echo "$BASE_BRANCH"
echo "$USER"
echo "$EMAIL"
#echo "$GH_TOKEN"

echo "Python V"
echo "$(python3 -V)"

#echo "Install poetry"
curl -sSL https://install.python-poetry.org | python3 -
#echo "Poetry version"
#echo "$(~/.local/share/pypoetry/venv/bin/poetry --version)"

#echo "Python V"
#echo "$(python3 -V)"
#echo "-> start"
#echo "listing branches"
#echo "$(git branch --list)"
#echo "status"
#git status
#echo "list remote branches"
#echo "$(git ls-remote --heads origin)"
#echo "test string"
#echo "refs/heads/$BASE_BRANCH"

if ! git ls-remote --heads origin | grep -wq "refs/heads/$BASE_BRANCH"; then
  echo "base branch '$BASE_BRANCH' does not exist"
  exit 1
fi

if [[ $(git branch --show-current) = "$BASE_BRANCH" ]]; then
  echo "cannot run conflict resolution from base branch '$BASE_BRANCH'"
  exit 1
fi

# start rebase
#git fetch

#echo "listing branches"
#echo "$(git branch --list)"
#current=$(git branch --show-current)
#echo "current branch $current"
#git fetch
#git checkout -b "$BASE_BRANCH" origin/"$BASE_BRANCH"
#git pull
#git checkout "$current"
#git rebase "$BASE_BRANCH"

#echo "-- configure git creds --"
#git config user.name github-actions
#git config user.email github-actions@github.com
#echo "-- configured credentials --"

git config --global user.name "$USER"
git config --global user.email "$EMAIL"

git fetch
#git rebase origin/main
git rebase "origin/$BASE_BRANCH"


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
