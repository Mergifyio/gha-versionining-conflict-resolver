#!/bin/bash

echo "--- START ---"
echo "Repo is $REPO"
echo "Head branch is $HEAD_BRANCH"
echo "Base branch is $BASE_BRANCH"
echo "User is $USER"
echo "Email is $EMAIL"

git status
git branch --show-current


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

git fetch origin "$BASE_BRANCH"
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
git push -v --force-with-lease origin "$current_branch"
