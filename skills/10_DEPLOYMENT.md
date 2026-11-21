# 10 — Deployment

**Purpose:** Follow the declared promotion and versioning policy without assuming product pipelines.

**Confidence note:** Verified against `git-guidelines.md` on 2026-11-21. No CI or deployment configuration is present; code wins (see 16).

## Declared release flow

The guideline defines `main → beta → release → production`. Develop and unit test on `main`; QA/system test on `beta`; publish a release bundle for independent integration tests from `release`; production approval is separate, and deployment must use the exact approved candidate. Carry stabilization fixes upstream through reviewed merges/cherry-picks. The actual branch setup and deployment targets are unverified.

Version form is `<product-prefix>.0X.Y.00Z`; the document assigns `WCN`, `BCN`, `ACN`, and `SCN` prefixes, though names remain generic. Candidate suffixes progress `a`, `b`, `rc`, with numbered retries such as `a2`; tags point to exact release-tested commits. Weekly tag rules and cutoff are specified in `git-guidelines.md`; consult that source before tagging. Never move or reuse a tag.

No build, deploy, rollback, or verification command is available in this checkout. **Miss →** guessing the pipeline can publish an untested artifact or the wrong candidate. See 11 and 14.
