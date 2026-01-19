#!/usr/bin/env bash
set -euo pipefail

output_path="build/release_checklist.md"
mkdir -p "$(dirname "${output_path}")"

cat <<'EOF' > "${output_path}"
# Release Checklist

- [ ] All unit and widget tests pass (`flutter test`).
- [ ] Integration suite passes on at least one device target.
- [ ] Coverage updated and badge reflects latest run.
- [ ] Release notes drafted and reviewed.
- [ ] App version and build number bumped.
- [ ] Android signing config verified in CI.
- [ ] iOS code signing and provisioning verified in CI.
- [ ] Fastlane `ios beta` lane completed successfully.
- [ ] Fastlane `android internal` lane completed successfully.
- [ ] Monitoring dashboard reviewed (errors, slow frames, adoption).
- [ ] Crash-free session rate checked for the last beta cohort.
- [ ] Backup/export/import flows spot-checked.
- [ ] Accessibility regression spot-check completed.
EOF

printf "Release checklist generated at %s\n" "${output_path}"
