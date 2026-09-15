# Keeping private information out of this project

Keep credentials in environment variables or an ignored local `.env` file. Put private datasets in `local-data/` and never force-add ignored files.

## Before committing

Install [Gitleaks](https://github.com/gitleaks/gitleaks), then enable the included local hook:

```sh
git config core.hooksPath .githooks
```

The hook scans staged changes and blocks the commit when the scanner is missing or finds a secret. The GitHub workflow also scans the Git history after pushes and on pull requests. A CI check runs after upload, so use the local hook to catch secrets before they leave your computer.

Before adding PDFs, spreadsheets, notebooks, screenshots or archives, inspect their contents, metadata, embedded files and saved outputs. Pattern-based secret scanning does not establish that private or business-sensitive data is safe to publish.

If a live credential is ever published, revoke or rotate it first. Deleting the visible file alone does not remove it from Git history.

The included pre-push hook also scans local history before upload. An additional local rule detects short MQTT/InfluxDB credential assignments found in legacy coursework.
