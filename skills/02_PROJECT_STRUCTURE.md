# 02 — Project structure

**Purpose:** Locate project material and decide where future files belong.

**Confidence note:** Verified against the checkout tree on 2026-11-21. Code wins (see 16).

## Current top level

```text
frostbite-ecosystem/
  frostbite-api/       API component repository
  frostbite-android/   Android component repository
  frostbite-web/       Web component repository
  frostbite-specs/     Specification repository; this skills folder belongs here
  AGENTS.md            Ecosystem instruction pointer (references AGENTS.md patterns)
  business-logic-v1.0.md  Unfilled business-logic template
  git-guidelines.md    Commit and release conventions
  handoff.md           Skills authoring instructions
  sense-making.md      Research workflow instructions
```

Each component currently has only an `AGENT.md` file describing its role. No source tree or naming convention can be verified. Put engineering knowledge in `frostbite-specs/skills/NN_TOPIC.md`; do not invent product source paths. The root `AGENTS.md` points to `*-specs/skills/*.md`, so these notes are discoverable by contributors.
