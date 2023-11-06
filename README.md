# gha-versionining-conflict-resolver

This GitHub Action is designed to automatically resolve the conflicts in dependencies version files, starting
with `poetry.lock` which is currently supported.

## Use with Mergify

First, we will create a GitHub Action's workflow. We will then trigger it on the conflicting pull requests.

### Create a GHA workflow

Add a GitHub Action Workflow to your repository with a step making use of this GitHub Action. In this example,
let us call creat it in the file `conflicts_resolver.yaml`.

Your worfklow needs the `workflow_dispatch` trigger and must exist in your default branch to become dispatchable.
You should provide a personal access token (PAT) with pull requests write permission to the action, as well as the
associated user and email.

```yaml
name: conflicts_resolver

on:
  workflow_dispatch:
    inputs:
      head-repo:
        description: "Full name of the head repository"
        type: string
        required: true
      head-branch:
        description: "Head branch"
        type: string
        required: true
      base-branch:
        description: "Base branch"
        type: string
        required: false
        default: "main"
      # Optionals are faculative to comment the pull request
      base-repo:
        description: "Base repo to comment PR about the resolution"
        type: string
        required: false
      pull-request-number:
        description: "PR number to comment PR about the resolution"
        type: number
        required: false
      author:
        description: "Author to comment PR about the resolution"
        type: string
        required: false

jobs:
  resolve_conflicts:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout the branch
        uses: actions/checkout@v4
        with:
          fetch-depth: '0'
          token: ${{ secrets.MY_SECRET_PAT }}
          
      - name: resolve-poetry-conflicts
        uses: Mergifyio/gha-versionining-conflict-resolver@main  # v1
        env:
          # Optional to comment the pull request
          GITHUB_TOKEN: ${{ secrets.MY_PAT }}
        with:
          head-repo: ${{ inputs.head-repo }}
          head-branch: ${{ inputs.head-branch }}
          base-branch: ${{ inputs.base-branch }}
          user: my_user
          email: my_user@example.com
          base-repo: ${{ inputs.base-repo }}
          pull-request-number: ${{ inputs.pull-request-number }}
          author: ${{ inputs.author }}
```

### Trigger the workflow automation in your Mergify config

In your `.mergify.yaml` config, add the following `pull_request_rule` to trigger the conflicts resolver on conflicts.

#### Notes
- We target the `poetry.lock` in this example.
- `head-repo` and `head-branch` are needed as inputs and that they are provided dynamically by Mergify.
- If the head repository is forked, the PAT must be allowed to push on this fork.

```yaml
  - name: Dispatch a gha
    conditions:
      - conflicts
      - modified-files=poetry.lock
    github_actions:
      workflow:
        dispatch:
          - workflow: conflicts_resolver.yaml
            inputs:
              head-repo: "{{ head_repo_full_name }}"
              head-branch: "{{ head }}"
              base-branch: main
              # Optionals to comment about successful resolution
              base-repo: "{{ repository_full_name }}"
              pull-request-number: "{{ number }}"
              author: "{{ author }}"
```
