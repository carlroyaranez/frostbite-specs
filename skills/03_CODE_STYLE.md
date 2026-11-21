# 03 — Code style

**Purpose:** Record verified contributor conventions and avoid imposing unsupported coding rules.

**Confidence note:** Verified against `git-guidelines.md` and repository instructions on 2026-11-21. Product code is absent; code wins (see 16).

## Verified conventions

- Commit subject format: `<scope>: Imperative summary`; sentence case, 50 characters or fewer, no final period. This matters because the repository's declared commit convention depends on readable, scoped summaries.
- Prefer product/feature scopes such as `code-name-api/auth:` and `code-name-specs/design:` where applicable. The actual product/code name is still a placeholder in `git-guidelines.md`; confirm it before using these examples literally.
- Explain why in the optional commit body, wrap at 72 characters, and use human-readable issue references.
- AI agents must not be credited as commit, tag, release, or PR authors.

No formatter, linter, language, logging style, error-handling convention, or code pattern is verifiable without source/manifests. Do not turn guesses into rules; add a verified entry when implementation appears.
