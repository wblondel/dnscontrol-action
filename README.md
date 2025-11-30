# DNSControl Action

![](https://github.com/wblondel/dnscontrol-action/workflows/build/badge.svg)

Deploy your DNS configuration using [GitHub Actions](https://github.com/actions)
using [DNSControl](https://github.com/StackExchange/dnscontrol/).

## Usage

These are the three relevant sub commands to use with this action.

### check

Run the action with the 'check' argument in order to check and validate the `dnsconfig.js`
file. This action does not communicate with the DNS providers, hence does not require
any secrets to be set.

```yaml
name: Check

on: pull_request

jobs:
  check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@08c6903cd8c0fde910a37f88322edcfb5dd907a8 # v5.0.0

      - name: DNSControl check
        uses: wblondel/dnscontrol-action@v4.26.0 # replace the version tag with the latest version's commit-hash for better security
        with:
          args: check

          # Optionally, if your DNSConfig config file is in a non-default location,
          # you could specify the path to it.
          config_file: 'dns/dnsconfig.js'
```

### preview

Run the action with the 'preview' argument to check what changes need to be made.
It prints out what DNS records are expected to be created, modified or deleted.
This action requires the secrets for the specified DNS providers.

```yaml
name: Preview

on: pull_request

jobs:
  preview:
    runs-on: ubuntu-latest
    env:
      DESEC_API_TOKEN: ${{ secrets.DESEC_API_TOKEN }}
      OVH_APP_KEY: ${{ secrets.OVH_APP_KEY }}
      OVH_APP_SECRET_KEY: ${{ secrets.OVH_APP_SECRET_KEY }}
      OVH_CONSUMER_KEY: ${{ secrets.OVH_CONSUMER_KEY }}

    steps:
      - uses: actions/checkout@08c6903cd8c0fde910a37f88322edcfb5dd907a8 # v5.0.0

      - name: DNSControl preview
        uses: wblondel/dnscontrol-action@v4.26.0 # replace the version tag with the latest version's commit-hash for better security
        id: dnscontrol_preview
        with:
          args: preview

          # Optionally, if your DNSConfig files are in a non-default location,
          # you could specify the paths to the config and credentials file.
          config_file: 'dns/dnscontrol.js'
          creds_file: 'dns/creds.json'
```

This is the action you probably want to run for each branch so that proposed changes
could be verified before an authorized person merges these changes into the default
branch.

#### Pull request comment

Optionally, you could configure your GitHub Action so that the output of the 'preview'
command is published as a comment to the pull request for the branch containing the
changes. This saves you several clicks through the menus to get to the output logs
for the preview job.

However, I do not recommend doing this, as all GitHub actions to comment on PRs are abandoned and / or have security issues.

### push

Run the action with the 'push' argument to publish the changes to the specified
DNS providers.

Running the action with the 'push' argument will publish the changes with the
specified DNS providers. The example workflow depicted below contains a filtering
pattern so that it only runs on the default branch.

```yaml
name: Push

on:
  push:
    branches:
      - main

jobs:
  push:
    runs-on: ubuntu-latest
    env:
      DESEC_API_TOKEN: ${{ secrets.DESEC_API_TOKEN }}
      OVH_APP_KEY: ${{ secrets.OVH_APP_KEY }}
      OVH_APP_SECRET_KEY: ${{ secrets.OVH_APP_SECRET_KEY }}
      OVH_CONSUMER_KEY: ${{ secrets.OVH_CONSUMER_KEY }}

    steps:
      - uses: actions/checkout@08c6903cd8c0fde910a37f88322edcfb5dd907a8 # v5.0.0

      - name: DNSControl push
        uses: wblondel/dnscontrol-action@v4.26.0 # replace the version tag with the latest version's commit-hash for better security
        with:
          args: push

          # Optionally, if your DNSConfig files are in a non-default location,
          # you could specify the paths to the config and credentials file.
          config_file: 'dns/dnsconfig.js'
          creds_file: 'dns/creds.json'
```

## Credentials

Depending on the DNS providers that are used, this action requires credentials to
be set. These secrets can be configured through a file named `creds.json`. You
should **not** add secrets as plaintext to this file, but use GitHub
Actions [encrypted secrets](https://help.github.com/en/actions/configuring-and-managing-workflows/creating-and-storing-encrypted-secrets)
instead. These encrypted secrets are exposed at runtime as environment variables.
See the DNSControl [Service Providers](https://stackexchange.github.io/dnscontrol/provider-list)
documentation for details.

You could define the `creds.json` file as follows, and create the relevant encrypted secrets in your repository.

```json
{
  "ovh": {
    "TYPE": "OVH",
    "app-key": "$OVH_APP_KEY",
    "app-secret-key": "$OVH_APP_SECRET_KEY",
    "consumer-key": "$OVH_CONSUMER_KEY"
  },
  "desec": {
    "TYPE": "DESEC",
    "auth-token": "$DESEC_API_TOKEN"
  },
  "none": {
    "TYPE": "NONE"
  }
}
```

## Dependabot

[Dependabot](https://docs.github.com/en/github/administering-a-repository/keeping-your-actions-up-to-date-with-github-dependabot)
is a GitHub service that helps developers to automate dependency maintenance and
keep dependencies updated to the latest versions. It has native support for
[GitHub Actions](https://docs.github.com/en/github/administering-a-repository/configuration-options-for-dependency-updates#package-ecosystem),
which means you can use it in your GitHub repository to keep the DNSConrol Acion
up-to-date.

To enable Dependabot in your GitHub repository, add a `.github/dependabot.yml`
file with the following contents:

```yaml
version: 2
updates:

  # Set update schedule for GitHub Actions
  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "daily"
```
