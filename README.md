# moto-debloat.sh

Reversibly disables known Motorola/Meta bloatware on the Moto G Play 2024
(fogona) via adb. Written for stock RETUS firmware but should work on
most modern Motorola devices.

## Requirements

- `adb` installed and on your PATH
- USB debugging enabled on the phone, connected and authorized

## Usage

```
chmod +x moto-debloat.sh

# See what's present on your device without changing anything
./moto-debloat.sh --dry-run

# Disable the confirmed-safe list (and optional list, if left uncommented)
./moto-debloat.sh
```

## How it works

Uses `pm disable-user --user 0 <package>` instead of uninstalling.
The app stays on disk but stops running and disappears from the app
drawer. Nothing is deleted, so it's safe to experiment with.

To restore a package:

```
adb shell pm enable --user 0 <package>
```

## Package lists

- **Confirmed safe** — Motorola system apps and Meta background
  services with no functional loss for normal calls/SMS/data use.
- **Optional** — present but worth a second look (FM radio, Moto
  Actions gestures, etc.). Comment out any you want to keep before
  running for real.

Packages not found on your specific build are skipped automatically.

## After running

Reboot the phone and confirm calls, SMS, and mobile data still work
before doing anything else. If something breaks, re-enable the
suspect package and reboot again.
