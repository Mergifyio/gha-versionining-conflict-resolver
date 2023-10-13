# gha-versionining-conflict-resolver

This GitHub Action is designed to automatically resolve the conflicts in dependencies version files, starting
with `poetry.lock` which is currently supported.

## Use with Mergify

First, you must add a GitHub Action Workflow to your repository with a step making use of this GitHub Action. 
Your worfklow needs the `workflow_dispatch` trigger and must exist in your default branch to become dispatchable.
You should provide a personal access token with pull requests write permission to the action, as well as the
associated user and email.

```yaml
name: conflicts_resolver

on:
  workflow_dispatch:
    inputs:
      base:
        description: "Base branch"
        type: string
        required: false
        default: "main"
      head:
        description: "Head branch"
        type: string
        required: true

jobs:
  resolve_conflicts:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout the branch
        uses: actions/checkout@v4
        with:
          fetch-depth: '0'
          token: ${{ secrets.MY_SECRET_PAT }}
          ref: ${{ inputs.head }}
          
      - name: resolve-poetry-conflicts
        uses: Mergifyio/gha-versionining-conflict-resolver@main  # will be @v1 when released
        with:
          base: ${{ inputs.base }}
          user: my_user
          email: my_user@example.com
```

In your `.mergify.yaml` config, add the following `pull_request_rule` to trigger the conflicts resolver on conflicts.
Note that we target the `poetry.lock` in this example.

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
              base: "main"
```
