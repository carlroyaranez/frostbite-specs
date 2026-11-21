# 15 — Known limitations

**Purpose:** Make knowledge gaps visible so plans do not mistake assumptions for product behavior.

**Confidence note:** Verified against all four component checkouts and supplied specifications on 2026-11-21. Code wins (see 16).

## Ranked by likelihood of surprise

1. **No implementation available:** API, web, and Android repositories contain only a brief `AGENT.md` description. Runtime behavior, setup, and tests cannot be verified.
2. **No history available:** product repositories have no commits, so fixes, reverts, and incident causes cannot be reconstructed.
3. **Incomplete requirements:** `business-logic-v1.0.md` contains placeholders for project identity, user roles, and most system requirements. Do not treat placeholders as accepted scope.
4. **Privacy goals unverified:** privacy and security statements are requirements only; implementation and legal review are not evidenced.
5. **Release conventions unvalidated:** `git-guidelines.md` specifies a promotion and tagging process, but no CI or deployment config confirms it.

## Redesign candidates

Prioritize establishing implementation and test evidence, then completing and approving product requirements. No architecture redesign can be justified without source and operational evidence.
