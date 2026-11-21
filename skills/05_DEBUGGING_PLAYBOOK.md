# 05 — Debugging playbook

**Purpose:** Give responders reliable diagnostics without fabricating log locations or errors.

**Confidence note:** Verified against the available tree on 2026-11-21. No executable code or runtime configuration is present; code wins (see 16).

## Logs and commands

Log destinations, observability tools, exact error messages, and run commands are unknown. Search source and deployment configuration when available; never assume client-visible errors match server logs. No symptom catalog can be verified from this checkout.

## Initial triage

1. Capture the exact user-visible message, timestamp/time zone, affected component, and a request/correlation identifier if the system provides one. **Miss →** unrelated requests can be mistaken for the failing operation.
2. Determine whether the failure is in the web client, Android client, API, or Supabase boundary using available logs and network traces. **Miss →** a client symptom may lead to a change in the wrong component.
3. Compare the API payload and persisted record against the implementation and schema versions. **Miss →** contract drift can look like intermittent infrastructure failure.
4. Record a reproducible sequence and the exact deployed revision before changing data or retrying a destructive operation. **Miss →** evidence may be lost and duplicate writes may result.

These are diagnostic recommendations, not verified historical incident procedures. Add exact messages, commands, and log paths to this file when observed.
