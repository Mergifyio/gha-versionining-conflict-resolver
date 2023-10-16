#!/bin/bash

echo "--- START ---"
git status

# install poetry
curl -sSL https://install.python-poetry.org | python3 -

if ! git ls-remote --heads origin | grep -wq "refs/heads/$BASE_BRANCH"; then
  echo "base branch '$BASE_BRANCH' does not exist"
  exit 1
fi

if [[ $(git branch --show-current) = "$BASE_BRANCH" ]]; then
  echo "cannot run conflict resolution from base branch '$BASE_BRANCH'"
  exit 1
fi

# git authentication
git config --global user.name "$USER"
git config --global user.email "$EMAIL"

git fetch
git rebase "origin/$BASE_BRANCH"

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
git push -f origin
