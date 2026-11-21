# 11 — Testing

**Purpose:** Explain the declared confidence gates and identify what cannot yet be assessed.

**Confidence note:** Verified against `git-guidelines.md` on 2026-11-21. No test files or tooling are present; code wins (see 16).

## Declared gates

The release guideline assigns unit testing to developers on `main`, system testing to QA on `beta`, and integration testing of published bundles to independent testers on `release`. Production approval is a separate decision. These responsibilities are process guidance; no evidence confirms the gates or coverage are implemented.

No test framework, commands, coverage, mocks, fixtures, or manual drills can be reported. When code is present, document runnable commands and test client/API/schema contract boundaries together. Include authorization and failure cases where applicable. **Miss →** isolated unit success can conceal a broken cross-component contract. See 04 and 10.
