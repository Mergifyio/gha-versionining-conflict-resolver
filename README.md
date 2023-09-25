# gha-versionining-conflict-resolver

This GitHub Action is designed to automatically try to resolve the conflicts in dependencies version files.

## Use with Mergify

First, you must add a GitHub Action Workflow to your repository with a step making use of this GitHub Action. 
Your worfklow needs the `workflow_dispatch` trigger and must exist in your default branch to become dispatchable. 

```yaml
name: conflicts_resolver

on:
  workflow_dispatch:

jobs:
  resolve_conflicts:
    runs-on: ubuntu-latest
    steps:
      - name: resolve
        uses: mergifyio/conflicts_resolver
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
              package_managers: poetry
```
