# OpenSAFELY Update Dependencies Action

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
    - uses: actions/checkout@v4
    - uses: "opensafely-core/setup-action@v1"
      with:
        python-version: "3.11"
        install-just: true
    - uses: bennettoxford/update-dependencies-action@v1
      with:
        update_command: "just update-dependencies"
```

## Action inputs

| Name | Description | Required | Default |
| --- | --- | --- | --- |
| update_command | Command to update the dependencies | yes | just update-dependencies |
| on_changes_command|A command to run if changes are detected|no|None|
| token | The token that the action will use to create and update the pull request | no | GITHUB_TOKEN |
| commit_message | Commit message if changes found| no | "chore: update-dependencies" |
| pr_title | Pull request title | no | "Update dependencies" |
| automerge | Enable automerge on PRs created with the action | no | true |


## Workflows triggered by pull requests

Pull requests created by actions using the default `GITHUB_TOKEN` cannot trigger other workflows.

### Workarounds

1. Use an `on_changes_command`

This can run tests, checks etc that would usually run when a PR is opened, to ensure that
the PR is only opened if the checks pass. The PR itself will still not trigger the checks.

2. Use an alternative token

Alternatively, you can pass a token that is allowed to create further workflows and pass it as the
`token` input to this action.

For example, to create and use a GitHub App token:

```
  update-dependencies:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    - uses: "opensafely-core/setup-action@v1"
      with:
        python-version: "3.11"
        install-just: true 
    
    - uses: actions/create-github-app-token@v1
      id: generate-token
      with:
        app-id: <GitHub APP ID>
        private-key: ${{ secrets.CREATE_PR_APP_PRIVATE_KEY }}

    - uses: bennettoxford/update-dependencies-action@v1
      with:
        token: ${{ steps.generate-token.outputs.token }}
```

`<GitHub APP ID>` and `secrets.CREATE_PR_APP_PRIVATE_KEY` are the 
app ID and private token for an installed GitHub App that has the following 
repository permissions:

- content: read and write
- pull-requests: read and write

See the `create-pull-request` [docs][2] for other options.

## Action outputs
Outputs from the `create-pull-request` action are propograted and can be used by subsequent workflow steps.

- `pull-request-number` - The pull request number.
- `pull-request-url` - The URL of the pull request.
- `pull-request-operation` - The pull request operation performed by the action, created, updated, or none.
- `pull-request-head-sha` - The commit SHA of the pull request branch.
- `pull-request-branch` - The branch name of the pull request.

For example, to post a created or update PR to a slack channel:

```
  ...
    - uses: bennettoxford/update-dependencies-action@v1
      id: update_dependencies
      with:
        token: ${{ steps.generate-token.outputs.token }}

    - name: Notify slack
      if: ${{ steps.update_dependencies.outputs.pull-request-operation != 'none' }}
      uses: slackapi/slack-github-action@v2.0.0
      with:
        method: chat.postMessage
        token: << SLACK_BOT_TOKEN >>
        payload: |
          channel: "channel-id"
          text: "Update dependencies\n${{ steps.update_dependencies.outputs.pull-request-url }}"
```

## Releasing a new version

Existing workflow files reference this repo using the `v1` tag. If you make
backwards compatible changes to this repo you'll need to update the
`v1` tag:

    make tag-release

Breaking changes should use a new version tag so that tests for existing
repos continue to pass.


[1]: https://docs.github.com/en/actions/creating-actions/creating-a-composite-run-steps-action
[2]: https://github.com/peter-evans/create-pull-request/blob/main/docs/concepts-guidelines.md#triggering-further-workflow-runs
