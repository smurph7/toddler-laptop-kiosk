#!/usr/bin/env bash
set -euo pipefail

KIOSK_USER="${KIOSK_USER:-toddlerkiosk}"
APP_DIR="${APP_DIR:-/opt/toddler-laptop-kiosk}"
SERVICE_NAME="${SERVICE_NAME:-toddler-laptop-kiosk.service}"

STATE_FILE="$APP_DIR/install-state.env"
SERVICE_PATH="/etc/systemd/system/$SERVICE_NAME"
DEFAULT_APP_DIR="/opt/toddler-laptop-kiosk"

require_root() {
	if [ "${EUID:-$(id -u)}" -ne 0 ]; then
		echo "This uninstaller must be run as root. Try: sudo $0"
		exit 1
	fi
}

confirm() {
	local prompt="$1"
	local reply

	read -r -p "$prompt [y/N] " reply
	case "$reply" in
		y|Y|yes|YES) return 0 ;;
		*) return 1 ;;
	esac
}

stop_service() {
	if command -v systemctl >/dev/null 2>&1; then
		echo "Stopping and disabling kiosk service if present."
		systemctl disable --now "$SERVICE_NAME" >/dev/null 2>&1 || true
	fi
}

remove_service() {
	if [ -f "$SERVICE_PATH" ]; then
		echo "Removing systemd service: $SERVICE_PATH"
		rm -f "$SERVICE_PATH"
	fi

	if command -v systemctl >/dev/null 2>&1; then
		systemctl daemon-reload
	fi
}

enable_and_start_unit() {
	local unit_name="$1"

	if systemctl enable --now "$unit_name" >/dev/null 2>&1; then
		return 0
	fi

	if systemctl enable "$unit_name" >/dev/null 2>&1 && systemctl start "$unit_name" >/dev/null 2>&1; then
		return 0
	fi

	return 1
}

restore_display_manager_unit() {
	local preferred_unit="$1"
	local candidate

	if enable_and_start_unit "$preferred_unit"; then
		echo "Started display manager: $preferred_unit"
		return 0
	fi

	for candidate in display-manager.service gdm.service gdm3.service lightdm.service sddm.service; do
		if [ "$candidate" = "$preferred_unit" ]; then
			continue
		fi

		if enable_and_start_unit "$candidate"; then
			echo "Started display manager: $candidate"
			return 0
		fi
	done

	return 1
}

restore_display_manager_if_needed() {
	local display_manager_disabled="0"
	local display_manager_unit="display-manager.service"

	if [ -f "$STATE_FILE" ]; then
		# shellcheck disable=SC1090
		. "$STATE_FILE"
		display_manager_disabled="${DISPLAY_MANAGER_DISABLED:-0}"
		display_manager_unit="${DISPLAY_MANAGER_UNIT:-display-manager.service}"
	fi

	if [ "$display_manager_disabled" = "1" ] && command -v systemctl >/dev/null 2>&1; then
		echo
		if confirm "This installer disabled the display manager. Re-enable and start it now?"; then
			if ! restore_display_manager_unit "$display_manager_unit"; then
				echo "Could not restart the display manager automatically."
				echo "Try one of these, depending on what this laptop uses:"
				echo "  sudo systemctl enable --now gdm.service"
				echo "  sudo systemctl enable --now gdm3.service"
				echo "  sudo systemctl enable --now lightdm.service"
				echo "  sudo systemctl enable --now sddm.service"
			fi
		fi
	fi
}

remove_app_dir() {
	local canonical_app_dir
	local canonical_default_app_dir

	canonical_app_dir="$(realpath -m "$APP_DIR")"
	canonical_default_app_dir="$(realpath -m "$DEFAULT_APP_DIR")"

	if [ "$canonical_app_dir" != "$canonical_default_app_dir" ] && [ "${canonical_app_dir#"$canonical_default_app_dir"/}" = "$canonical_app_dir" ]; then
		echo "Refusing to remove APP_DIR outside $canonical_default_app_dir: $APP_DIR"
		exit 1
	fi

	if [ -d "$canonical_app_dir" ]; then
		echo "Removing app directory: $canonical_app_dir"
		rm -rf "$canonical_app_dir"
	fi
}

remove_kiosk_user_if_requested() {
	if ! id "$KIOSK_USER" >/dev/null 2>&1; then
		return
	fi

	echo
	if confirm "Remove kiosk user '$KIOSK_USER' and its home directory?"; then
		userdel -r "$KIOSK_USER"
	fi
}

main() {
	require_root
	if ! command -v realpath >/dev/null 2>&1; then
		echo "Missing required command: realpath"
		exit 1
	fi

	echo "Toddler Laptop Kiosk uninstaller"
	echo
	echo "User:    $KIOSK_USER"
	echo "App dir: $APP_DIR"
	echo "Service: $SERVICE_NAME"
	echo

	stop_service
	restore_display_manager_if_needed
	remove_service
	remove_app_dir
	remove_kiosk_user_if_requested

	echo
	echo "Kiosk uninstall complete."
}

main "$@"
