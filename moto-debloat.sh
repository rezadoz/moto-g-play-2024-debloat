#!/usr/bin/env bash
# Moto G Play 2024 (fogona) debloat script — REVERSIBLE
#
# Uses `pm disable-user` instead of uninstall. This is non-destructive:
# the app stays installed but stops running/showing up. Undo any single
# package with:
#   adb shell pm enable --user 0 <package>
#
# Usage:
#   chmod +x moto-debloat.sh
#   ./moto-debloat.sh            # disables the list below
#   ./moto-debloat.sh --dry-run  # just shows what's present, changes nothing

set -euo pipefail

DRY_RUN=false
if [[ "${1:-}" == "--dry-run" ]]; then
  DRY_RUN=true
fi

# Confirmed safe to disable — Motorola-added system apps with no
# functional loss for normal phone/SMS/data use. com.motorola.ccc.ota
# in particular is well-documented as safe to disable (it only nags
# about OS updates, which won't apply cleanly on an unlocked bootloader
# anyway).
PACKAGES=(
  com.motorola.ccc.ota          # Motorola Update Services / OTA nag
  com.motorola.demo              # retail demo mode
  com.motorola.entitlement        # carrier entitlement checks
  com.motorola.motocare            # Moto "support" app
  com.motorola.genie.geniewidget    # weather/news widget
  com.motorola.metrics               # telemetry/analytics
  com.facebook.appmanager             # Meta background services (not the FB app)
  com.facebook.services
  com.facebook.system
)

# Present but worth a second look before disabling — comment out any
# you want to skip. These won't break the phone if disabled, but you
# may lose a feature you actually use.
OPTIONAL_PACKAGES=(
  com.motorola.fmradio      # FM radio, if you never use it
  com.motorola.timer          # redundant clock/timer app
  # com.motorola.actions          # Moto Actions gestures (chop for flashlight, etc.)
)

adb get-state >/dev/null 2>&1 || { echo "No device connected via adb. Aborting."; exit 1; }

echo "Checking installed packages on device..."
INSTALLED=$(adb shell pm list packages)

process_list() {
  local label="$1"; shift
  local pkgs=("$@")
  echo ""
  echo "== $label =="
  for pkg in "${pkgs[@]}"; do
    if echo "$INSTALLED" | grep -q "package:$pkg$"; then
      if $DRY_RUN; then
        echo "  [present]  $pkg"
      else
        echo "  disabling: $pkg"
        adb shell pm disable-user --user 0 "$pkg" || echo "    (failed — may already be disabled or not removable on this build)"
      fi
    else
      echo "  [not found] $pkg (skipping — not on this device/build)"
    fi
  done
}

process_list "Confirmed safe" "${PACKAGES[@]}"
process_list "Optional (review before running for real)" "${OPTIONAL_PACKAGES[@]}"

echo ""
if $DRY_RUN; then
  echo "Dry run complete — nothing was changed."
else
  echo "Done. Reboot and confirm calls/SMS/data still work fine."
  echo "To undo any package: adb shell pm enable --user 0 <package>"
fi
