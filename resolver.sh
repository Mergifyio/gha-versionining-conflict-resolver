#!/bin/bash

echo "--- START ---"
echo "Repo is $HEAD_REPO"
echo "Head branch is $HEAD_BRANCH"
echo "Base branch is $BASE_BRANCH"
echo "User is $USER"
echo "Email is $EMAIL"

# print stuffs
echo "remotes"
git remote -v

git status
git branch --show-current

# 1) BASE is checked out by the action checkout
# - if HEAD_REPO (from input) != current head repo (current)
#       -> add HEAD_REPO origin
remote_url=$(git config --get remote.origin.url)
echo "$remote_url"

if [ -n "$remote_url" ]; then
  git_url=$(echo "$remote_url" | awk -F/ '{print $1 "//" $3}')
  repo=$(echo "$remote_url" | awk -F/ '{print $4 "/" $5}' | sed 's/\.git$//')
else
  echo "Could not find remote url"
  exit 1
fi

echo "git url: $git_url"
echo "repo: $repo"

if [ "$repo" != "$HEAD_REPO" ]; then
  echo "Head of PR is from a forked repository -> must add remote"
  # 2) Add remote
  echo "Adding remote"
  forked_url="$git_url/$HEAD_REPO.git"
  echo "forked url: $forked_url"
  git remote add forked "$forked_url"
fi

echo "remotes"
git remote -v

# 3) Checkout


## install poetry
#curl -sSL https://install.python-poetry.org | python3 -
#
#if ! git ls-remote --heads origin | grep -wq "refs/heads/$BASE_BRANCH"; then
#  echo "base branch '$BASE_BRANCH' does not exist"
#  exit 1
#fi
#
#current_branch=$(git branch --show-current)
#if [[ "$current_branch" = "$BASE_BRANCH" ]]; then
#  echo "cannot run conflict resolution from base branch '$BASE_BRANCH'"
#  exit 1
#fi
#
## git authentication
#git config --global user.name "$USER"
#git config --global user.email "$EMAIL"
#
#git fetch origin "$BASE_BRANCH"
#git rebase "origin/$BASE_BRANCH"
#
## exit if more than poetry is conflicting
#conflict_files=$(git diff --name-only --diff-filter=U --relative)
#if [ "$conflict_files" != "poetry.lock" ]; then
#  echo "conflicts resolution is supported for 'poetry.lock' only"
#  git rebase --abort
#  exit 1
#fi
#
## keep the local poetry.lock
#git checkout --theirs poetry.lock
#echo "Refreshing poetry.lock"
#poetry lock --no-update
#
#git add poetry.lock
#git -c core.editor=true rebase --continue
#
#echo "Pushing resolved poetry.lock"
#git push -v --force-with-lease origin "$current_branch"
