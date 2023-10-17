#!/bin/bash

echo "--- START ---"
git status

# install poetry
curl -sSL https://install.python-poetry.org | python3 -

if ! git ls-remote --heads origin | grep -wq "refs/heads/$BASE_BRANCH"; then
  echo "base branch '$BASE_BRANCH' does not exist"
  exit 1
fi

current_branch=$(git branch --show-current)
if [[ "$current_branch" = "$BASE_BRANCH" ]]; then
  echo "cannot run conflict resolution from base branch '$BASE_BRANCH'"
  exit 1
fi

# git authentication
git config --global user.name "$USER"
git config --global user.email "$EMAIL"

echo "Branches on origin"
git ls-remote --heads origin
echo "Branches locally"
git branch -l
echo "--"
git branch -r

echo "FETCHING origin and current branch"
git fetch origin "$BASE_BRANCH" #  "$current_branch"  # current_branch optional ?
git rebase "origin/$BASE_BRANCH"

echo "Branches on origin"
git ls-remote --heads origin
echo "Branches locally"
git branch -l
echo "--"
git branch -r

# exit if more than poetry is conflicting
conflict_files=$(git diff --name-only --diff-filter=U --relative)
if [ "$conflict_files" != "poetry.lock" ]; then
  echo "conflicts resolution is supported for 'poetry.lock' only"
  git rebase --abort
  exit 1
fi

# keep the local poetry.lock
git checkout --theirs poetry.lock
echo "Refreshing poetry.lock"
poetry lock --no-update

git add poetry.lock
git -c core.editor=true rebase --continue

echo "Pushing resolved poetry.lock"
#git push -f origin
echo current local branch "$current_branch"
echo "$current_branch":refs/heads/"$current_branch"
git push -v --force-with-lease origin "$current_branch"  # :"$current_branch"
