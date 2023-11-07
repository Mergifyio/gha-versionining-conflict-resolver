#!/bin/bash

is_forked_head=0
forked="forked"

# input checks
if ! git ls-remote --heads origin | grep -wq "refs/heads/$BASE_BRANCH"; then
  echo "base branch '$BASE_BRANCH' does not exist"
  exit 1
fi

# determine remote of head
remote_url=$(git config --get remote.origin.url)
if [ -n "$remote_url" ]; then
  git_url=$(echo "$remote_url" | awk -F/ '{print $1 "//" $3}')
  origin_repo=$(echo "$remote_url" | awk -F/ '{print $4 "/" $5}' | sed 's/\.git$//')
else
  echo "could not find remote url"
  exit 1
fi

if [ "$origin_repo" != "$HEAD_REPO" ]; then
  # head is a on a forked repository
  is_forked_head=1
  # add forked remote
  forked_url="$git_url/$HEAD_REPO.git"
  git remote add "$forked" "$forked_url"
  # checkout head on fork
  git fetch "$forked" "$HEAD_BRANCH"
  git checkout -b "$HEAD_BRANCH" "$forked/$HEAD_BRANCH"
else
  # head is on origin
  git fetch origin "$HEAD_BRANCH"
  git checkout -b "$HEAD_BRANCH" "origin/$HEAD_BRANCH"
fi


# rebase head
git fetch origin "$BASE_BRANCH"
git rebase "origin/$BASE_BRANCH"

conflict_files=$(git diff --name-only --diff-filter=U --relative)
if [ "$conflict_files" != "poetry.lock" ]; then
  echo "conflicts resolution is supported for 'poetry.lock' only"
  git rebase --abort
  exit 1
fi

# install poetry
curl -sSL https://install.python-poetry.org | python3 -

# git authentication
git config --global user.name "$USER"
git config --global user.email "$EMAIL"

# resolve poetry conflict
git checkout --theirs poetry.lock
poetry lock -v --no-update --no-cache

git add poetry.lock
git -c core.editor=true rebase --continue

# pushing resolved
if [ "$is_forked_head" -eq 1 ]; then
  target="forked"
else
  target="origin"
fi

git push -v --force-with-lease "$target"
