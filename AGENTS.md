# AGENTS.md

A reusable Terraform module that creates and configures a GitHub repository
(settings, labels, environments, Actions permissions, branch ruleset) and
optionally checks that required Actions secrets exist.

## What to know

- This is a module, not a root config: no `provider` or `backend` blocks. The
  caller wires those.
- One apply does everything. The secret-check data source uses `depends_on` on
  the repository so its read defers to apply time, after the repo exists.
- The branch ruleset blocks pushing existing history; `ruleset_enforcement`
  (`active` / `disabled`) handles seeding.
- The secret check is opt-in via `required_secrets`. It confirms names exist,
  never reads values, and is skipped (no secret permissions needed) when the list
  is empty. Owner type (org vs user) is auto-detected.
- `github_issue_labels` is authoritative, so `labels` is the full set; it
  defaults to GitHub's stock labels to avoid deleting the auto-created ones.

## Working here

- Run `terraform fmt` and `terraform validate` before committing.
- Keep prose plain and human; avoid AI tells. Give docs a humanizer pass.
- Release with semver tags (`v0.1.0`); consumers pin `?ref=`.
