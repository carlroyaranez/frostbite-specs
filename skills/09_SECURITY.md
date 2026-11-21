# 09 — Security

**Purpose:** Separate stated privacy requirements from verified security controls.

**Confidence note:** The only security evidence is the requirement text in `business-logic-v1.0.md`, reviewed 2026-11-21. Implementation is absent; code wins (see 16).

## Stated requirements, not verified controls

The business-logic template calls for security and privacy by design, Data Privacy Act compliance, location protection, retention limits, no per-user trails, aggregation thresholds, consent for data resale, and Google Sign-In. These are not evidence of implementation or legal compliance. Authentication provider configuration, authorization layers, secrets management, injection surfaces, debug gates, and accepted gaps are unknown.

## Change checklist

For security-sensitive changes, trace identity from Google Sign-In through API authorization to database policy; verify each layer in code/configuration. Check that secrets are referenced by environment/config key only and never copied into docs or logs. Confirm location and retention behavior against actual storage and deletion paths. **Miss →** a client-only gate can be bypassed, sensitive data can persist or leak, and stated privacy goals can be falsely represented as delivered. See 07, 08, and 15.
