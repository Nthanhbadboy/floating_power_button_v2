#!/usr/bin/env bash
# Lean release build. Debug APKs (flutter run / build apk --debug) are ~80+ MB;
# a release build is only a few MB per ABI.
#
# Usage:
#   ADMOB_APP_ID=ca-app-pub-XXXX~YYYY ADMOB_BANNER_ID=ca-app-pub-XXXX/ZZZZ ./build_release.sh
# Without those variables Google's TEST ad ids are used (test ads only, no revenue).
set -euo pipefail
cd "$(dirname "$0")"

ARGS=(--release --split-per-abi --obfuscate --split-debug-info=build/symbols)
[ -n "${ADMOB_BANNER_ID:-}" ] && ARGS+=(--dart-define=ADMOB_BANNER_ID="$ADMOB_BANNER_ID")
# `flutter build` has no -P passthrough; Gradle reads this env var as property ADMOB_APP_ID.
[ -n "${ADMOB_APP_ID:-}" ]    && export ORG_GRADLE_PROJECT_ADMOB_APP_ID="$ADMOB_APP_ID"

flutter build apk "${ARGS[@]}"
ls -lh build/app/outputs/flutter-apk/*-release.apk
