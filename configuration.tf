# Everything below references the repository RESOURCE (github_repository.this),
# so it's created after the repo in the same apply — no separate stage needed.

# Labels — managed authoritatively (reconciles the auto-created defaults).
resource "github_issue_labels" "this" {
  repository = github_repository.this.name

  dynamic "label" {
    for_each = var.labels
    content {
      name        = label.value.name
      color       = label.value.color
      description = label.value.description
    }
  }
}

# Deployment environments (no protection rules).
resource "github_repository_environment" "this" {
  for_each    = toset(var.environments)
  repository  = github_repository.this.name
  environment = each.value
}

# Actions runtime policy.
resource "github_actions_repository_permissions" "this" {
  repository      = github_repository.this.name
  enabled         = true
  allowed_actions = var.allowed_actions
}

# Default-branch ruleset: block deletion and non-fast-forward, require signed
# commits, require a PR (0 approvals) to update the branch. Set
# ruleset_enforcement = "disabled" to seed existing history, then "active".
resource "github_repository_ruleset" "main" {
  name        = "main"
  repository  = github_repository.this.name
  target      = "branch"
  enforcement = var.ruleset_enforcement

  conditions {
    ref_name {
      include = ["~DEFAULT_BRANCH"]
      exclude = []
    }
  }

  rules {
    deletion            = true
    non_fast_forward    = true
    required_signatures = true

    pull_request {
      required_approving_review_count   = 0
      dismiss_stale_reviews_on_push     = false
      require_code_owner_review         = false
      require_last_push_approval        = false
      required_review_thread_resolution = false
      allowed_merge_methods             = var.ruleset_allowed_merge_methods
    }
  }
}
