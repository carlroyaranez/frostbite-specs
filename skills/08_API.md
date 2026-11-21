# 08 — API

**Purpose:** Guide API work while the actual contract remains unavailable.

**Confidence note:** Verified only from `frostbite-api/AGENT.md` on 2026-11-21. No routes, validators, or source exist in the checkout; code wins (see 16).

The API repository is described as a back-end web application between Supabase and web/Android clients. Response envelope, route inventory, authentication middleware, authorization rules, error codes, validators, versioning, and local run commands are unknown.

When adding an endpoint, first locate the router, shared response/error helpers, input validation, auth/role checks, persistence layer, and both client call sites. Update all affected consumers and contract documentation together. **Miss →** a client can mis-handle a valid server response or an endpoint can be exposed without the intended authorization. See 04, 07, and 09.
