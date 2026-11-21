# 01 — Architecture

**Purpose:** Establish the verified ecosystem model and boundaries before changing a component.

**Confidence note:** Verified against `frostbite-api/AGENT.md`, `frostbite-web/AGENT.md`, `frostbite-android/AGENT.md`, and `frostbite-specs/AGENT.md` on 2026-11-21. Code wins (see 16).

## Model

Frostbite is described as a web and Android product ecosystem. The API repository is described as the back-end web application communicating between the Supabase database API and web/Android clients. The web repository is described as a front end containing regulatory compliance. The Android repository is the Android application. The specs repository holds ecosystem specifications.

## Ownership and flow

| Component | Verified ownership | Known connection |
|---|---|---|
| `frostbite-api/` | Back-end application | Supabase database API ↔ API ↔ web and Android clients |
| `frostbite-web/` | Web front end; regulatory compliance is mentioned | Exact routes and API contract unknown |
| `frostbite-android/` | Android application | Exact API contract unknown |
| `frostbite-specs/` | Ecosystem specifications | Describes intended behavior; implementation absent |

## Boundaries and decisions

Do not infer that clients access Supabase directly: the API description places the API between database and clients. Confirm actual network paths in source before changing this assumption. No architecture decision record or code-backed tradeoff is available. The supplied `business-logic-v1.0.md` is a template with placeholders, not an approved product specification.

## Debt register

1. **Critical knowledge gap:** no product source, manifests, schemas, tests, deployment configuration, or commit history are present in the product repositories. This prevents safe claims about runtime architecture and failure behavior.
2. **Specification placeholders:** product name, user levels, and requirements in `business-logic-v1.0.md` are largely unfilled; implementations could diverge if treated as requirements.
