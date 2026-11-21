# 04 — Change rules

**Purpose:** Track coupled changes whose partial update can break clients or data.

**Confidence note:** Verified against the available repository tree and component descriptions on 2026-11-21. Code wins (see 16).

## Known lockstep sets

No constants, enums, registries, columns, error codes, or mirrored types can be enumerated: implementation files are absent. This is an inventory gap, not evidence that no coupled sets exist.

## Contract boundaries to inspect when source is added

1. API request/response definitions and web/Android consumers. **Miss →** incompatible payload changes may break one client while another continues to work.
2. API persistence behavior and Supabase schema/migrations. **Miss →** deployed code may query missing columns or violate data constraints.
3. Authentication/authorization rules and each client route or screen. **Miss →** a UI change can expose an operation that the server does not authorize correctly.

Before changing any of these, locate the real definitions and all consumers with repository search, then list concrete paths here. No retest command can be named yet because test/build tooling is absent. See 08, 09, and 11.
