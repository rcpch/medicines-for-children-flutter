# Monitoring Dashboards

Use the telemetry events emitted by the app to build release readiness dashboards.

Recommended panels:
- Crash-free sessions and crash count by version.
- Slow frame count (event: `slow_frame_detected`) by device model.
- Auth funnel: `login_success` and `signup_completed`.
- Share centre actions: `share_centre_created`, `share_centre_updated`, `share_centre_ended`.
- Secondary carer actions: `shared_schedule_confirmed`, `shared_schedule_declined`, `shared_schedule_administration_recorded`.
- Update prompts: `app_update_required` and `app_update_available`.

Alerting suggestions:
- Crash-free sessions < 99.5% in the last 24 hours.
- Spike in `app_error` events after a release.
- Elevated slow frames per session for a specific OS version.
