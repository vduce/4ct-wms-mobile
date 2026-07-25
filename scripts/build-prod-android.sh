#!/usr/bin/env bash
set -euo pipefail

flutter build appbundle \
  --flavor prod \
  --dart-define=FLAVOR=prod \
  --dart-define=TENANT_SLUG="${TENANT_SLUG:-mial}" \
  --dart-define=API_BASE_URL="${API_BASE_URL:-https://api.wms-prod.smartdigibuild.net/api/v1}" \
  --dart-define=PORTAL_BASE_URL="${PORTAL_BASE_URL:-https://mial.smartdigibuild.net}" \
  "$@"
