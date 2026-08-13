#!/usr/bin/env bash
set -euo pipefail

# Base config comes from env/prod.env (edit that file to configure).
# Optional per-build overrides via shell env / extra args:
#   TENANT_SLUG=foo ./scripts/build-prod-android.sh
#   ./scripts/build-prod-android.sh --dart-define=API_BASE_URL=...
# A --dart-define passed on the command line takes precedence over the file.

DEFINES=(--dart-define-from-file=env/prod.env)
if [[ -n "${TENANT_SLUG:-}" ]]; then DEFINES+=(--dart-define=TENANT_SLUG="$TENANT_SLUG"); fi
if [[ -n "${API_BASE_URL:-}" ]]; then DEFINES+=(--dart-define=API_BASE_URL="$API_BASE_URL"); fi
if [[ -n "${PORTAL_BASE_URL:-}" ]]; then DEFINES+=(--dart-define=PORTAL_BASE_URL="$PORTAL_BASE_URL"); fi
if [[ -n "${ONESIGNAL_APP_ID:-}" ]]; then DEFINES+=(--dart-define=ONESIGNAL_APP_ID="$ONESIGNAL_APP_ID"); fi

flutter build appbundle \
  --flavor prod \
  "${DEFINES[@]}" \
  "$@"
