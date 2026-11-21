# Business Logic v1.1 — Proposed

**Status:** Proposal for review; not an approved policy or implementation specification.

> A web and Android membership and fee management system for college student councils, built around a shared Laravel backend/API.

- **Allowed platforms:** Web and Android
- **Team:** ColdRes
- **Project code name:** frostbite
- **Short code:** FB
- **Technology:** Laravel backend/API; web frontend; Android application. Frontend and Android frameworks, database, hosting, and identity provider remain to be selected.
- **Primary users:** Student council administrators, organization officers/treasurers, and college students.

## Product positioning

Student councils often need to coordinate organization rosters, membership decisions, and fee records across separate lists and manual processes. Frostbite gives councils one role-controlled system to manage those records and gives students a simple way to apply, check membership status, and see what fees have been recorded for them.

**Value proposition:** Keep membership records current, make fee collection easier to reconcile, and give students visibility into their own status—through web administration and an Android student experience backed by the same API.

**Initial audience:** One participating college and its student councils/organizations. Multi-campus or institution-wide rollout is not assumed for the MVP.

## Project details

- **Short description:** Manage organization membership and manually recorded fees in one shared system, with council tools on the web and student self-service on web and Android.
- **Long description:** Authorized council users configure organizations and membership periods, review applications, maintain rosters, assess fees, and record payments received through approved channels. Students submit or renew applications and view their own membership and fee status. The Laravel backend is the source of truth for permissions and records; web and Android clients use the same API. MVP reporting focuses on operational rosters and fee reconciliation.

## Users and access

| Role | Main responsibilities | Scope |
|---|---|---|
| System administrator | Set up system access and maintain the service | System-wide; sensitive financial access only when needed and audited |
| Council administrator | Configure organizations, membership periods, and officer assignments | Assigned council |
| Treasurer | Record and correct payment entries; review reconciliation summaries | Assigned organization(s) |
| Organization officer | Review membership applications and maintain roster | Assigned organization(s) |
| Student/member | Apply or renew; view own membership, assessed fees, and recorded payments | Own account only |

Use the web client for council administration and reporting. The Android MVP is student-facing. Do not add officer workflows to Android unless validated as essential. Enforce authorization in the Laravel API, regardless of client.

## MVP requirements

1. Users can sign in using the college-approved account method; the backend enforces role and organization scope on every protected operation.
2. Council administrators can create organizations, set a membership period, and assign officers.
3. Students can submit or renew a membership application from web or Android and see its current status; assigned officers can approve or reject it and record the decision.
4. Authorized officers can view and maintain a roster for their organization and period. Membership in a new period does not overwrite prior-period history.
5. Council administrators can define a fee name, amount, and applicable organization/period; authorized users can assess it to members and students can view their own assessments.
6. Treasurers can record a payment against an assessment, including amount, date, and payment channel/reference when available. Corrections preserve an audit trail. Online payment processing is not part of the MVP.
7. Students can view their own membership, fee assessments, and recorded payment history on web and Android.
8. Authorized council users can view a roster and a basic fee collection/reconciliation summary filtered by organization and period.
9. The system records who and when for membership decisions, officer/access changes, fee assessments, and payment additions or corrections.

## MVP feature and access matrix

| Feature | System admin | Council admin | Treasurer | Organization officer | Student |
|---|---:|---:|---:|---:|---:|
| Sign in and scoped access | ✓ | ✓ | ✓ | ✓ | ✓ |
| Organization, period, officer setup | ✓ | ✓ | — | — | — |
| Apply/renew membership | — | — | — | — | ✓ |
| Review applications and manage roster | — | ✓ | — | Assigned org | — |
| Define/assess fees | — | ✓ | View | View if assigned | Own records |
| Record/correct payments | — | — | Assigned org | — | — |
| View own membership and fee history | — | — | — | — | ✓ |
| Basic roster and reconciliation summaries | Limited support access | ✓ | ✓ | Roster only | — |
| Review audit history | System/access events | Assigned council | Payment events | Membership events | — |

## Privacy, security, and integrity

- Collect only identity and contact information required to verify membership and administer fees; agree on exact fields with the college before implementation.
- Restrict records by role and organization in the backend, not only by hiding client screens.
- Students can access only their own records. Organization staff see only assigned organizations and information needed for their duties.
- Keep an attributable history of sensitive changes. Do not silently delete or overwrite payment and membership decisions.
- Use encrypted transport, protected credentials/sessions, access-controlled backups, and a college-approved retention and deletion schedule.
- Do not expose member rosters or financial details through public pages or unauthenticated exports.

## MVP boundaries

To ship a focused first release, exclude online payment gateway integration, refunds/waivers/installments/penalties, event management, messaging campaigns, attendance, public organization discovery, advanced analytics, custom report builders, offline synchronization, and multi-college tenancy. Add these only after a validated user need and an agreed policy exist.

## Success measures

Evaluate the pilot using a small set of operational measures: time for officers to process an application; share of active members with a current-period status; share of recorded payments linked to an assessment; and time required to reconcile a period's fee records. Establish baseline and target values with the participating council before the pilot. These measures are for evaluation, not additional product features.

## Decisions required before implementation

1. **Identity:** Which college account or student identifier is authoritative, how accounts are provisioned, and what happens when a student leaves?
2. **Membership policy:** Application fields, approval authority, renewal window, status definitions, and whether students may join multiple organizations.
3. **Fee policy:** Who may set fees, whether fee assessment is mandatory/optional, acceptable payment channels, evidence/reference requirements, and who approves corrections.
4. **Roles:** Whether council administrator and organization officer are distinct roles, and how treasurer duties are assigned and separated.
5. **Privacy and records:** Approved personal data fields, visibility, retention/deletion periods, export rules, and institutional review requirements.
6. **Delivery choices:** Laravel version, client frameworks, supported Android versions, hosting/database, backups, and notification channel. Notifications are not an MVP dependency unless required for application decisions.

## Assumptions and notes

- Payments are made through existing college-approved channels and entered by an authorized treasurer; Frostbite does not move money in the MVP.
- The Android app provides the core student self-service flow and depends on network access; offline writes are excluded.
- The web and Android clients share the Laravel API and authorization rules.
- This document strengthens the initial `business-logic-v1.0.md` design. It is a proposal, not confirmation of college policy, legal compliance, or final technical architecture.
