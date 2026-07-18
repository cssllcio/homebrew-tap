# Tap Hardening Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Harden `cssllcio/homebrew-tap` (and its two release repos) with commit signing, branch protection, CI linting, accurate license metadata, and a provenance note — without breaking the solo-maintainer workflow.

**Architecture:** Local SSH-based commit signing feeds three near-identical classic-branch-protection configurations (one per repo), then a small GitHub Actions workflow adds automated `brew audit`/`brew style` checks to `homebrew-tap`, landed through a real PR to prove the new rules work, followed by a final protection update that makes that check required.

**Tech Stack:** `git`, `gh` (GitHub CLI) authenticated as `gitizenme`, GitHub REST API (classic branch protection endpoints, `ssh_signing_keys`), GitHub Actions (`Homebrew/actions/setup-homebrew`), Ruby (Homebrew formula DSL), Markdown.

## Global Constraints

- Repos in scope: `cssllcio/homebrew-tap`, `cssllcio/vibrai-releases`, `cssllcio/typeclip` — all public, default branch `main`.
- Solo maintainer, no other collaborators — branch protection must NOT require a second approving review; `enforce_admins` stays `false` so the repo owner can still push/merge directly.
- No commit signing configured anywhere yet. Existing SSH key at `~/.ssh/id_ed25519.pub` is reused for signing — do not generate a new key.
- Commit signing (Task 1) MUST be completed and verified before any repo requires signed commits (Tasks 2–4), or the owner gets locked out of pushing to `main` on that repo.
- `gh auth status` currently has scopes `gist, project, read:org, repo, workflow` — uploading a signing key needs `admin:ssh_signing_key`, requested via `gh auth refresh` in Task 1.
- Every `gh api` call in this plan changes GitHub account or repo settings — confirm with the user in chat before running each one; do not batch multiple settings changes into one unconfirmed step.
- `vibrai.rb`'s `license :cannot_represent` is the *correct* value (Vibrai is confirmed proprietary/all-rights-reserved and Homebrew has no SPDX id for that) — Task 5 only adds a clarifying comment, it does not change the license value.
- Use the classic branch protection API (`/branches/{branch}/protection`), not the newer repository-rulesets API — it has an explicit `enforce_admins: false` field that cleanly expresses "owner bypasses," rather than needing to guess numeric bypass-actor role IDs.
- Repo merge settings on `homebrew-tap` confirmed: squash, rebase, and merge-commit are all allowed — Task 5's PR is merged with `--squash` (required_linear_history forbids merge commits).

---

## File Structure

- Create: `.github/workflows/lint.yml` — CI job running `brew audit --strict` and `brew style` on every push/PR to `homebrew-tap`.
- Modify: `Formula/vibrai.rb` — add a comment above the `license :cannot_represent` line.
- Modify: `README.md` — add a short "About this tap" provenance section.
- No files change for Tasks 1–4 and Task 6 — those are `git config` (local, unversioned) and GitHub account/repo settings changes made via `gh api`.

---

### Task 1: Set up SSH-based commit signing

**Files:** none (global git config + GitHub account setting)

**Interfaces:**
- Consumes: existing SSH key at `~/.ssh/id_ed25519.pub` (confirmed present).
- Produces: local git configured to sign every commit with that key; that key registered on GitHub as a signing key. Tasks 2–4 depend on this being verified working before they run.

- [ ] **Step 1: Configure git to sign commits with the existing SSH key**

```bash
git config --global gpg.format ssh
git config --global user.signingkey ~/.ssh/id_ed25519.pub
git config --global commit.gpgsign true
```

- [ ] **Step 2: Verify the config took**

Run: `git config --global --get-regexp '^(gpg\.format|user\.signingkey|commit\.gpgsign)$'`

Expected output:
```
gpg.format ssh
user.signingkey /Users/joe/.ssh/id_ed25519.pub
commit.gpgsign true
```

- [ ] **Step 3: Confirm with the user, then request the scope needed to upload a signing key**

This is a GitHub account permission change — confirm with the user in chat before running it.

```bash
gh auth refresh -h github.com -s admin:ssh_signing_key
```

Expected: prompts a browser/device flow; `gh auth status` afterward shows `admin:ssh_signing_key` in the scope list.

- [ ] **Step 4: Confirm with the user, then upload the key to GitHub as a signing key**

Confirm with the user in chat before running it (adds a key to their GitHub account).

```bash
gh api -X POST /user/ssh_signing_keys \
  -f title="$(hostname -s) commit signing" \
  -f key="$(cat ~/.ssh/id_ed25519.pub)"
```

Expected: JSON response with an `"id"` field and `"key"` matching the local pubkey content.

- [ ] **Step 5: Verify the signing key is registered**

Run: `gh api /user/ssh_signing_keys --jq '.[].title'`
Expected: includes the title used in Step 4 (e.g. `yourhostname commit signing`).

- [ ] **Step 6: Verify signing actually works, in an isolated scratch repo (not the real tap)**

```bash
mkdir -p /tmp/sign-check && cd /tmp/sign-check && git init -q
git commit --allow-empty -m "test: verify SSH commit signing"
git log --show-signature -1
cd / && rm -rf /tmp/sign-check
```

Expected: `git log --show-signature -1` output includes `Good "git" signature for ... with ED25519 key SHA256:...` (no `gpg: Can't check signature` or `error` lines). If it errors instead, stop and fix signing configuration before proceeding to Task 2 — do not enable required-signatures on any repo while this is broken.

---

### Task 2: Branch protection on `homebrew-tap`

**Files:** none (GitHub repo settings)

**Interfaces:**
- Consumes: working commit signing from Task 1 (verified in Step 6).
- Produces: `main` on `cssllcio/homebrew-tap` protected (signed commits required, linear history required, no force-push/delete, admin bypass retained, no required status check yet). Task 5 will open a PR against this protected branch; Task 6 will add a required status check on top of this.

- [ ] **Step 1: Confirm with the user, then apply base branch protection**

Confirm with the user in chat before running it (repo settings change).

```bash
gh api -X PUT /repos/cssllcio/homebrew-tap/branches/main/protection \
  --input - <<'EOF'
{
  "required_status_checks": null,
  "enforce_admins": false,
  "required_pull_request_reviews": null,
  "restrictions": null,
  "required_linear_history": true,
  "allow_force_pushes": false,
  "allow_deletions": false
}
EOF
```

Expected: JSON response echoing `"enforce_admins": {"enabled": false}`, `"required_linear_history": {"enabled": true}`, `"allow_force_pushes": {"enabled": false}`, `"allow_deletions": {"enabled": false}`.

- [ ] **Step 2: Enable required commit signatures**

```bash
gh api -X POST /repos/cssllcio/homebrew-tap/branches/main/protection/required_signatures
```

Expected: `{"url":"...","enabled":true}`

- [ ] **Step 3: Verify the full protection state**

Run: `gh api /repos/cssllcio/homebrew-tap/branches/main/protection --jq '{enforce_admins: .enforce_admins.enabled, linear_history: .required_linear_history.enabled, force_pushes: .allow_force_pushes.enabled, deletions: .allow_deletions.enabled}'`

Expected:
```json
{"enforce_admins":false,"linear_history":true,"force_pushes":false,"deletions":false}
```

Run: `gh api /repos/cssllcio/homebrew-tap/branches/main/protection/required_signatures --jq .enabled`
Expected: `true`

---

### Task 3: Branch protection on `vibrai-releases`

**Files:** none (GitHub repo settings)

**Interfaces:**
- Consumes: working commit signing from Task 1.
- Produces: `main` on `cssllcio/vibrai-releases` protected identically to Task 2, minus any status-check wiring (this repo has no CI in scope).

- [ ] **Step 1: Confirm with the user, then apply base branch protection**

```bash
gh api -X PUT /repos/cssllcio/vibrai-releases/branches/main/protection \
  --input - <<'EOF'
{
  "required_status_checks": null,
  "enforce_admins": false,
  "required_pull_request_reviews": null,
  "restrictions": null,
  "required_linear_history": true,
  "allow_force_pushes": false,
  "allow_deletions": false
}
EOF
```

Expected: same shape of response as Task 2 Step 1.

- [ ] **Step 2: Enable required commit signatures**

```bash
gh api -X POST /repos/cssllcio/vibrai-releases/branches/main/protection/required_signatures
```

Expected: `{"url":"...","enabled":true}`

- [ ] **Step 3: Verify**

```bash
gh api /repos/cssllcio/vibrai-releases/branches/main/protection --jq '{enforce_admins: .enforce_admins.enabled, linear_history: .required_linear_history.enabled, force_pushes: .allow_force_pushes.enabled, deletions: .allow_deletions.enabled}'
gh api /repos/cssllcio/vibrai-releases/branches/main/protection/required_signatures --jq .enabled
```

Expected: same values as Task 2 Step 3 (`false`/`true`/`false`/`false`, then `true`).

---

### Task 4: Branch protection on `typeclip`

**Files:** none (GitHub repo settings)

**Interfaces:**
- Consumes: working commit signing from Task 1.
- Produces: `main` on `cssllcio/typeclip` protected identically to Tasks 2–3.

- [ ] **Step 1: Confirm with the user, then apply base branch protection**

```bash
gh api -X PUT /repos/cssllcio/typeclip/branches/main/protection \
  --input - <<'EOF'
{
  "required_status_checks": null,
  "enforce_admins": false,
  "required_pull_request_reviews": null,
  "restrictions": null,
  "required_linear_history": true,
  "allow_force_pushes": false,
  "allow_deletions": false
}
EOF
```

Expected: same shape of response as Task 2 Step 1.

- [ ] **Step 2: Enable required commit signatures**

```bash
gh api -X POST /repos/cssllcio/typeclip/branches/main/protection/required_signatures
```

Expected: `{"url":"...","enabled":true}`

- [ ] **Step 3: Verify**

```bash
gh api /repos/cssllcio/typeclip/branches/main/protection --jq '{enforce_admins: .enforce_admins.enabled, linear_history: .required_linear_history.enabled, force_pushes: .allow_force_pushes.enabled, deletions: .allow_deletions.enabled}'
gh api /repos/cssllcio/typeclip/branches/main/protection/required_signatures --jq .enabled
```

Expected: same values as Task 2 Step 3.

---

### Task 5: CI lint workflow + license comment + README note (via PR)

**Files:**
- Create: `.github/workflows/lint.yml`
- Modify: `Formula/vibrai.rb` (add comment above line 5)
- Modify: `README.md` (append provenance section)

**Interfaces:**
- Consumes: protected, signing-required `main` on `homebrew-tap` from Task 2 — this task's commits must be signed (already default from Task 1) and merged via squash (no merge commits, per `required_linear_history`).
- Produces: a passing `audit` status check on `homebrew-tap`, whose context name (`audit`) Task 6 references when making it a required check.

- [ ] **Step 1: Branch from main**

```bash
git checkout main
git pull origin main
git checkout -b hardening/ci-lint-and-docs
```

- [ ] **Step 2: Add the CI workflow**

Create `.github/workflows/lint.yml`:

```yaml
name: Lint Formulas

on:
  push:
    branches: [main]
  pull_request:

jobs:
  audit:
    name: audit
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - uses: Homebrew/actions/setup-homebrew@master
      - run: brew audit --strict Formula/*.rb
      - run: brew style Formula/
```

- [ ] **Step 3: Add the license clarification comment**

In `Formula/vibrai.rb`, change:

```ruby
  license :cannot_represent
```

to:

```ruby
  # Proprietary, all rights reserved — Homebrew has no SPDX id for this,
  # :cannot_represent is the documented correct value, not a placeholder.
  license :cannot_represent
```

- [ ] **Step 4: Add the README provenance section**

Append to `README.md`:

```markdown

## About this tap

This is an unofficial tap maintained by CSSLLC — it is not audited or
endorsed by Homebrew. Every formula pins an exact version and `sha256`;
before upgrading, you can verify that hash against the corresponding
GitHub release for that formula's source repo.
```

- [ ] **Step 5: Commit**

```bash
git add .github/workflows/lint.yml Formula/vibrai.rb README.md
git commit -m "Add CI lint workflow, clarify Vibrai license, add tap provenance note"
```

Expect the commit to be signed automatically (from Task 1); spot-check with `git log --show-signature -1`.

- [ ] **Step 6: Push and open the PR**

```bash
git push -u origin hardening/ci-lint-and-docs
gh pr create --title "Add CI linting and tap provenance docs" --body "Adds brew audit/style CI, clarifies the Vibrai license field, and documents this tap's provenance for users."
```

Expected: PR URL printed; no push rejection (confirms Task 2's protection allows the owner's direct branch push + signed commit).

- [ ] **Step 7: Wait for the CI check and confirm it passes**

```bash
gh pr checks --watch
```

Expected: a check named `audit` (or `Lint Formulas / audit`) completes with a passing status. If it fails, read the `brew audit`/`brew style` output, fix `Formula/vibrai.rb` or `Formula/typeclip.rb` accordingly, commit, push, and re-run this step until it passes.

- [ ] **Step 8: Merge**

```bash
gh pr merge --squash --delete-branch
```

Expected: PR merged into `main`; local branch and remote branch both deleted.

- [ ] **Step 9: Sync local main**

```bash
git checkout main
git pull origin main
```

---

### Task 6: Require the CI check on `homebrew-tap`

**Files:** none (GitHub repo settings)

**Interfaces:**
- Consumes: the `audit` check context that ran at least once in Task 5 Step 7 (GitHub only allows requiring a check that has already reported at least one run on the repo).
- Produces: `main` on `homebrew-tap` now also blocks merges when `audit` is failing or hasn't run, completing the full protection design from the spec.

- [ ] **Step 1: Confirm with the user, then add the required status check**

```bash
gh api -X PATCH /repos/cssllcio/homebrew-tap/branches/main/protection/required_status_checks \
  --input - <<'EOF'
{
  "strict": true,
  "checks": [{"context": "audit"}]
}
EOF
```

Expected: JSON response with `"contexts": ["audit"]` and `"checks": [{"context":"audit","app_id":null}]`.

- [ ] **Step 2: Verify**

```bash
gh api /repos/cssllcio/homebrew-tap/branches/main/protection/required_status_checks --jq '{strict, checks}'
```

Expected: `strict: true`, `checks` containing an entry with `"context": "audit"`.

- [ ] **Step 3: End-to-end confirmation (optional but recommended)**

Open a throwaway PR that intentionally breaks `brew style` (e.g. a stray trailing whitespace in `Formula/typeclip.rb`), confirm `gh pr view --json mergeable,statusCheckRollup` shows the merge blocked while `audit` is failing, then close the PR without merging (or fix and merge if you'd rather keep the fix).

```bash
git checkout -b throwaway/verify-required-check
printf '  \n' >> Formula/typeclip.rb
git commit -am "test: verify required status check blocks merge"
git push -u origin throwaway/verify-required-check
gh pr create --title "DO NOT MERGE: verify required check" --body "Temporary PR to confirm the required audit check blocks merge."
gh pr checks --watch
gh pr view --json mergeable,statusCheckRollup
gh pr close --delete-branch
```

Expected: `mergeable` reports blocked/`CONFLICTING` or the rollup shows `audit` as `FAILURE`, and the PR UI shows the merge button disabled until checks pass — confirming Task 6 Step 1 is actually enforced.

---

## Self-Review Notes

- **Spec coverage:** §1 commit signing → Task 1; §2 branch protection (3 repos) → Tasks 2–4; §3 CI workflow → Task 5; §4 license comment → Task 5 Step 3; §5 README note → Task 5 Step 4; required-check wiring from §3 → Task 6. All five spec sections have a task.
- **Sequencing matches spec:** signing before protection (Task 1 before 2–4); protection before the PR that exercises it (Tasks 2–4 before 5); CI existing before it can be required (5 before 6).
- **Type/name consistency:** the workflow job is named `audit` (both the job id and the `name:` field) in Task 5 Step 2, and Task 6 references that exact context string `"audit"` — verified matching.
- **No placeholders:** every `gh api` call has a literal JSON body and an expected literal response shape; every file edit shows exact before/after content.
