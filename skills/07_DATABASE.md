# 07 — Database

**Purpose:** Prevent unsafe assumptions about identity, constraints, and data changes.

**Confidence note:** `frostbite-api/AGENT.md` names the Supabase database API, but no schema or migration is present as of 2026-11-21. Code wins (see 16).

## Verified and unknown

The API is described as communicating with the Supabase database API. Table names, primary keys, foreign keys, row-level security policies, indexes, delete behavior, migration tooling, backup policy, and retention rules are unknown. `business-logic-v1.0.md` states privacy goals (including location protection and retention limits) as a required solution layer, but supplies no implemented controls.

## Change checklist

Before a data change, inspect the live schema definition, migration history, API queries, and authorization policies. Write down invariants and rollback behavior before applying destructive migrations. **Miss →** a schema change may orphan records, expose rows, or make deployed API code incompatible. Never claim a privacy or retention guarantee from the placeholder requirements alone; see 09 and 15.
