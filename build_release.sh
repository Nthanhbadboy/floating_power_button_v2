#!/usr/bin/env bash
# Lean release build. Debug APKs (flutter run / build apk --debug) are ~80+ MB;
# a release build is only a few MB per ABI.
#
# Usage:
#   ./build_release.sh                      # real Petal Ads banner (slot i3kcblwkv6)
#   PETAL_USE_TEST_ADS=true ./build_release.sh   # release build that shows Huawei TEST ads
set -euo pipefail
cd "$(dirname "$0")"

ARGS=(--release --split-per-abi --obfuscate --split-debug-info=build/symbols)
[ "${PETAL_USE_TEST_ADS:-}" = "true" ] && ARGS+=(--dart-define=PETAL_USE_TEST_ADS=true)

flutter build apk "${ARGS[@]}"
ls -lh build/app/outputs/flutter-apk/*-release.apk
