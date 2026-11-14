#!/bin/bash
set -euo pipefail

ipa_path="${1:-build/ios/ipa/Soengr.ipa}"
shift || true

if [[ ! -f "$ipa_path" ]]; then
  echo "IPA not found: $ipa_path" >&2
  exit 1
fi

audit_dir="$(mktemp -d "${TMPDIR:-/tmp}/songr-release-audit.XXXXXX")"
unzip -q "$ipa_path" -d "$audit_dir"
app_dir="$audit_dir/Payload/Runner.app"

if [[ ! -d "$app_dir" ]]; then
  echo "Expected Payload/Runner.app in $ipa_path" >&2
  exit 1
fi

forbidden_files="$(
  find "$app_dir" -type f \
    \( -name '*.db' -o -name '*.sqlite' -o -name '*.sqlite3' \
       -o -name '.env*' -o -name '*.p12' -o -name '*.cer' \
       -o -name '*.jks' -o -name '*.keystore' \) \
    -print
)"

if [[ -n "$forbidden_files" ]]; then
  echo "Private or stateful files found in the release bundle:" >&2
  echo "$forbidden_files" >&2
  exit 1
fi

bundle_text="$(
  find "$app_dir" -type f -size -50M -print0 \
    | xargs -0 strings -a
)"

default_terms=(
  "musik.simonbystrom.se"
  "demo"
  "192.168.0.252"
)

for term in "${default_terms[@]}" "$@"; do
  if grep -Fq -- "$term" <<<"$bundle_text"; then
    echo "Private release denylist term found: $term" >&2
    exit 1
  fi
done

encryption="$(
  plutil -extract ITSAppUsesNonExemptEncryption raw -o - \
    "$app_dir/Info.plist"
)"
if [[ "$encryption" != "false" ]]; then
  echo "ITSAppUsesNonExemptEncryption must be false." >&2
  exit 1
fi

echo "Release privacy check passed: $ipa_path"
echo "Scanned bundle: $app_dir"
