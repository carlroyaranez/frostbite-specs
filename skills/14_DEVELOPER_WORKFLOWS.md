# 14 — Developer workflows

**Purpose:** Provide reproducible setup and change recipes based on verified project tooling.

**Confidence note:** Verified against the checkout and `git-guidelines.md` on 2026-11-21. Build and setup files are absent; code wins (see 16).

## Setup

No prerequisites, environment keys, install commands, or local run commands can be verified. Inspect each product's manifest and deployment config when available. Never put secret values in these documents.

## Recipe: propose a product change

1. Identify the owning component from 01 and the relevant requirements/spec.
2. Search for all API/client/schema consumers and list the paths; see 04, 07, and 08.
3. Follow the component's own setup and test instructions once manifests exist; do not guess commands.
4. Use the scoped imperative commit format in `git-guidelines.md`; see 03.
5. For release work, follow its promotion gate and exact-candidate rules; see 10 and 11.
6. Add what surprised you to `INBOX.md`.

## Recipe: refresh these notes

Compare code/history since the confidence note, process inbox entries with evidence, preserve direct edits and credit, retire stale claims rather than deleting silently, append without renumbering, and update 00_INDEX. Add what surprised you to `INBOX.md`.
