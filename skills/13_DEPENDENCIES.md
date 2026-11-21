# 13 — Dependencies

**Purpose:** Explain dependency choices and upgrades once manifests are available.

**Confidence note:** No dependency manifest exists in the product checkout as of 2026-11-21. Code wins (see 16).

Languages, frameworks, package managers, pinned versions, licenses, upgrade traps, and deliberate rejections cannot be identified. Do not invent a dependency inventory. When manifests are added, record for each direct dependency its purpose, owning component, version source, known upgrade constraints, and replacement decision if one exists. **Miss →** transitive or coordinated upgrades may break builds or runtime contracts without a traceable owner.
