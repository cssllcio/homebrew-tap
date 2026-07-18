# Homebrew Tap Hardening — Design

Date: 2026-07-18
Repo: `cssllcio/homebrew-tap` (tap name `cssllcio/tap`)

## Goal

Homebrew has no central "trusted tap" registry or approval process — third-party
taps are always flagged as unaudited. This project makes `cssllcio/homebrew-tap`
verifiably safe for third-party use anyway: automated linting, protected commit
history, accurate license metadata, and clear provenance guidance for users —
without breaking the solo-maintainer workflow.

## Scope

1. Commit signing (prerequisite for branch protection)
2. Branch protection on `homebrew-tap`, `vibrai-releases`, `typeclip`
3. CI linting workflow on `homebrew-tap` (`brew audit --strict`, `brew style`)
4. License field documentation in `vibrai.rb`
5. README provenance note

Out of scope: code signing/notarization of the release binaries themselves
(Gatekeeper trust), getting the tap listed in any official Homebrew directory
(no such mechanism exists for third-party taps).

## Context

- Sole maintainer, no other collaborators on any of the three repos.
- No commit signing configured locally (`commit.gpgsign` / `gpg.format` unset,
  no `user.signingkey`) and none of the three repos require it yet.
- An SSH key already exists at `~/.ssh/id_ed25519.pub` and can be reused as an
  SSH-based commit-signing key rather than generating a new GPG key.
- `gh` is authenticated as `gitizenme` with `gist, project, read:org, repo,
  workflow` scopes; managing signing keys needs an additional
  `admin:ssh_signing_key` scope (requires `gh auth refresh`) and branch
  protection needs the existing `repo` scope (already sufficient).
- All three repos (`homebrew-tap`, `vibrai-releases`, `typeclip`) are public
  with default branch `main`.
- `vibrai.rb` currently sets `license :cannot_represent`. This has been
  confirmed correct — Vibrai is proprietary/all-rights-reserved and Homebrew
  has no SPDX identifier for plain proprietary software — so the fix is a
  documenting comment, not a license change.

## Design

### 1. Commit signing (prerequisite)

Must land before any repo requires signed commits, or pushes get rejected
immediately after enabling the requirement.

- `git config --global gpg.format ssh`
- `git config --global user.signingkey ~/.ssh/id_ed25519.pub`
- `git config --global commit.gpgsign true`
- Upload `~/.ssh/id_ed25519.pub` to GitHub as a **signing key** (distinct from
  an auth/deploy key) via `gh api user/ssh_signing_keys` — requires
  `gh auth refresh -h github.com -s admin:ssh_signing_key` first. Confirm with
  the user before requesting the elevated scope and before the upload, since
  both touch their GitHub account.
- Verify with a signed test commit (`git commit -S` or rely on
  `commit.gpgsign true`) and `git log --show-signature` before moving on.

### 2. Branch protection (all three repos)

Applied identically to `main` on `homebrew-tap`, `vibrai-releases`, and
`typeclip`, via the classic branch-protection API
(`gh api /repos/{owner}/{repo}/branches/main/protection`, plus its
`required_signatures` sub-resource) — not the newer repository-rulesets API,
because the classic API has an explicit `enforce_admins: false` field that
cleanly expresses "owner bypasses," rather than needing to guess numeric
ruleset bypass-actor role IDs for a personal (non-org) repo:

- Require signed commits (`required_signatures`)
- Require linear history
- Block force-pushes
- Block branch deletion
- Solo maintainer → `enforce_admins: false` and no
  `required_pull_request_reviews` (that would need a second approving
  account); this is what lets the repo owner keep merging without a second
  approver
- `homebrew-tap` additionally requires the new CI status check (§3) to pass
  before merge — added via a follow-up call once the check has run at least
  once (GitHub will not let a never-run check be marked required)

Each repo's protection update is applied as its own confirmed `gh api` call —
these are account-level settings changes and each one is confirmed with the
user before running, per the earlier discussion.

### 3. CI linting workflow (`homebrew-tap` only)

New `.github/workflows/lint.yml`:

```yaml
on: [push, pull_request]
jobs:
  audit:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - uses: Homebrew/actions/setup-homebrew@master
      - run: brew audit --strict Formula/*.rb
      - run: brew style Formula/
```

(Superseded during execution — `brew audit`/`brew style` reject bare path
arguments on current Homebrew; the shipped workflow resolves the checkout as
a registered tap by name instead, keeping the job/check name `audit`. See
`docs/superpowers/plans/2026-07-18-tap-hardening.md` Task 5 and
`.superpowers/sdd/progress.md` for the actual YAML and why.)

This job's check name becomes the required status check added to
`homebrew-tap`'s branch protection in §2. Landed via a PR (rather than a direct push to
`main`) so the new branch protection + CI combination is exercised end-to-end
before being relied on.

### 4. License field documentation

In `Formula/vibrai.rb`, add a one-line comment directly above
`license :cannot_represent` explaining it's intentional — proprietary software
with no OSS license — so it doesn't read as an unfinished field to a future
maintainer or contributor.

### 5. README provenance note

Add a short section to `README.md`:

- States this is an unofficial, CSSLLC-maintained tap, not audited by
  Homebrew.
- Notes that each formula pins an exact version + `sha256`, and recommends
  users diff that hash against the linked GitHub release before trusting an
  upgrade.

## Sequencing

1. Commit signing setup (local + GitHub signing key upload)
2. Branch protection on all three repos (now safe since signing works)
3. CI workflow + license comment + README note, landed together as one PR to
   `homebrew-tap` (exercises the new required-check + signed-commit rules)

## Testing / Verification

- After §1: a signed commit shows "Verified" on GitHub.
- After §2: attempt (and expect rejection of) an unsigned or force-push to
  confirm rules are active; confirm the user (as owner) can still merge
  without a second approver.
- After §3: open the PR, confirm the `audit` check runs and passes (or
  intentionally fails on a bad formula edit, then fix, to prove it's wired to
  the merge requirement), then merge.
