
---

# Protect `main`

For a new GitHub repo, I recommend using a **GitHub Ruleset** targeting the default branch. Rulesets can require PRs, status checks, signed commits, linear history, and block force pushes/deletion. :chatgpt-content-reference{index="0"}

Configure:

| Setting | RecallMind recommendation |
|---|---|
| Ruleset name | `Protect main` |
| Enforcement | **Active** |
| Target | Default branch / `main` |
| Restrict deletions | **ON** |
| Block force pushes | **ON** |
| Require pull request before merging | **ON** |
| Required approvals | **0 while you're solo**, then **1** when another developer joins |
| Dismiss stale approvals | ON once you have reviewers |
| Require conversation resolution | **ON** |
| Require status checks | **ON after CI is working** |
| Require branch up to date | Recommended |
| Require linear history | **ON** |
| Merge method | **Squash merge** |
| Bypass list | Ideally empty |
| Allow direct pushes to `main` | **No** |

GitHub supports required PRs and required status checks directly through rulesets/protected branches. :chatgpt-content-reference{index="1"}

### Important for you as a solo developer

Do **not** set:

```text
Required approvals = 1
