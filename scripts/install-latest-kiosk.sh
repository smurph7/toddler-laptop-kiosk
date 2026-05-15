#!/usr/bin/env bash
set -euo pipefail

RELEASE_URL="${RELEASE_URL:-https://github.com/smurph7/toddler-laptop-kiosk/releases/latest/download/toddler-laptop-kiosk.x86_64}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALLER="$SCRIPT_DIR/install-kiosk.sh"

require_command() {
	if ! command -v "$1" >/dev/null 2>&1; then
		echo "Missing required command: $1"
		echo "Install the Debian package that provides it, then run this script again."
		exit 1
	fi
}

require_command mktemp
require_command wget
require_command sha256sum
require_command cut
require_command sudo

temp_file="$(mktemp)"
cleanup() {
	rm -f "$temp_file"
}
trap cleanup EXIT

echo "Downloading release to calculate SHA-256:"
echo "$RELEASE_URL"
wget -O "$temp_file" "$RELEASE_URL"

release_sha256="$(sha256sum "$temp_file" | cut -d' ' -f1)"

echo
echo "Calculated SHA-256:"
echo "$release_sha256"
echo
echo "Running kiosk installer with this checksum."

sudo env \
	RELEASE_URL="$RELEASE_URL" \
	RELEASE_SHA256="$release_sha256" \
	KIOSK_USER="${KIOSK_USER:-toddlerkiosk}" \
	APP_DIR="${APP_DIR:-/opt/toddler-laptop-kiosk}" \
	SERVICE_NAME="${SERVICE_NAME:-toddler-laptop-kiosk.service}" \
	KIOSK_LOCKDOWN_KEYS="${KIOSK_LOCKDOWN_KEYS:-ask}" \
	"$INSTALLER"
