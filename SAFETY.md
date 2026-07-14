# Clinical Safety

Medicines for Children is an offline-first record and reminder application for carers. It stores carer-entered details about children, medicines, schedules, and administrations; produces exports; and can share a time-bounded schedule. It does not prescribe, recommend a dose, verify that a medicine is suitable, or replace the medicine label, prescription, pharmacist, clinician, or emergency advice.

## Intended Use

- Intended users: parents, guardians, and other carers managing a child's medicines.
- Intended environment: personal mobile devices, with optional web and desktop access during development and evaluation.
- Current status: pre-alpha evaluation software. It is not approved for unsupervised clinical deployment.
- Clinical safety owner: to be appointed by the project before pilot or production use.

## Safety Position

The app must preserve the distinction between a recorded schedule and an advisory reminder. All scanned, imported, shared, and restored information is untrusted until validated and confirmed against the medicine packaging or current instructions. No terminology lookup or product match may silently create or change a medicine or dose.

Known hazards and planned controls are tracked in [clinical-safety/HAZARD-LOG.md](clinical-safety/HAZARD-LOG.md). Risk ratings, acceptance decisions, and clinical sign-off remain pending appointment of the responsible clinical safety role.

## Release Gate

Before a pilot or production release:

- A named clinical safety owner must review the hazard log and assign initial and residual risks.
- Safety-relevant changes must link to a hazard and test or human verification evidence.
- Critical workflows must be tested with offline operation, wrong-child prevention, malformed imports, notification denial/failure, timezone changes, and realistic long data.
- Security or privacy findings that can affect care must be represented in the safety evidence.

## Reporting

Report vulnerabilities privately as described in [SECURITY.md](SECURITY.md). Do not put real child or carer data in an issue, test fixture, screenshot, or safety document.
