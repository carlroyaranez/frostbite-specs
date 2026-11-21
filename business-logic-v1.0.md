# Business Logic

> Development of a Web and Android College Organization Membership and Fee Management System using Laravel for Student Councils.

- **Allowed platforms:** Web and Android
- **Primary users:** Student councils, organization officers, and college students
- **Technology:** Laravel backend/API, web frontend, and Android application. The frontend and Android frameworks, database engine, hosting provider, and payment integrations remain design decisions.

## Project Details

- **Company/Startup/Team Name:** ColdRes
- **Project Code Name:** frostbite
- **Project Short Code:** FB
- **Short Description:** A web and Android system for student councils to manage organization membership, member records, fee assessments, payment records, and basic reports.
- **Long Description:** The system gives authorized student council and organization officers a shared place to publish membership information, review applications, maintain member rosters, assess organization fees, record payments, and produce summaries for reconciliation. Students can use the web frontend or Android application to view membership status, applicable fees, and payment history, and to submit or renew applications. The web frontend supports administrative workflows; Android provides student-facing access and any officer functions explicitly granted by role. Both clients use the Laravel backend/API and enforce the same server-side access rules. The system supports accountable fee handling through role-based access and an auditable record of administrative changes. Payment processing is not assumed; the initial design supports recording payments received through approved channels.

## User Levels

| User Level | Description |
|---|---|
| A. System Administrator | Manages system-wide configuration, user access, organization setup, and maintenance. Access to fee records is limited to operational need and should be auditable. |
| B. Student Council Administrator | Manages the council's organizations, academic-year settings, officers, membership periods, and fee categories. |
| C. Treasurer | Records and verifies fee payments, issues or records acknowledgments, reconciles collections, and views financial reports for assigned organizations. |
| D. Organization Officer | Reviews membership applications, maintains the assigned organization's roster, and views membership and fee status needed for organization work. |
| E. Student/Member | Submits or renews a membership application, views its status, sees assessed fees, and reviews their own payment history. |

## System Requirements

1. The system shall authenticate users through the web frontend and Android application and enforce role- and organization-scoped access on the Laravel backend/API.
2. The system shall allow authorized administrators to create and maintain organizations, membership periods, and officer assignments.
3. The system shall allow students to submit membership applications and view application status; authorized officers shall be able to review, approve, or reject them with a recorded outcome.
4. The system shall maintain a roster with membership status and relevant academic period, and shall support renewal without silently overwriting prior-period records.
5. The system shall allow authorized users to define fee categories and assess fees for an organization or eligible members, with the reason and applicable period recorded.
6. The system shall let treasurers record payments, including amount, date, channel/reference where available, and the user who recorded or verified the entry. The initial scope does not require online payment processing.
7. The system shall let students view only their own fee assessments and payment history from web and Android; authorized officers shall see only records needed for their assigned organization and role.
8. The system shall provide membership and fee summaries that can be filtered by organization and period and reconciled against payment records.
9. The system shall retain an audit history for sensitive changes to roles, membership decisions, fee assessments, and payment records, including who made the change and when.
10. The system shall provide validation and clear feedback for invalid or incomplete submissions and prevent duplicate payment records where the available reference data permits detection.

## Required Solution Layers

1. **Privacy and security:** Collect only data needed for membership and fee administration. Restrict personal and financial records by role and organization, protect credentials and session access, and avoid exposing member lists or payment history publicly.
2. **Accountability:** Record changes to membership decisions, fee assessments, payments, and access assignments so that council officers can review and reconcile them.
3. **Data lifecycle:** Define retention, archival, and deletion rules with the college before production use. Protect backups and restrict access to exported reports.
4. **Operational integrity:** Treat payment records as financial records; corrections should be traceable rather than silently erasing the original entry.

## MVP Features and Access

| Feature | Access |
|---|---|
| 1. Sign in and role-/organization-scoped access | A, B, C, D, E |
| 2. Organization, period, and officer administration | A, B |
| 3. Membership application and decision workflow | B, D, E |
| 4. Organization roster and membership status | B, D; E can view own status |
| 5. Fee categories and member assessments | B; C; D as view-only where assigned |
| 6. Payment recording, verification, and member history | C; E can view own history |
| 7. Membership and fee summaries/reconciliation reports | A, B, C; D gets organization-scoped summaries |
| 8. Audit history for sensitive actions | A; B and C within authorized scope |

The web frontend is the primary client for council administration and reporting. The Android application provides student membership, fee, and payment-history access; any additional Android officer functions must use the same role permissions and backend authorization as the web frontend.

## Assumptions and decisions to confirm

- The college's approved identity and account provisioning method is not yet specified; Google Sign-In is not assumed.
- The frontend and Android technology stacks, supported Android versions, offline behavior, and client release process are not yet specified.
- The first release records payments made through existing approved channels; online payment gateway integration is out of scope until selected and approved.
- Fee waivers, refunds, installment plans, late penalties, and approval thresholds require council policy decisions before implementation.
- The college must define authoritative student identity, required student data, record retention, and who may access reports.
- Laravel version, database engine, hosting, email/SMS provider, and backup procedures must be selected in the technical design.

## Notes

- This is an initial product design derived from the project title, not a finalized college policy or legal review.
- Confirm role names, fee handling rules, privacy requirements, and approval workflows with the participating student councils before implementation.
