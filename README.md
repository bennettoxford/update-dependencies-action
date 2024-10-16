# OpenSAFELY Research Action

This repo provides a GitHub Action for ensuring that
dependencies are kept up to date.

It is written as a "[composite run steps][1]" action.


## Usage

You can invoke this action from a Github workflow file (e.g.
`.github/workflows/dependencies.yaml`):

```yaml
name: Update python dependencies

on:
  workflow_dispatch:
  schedule:
    - cron:  "0 23 * * *"
env:
  GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
jobs:
  update-dependencies:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    - uses: "opensafely-core/setup-action@v1"
      with:
        python-version: "3.11"
        install-just: true
    - uses: opensafely-core/update-dependencies-action@v1
      with:
        update_command: "just update-dependencies"
        on_changes_command: "just test"
```

## Action inputs

| Name | Description | Required | Default |
| --- | --- | --- | --- |
| update_command | Command to update the dependencies | yes | just update-dependencies |
| on_changes_command|A command to run if changes are detected|no|None|
| token | The token that the action will use to create and update the pull request | no | GITHUB_TOKEN


## Workflows triggered by pull requests

Pull requests created by actions using the default `GITHUB_TOKEN` cannot trigger other workflows.

You can pass an `on_changes_command` which can run tests, checks etc that would usually run when
a PR is opened.

Alternatively, you can pass a token that is allowed to create further workflows and pass it as the
`token` input to this action.

Or see the `create-pull-request` [docs][2] for other options.


## Releasing a new version

Existing workflow files reference this repo using the `v1` tag. If you make
backwards compatible changes to this repo you'll need to update the
`v1` tag:

    make tag-release

Breaking changes should use a new version tag so that tests for existing
repos continue to pass.


[1]: https://docs.github.com/en/actions/creating-actions/creating-a-composite-run-steps-action
[2]: https://github.com/peter-evans/create-pull-request/blob/main/docs/concepts-guidelines.md#triggering-further-workflow-runs
