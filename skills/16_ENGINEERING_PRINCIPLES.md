# 16 — Engineering principles

**Purpose:** State durable rules supported by repository evidence.

**Confidence note:** Verified against the supplied instructions and guidelines on 2026-11-21. Product implementation is absent; code wins (see this document).

## Principles

1. **Trace a change across the API and every client.** The API is described as the shared path between Supabase and web/Android clients; a partial contract update can leave one client broken (01, 04).
2. **Treat privacy statements as requirements until implementation is verified.** The business-logic template names protections but supplies no controls; claiming them as delivered can mislead users and reviewers (07, 09, 15).
3. **Promote and deploy the exact candidate that passed its gate.** The release guideline separates QA, integration testing, and production approval; substituting another build invalidates that evidence (10, 11).
4. **Keep evidence and confidence beside each rule.** The implementation and history are currently unavailable; unsupported certainty would teach false behavior (00, 05, 06).

trust the code over any document, including this one
