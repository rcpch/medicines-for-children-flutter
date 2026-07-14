# Ubiquitous Language

## People And Scope

**Profile**: A local security and data boundary on one device. Importing an encrypted backup creates a new profile.

**Primary carer**: A person who owns and manages a local profile, its children, medicines, schedules, and exports.

**Secondary carer**: A person invited to view and record administrations for a time-bounded shared schedule.

**Child**: The person whose medicines and schedules are being managed. Every medicine, schedule, administration, and share is scoped to one child.

**Active child**: The child currently selected in the primary-carer interface.

## Medicines And Events

**Medicine**: A carer-confirmed record of a medicinal product used by a child. A product lookup result is not a Medicine until the carer confirms and saves it.

**Schedule**: The authoritative local record of when a Medicine is intended to be administered, including its active dates, weekdays, and times.

**Reminder**: An advisory device notification derived from a Schedule. A Reminder is not the Schedule and delivery is not guaranteed.

**Administration**: A recorded dose event with a time and status such as Given or Skipped. Use Administration rather than "dose given data" in code and specifications.

**As-needed administration**: An Administration recorded without a regular scheduled occurrence.

## Product Identification

**Pack code**: A machine-readable EAN/UPC barcode or GS1 DataMatrix on medicine packaging.

**GTIN**: Global Trade Item Number extracted from a Pack code and normalised to canonical GTIN-14 for lookup. Do not call every Pack code a QR code.

**Product lookup result**: Untrusted product and terminology data returned for a GTIN. It carries identifiers, display terms, source, and release dates and requires confirmation.

**dm+d**: NHS Dictionary of Medicines and Devices. Its VTM, VMP, AMP, and AMPP identifiers represent different medicine and pack levels and must not be treated as interchangeable.

**Therapeutic class**: A sourced BNF or ATC classification associated through the dm+d product graph. It must not be inferred from a medicine name.

## Transfer And Sharing

**Schedule transfer**: Offline export and import of one Child's Medicines and Schedules through one or more QR symbols. It is distinct from an encrypted whole-profile Backup and from an online Share.

**Administration history**: Administrations optionally included in a Schedule transfer, either for a selected date range or for all retained history.

**Share**: A time-bounded online view of a Schedule for a Secondary carer. Use Share only for this online collaboration workflow, not for Backup or Schedule transfer.
