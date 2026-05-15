#!/usr/bin/env bash
set -euo pipefail

KIOSK_USER="${KIOSK_USER:-toddlerkiosk}"
APP_DIR="${APP_DIR:-/opt/toddler-laptop-kiosk}"
SERVICE_NAME="${SERVICE_NAME:-toddler-laptop-kiosk.service}"
RELEASE_URL="${RELEASE_URL:-https://github.com/smurph7/toddler-laptop-kiosk/releases/latest/download/toddler-laptop-kiosk.x86_64}"
RELEASE_SHA256="${RELEASE_SHA256:-}"
KIOSK_LOCKDOWN_KEYS="${KIOSK_LOCKDOWN_KEYS:-ask}"

APP_EXE="$APP_DIR/toddler-laptop-kiosk.x86_64"
LAUNCH_SCRIPT="$APP_DIR/launch-kiosk.sh"
XSESSION_SCRIPT="$APP_DIR/xsession.sh"
STARTX_WRAPPER_SCRIPT="$APP_DIR/run-startx.sh"
PRESTART_SCRIPT="$APP_DIR/prestart-kiosk.sh"
KEY_LOCKDOWN_SCRIPT="$APP_DIR/lockdown-special-keys.sh"
RECOVERY_HINT_SCRIPT="$APP_DIR/show-recovery-hint.sh"
RUNTIME_DIRECTORY_NAME="${SERVICE_NAME%.service}"
APP_EXIT_STATUS_FILE="/run/$RUNTIME_DIRECTORY_NAME/app-exit-status"
STARTX_LOG_FILE="/tmp/$SERVICE_NAME.run-startx.log"
STATE_FILE="$APP_DIR/install-state.env"
SERVICE_PATH="/etc/systemd/system/$SERVICE_NAME"
KEY_LOCKDOWN_ENABLED="0"

require_root() {
	if [ "${EUID:-$(id -u)}" -ne 0 ]; then
		echo "This installer must be run as root. Try: sudo $0"
		exit 1
	fi
}

require_command() {
	if ! command -v "$1" >/dev/null 2>&1; then
		echo "Missing required command: $1"
		echo "Install the Debian package that provides it, then run this installer again."
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

configure_key_lockdown() {
	case "$KIOSK_LOCKDOWN_KEYS" in
		1|true|TRUE|yes|YES|y|Y|on|ON)
			KEY_LOCKDOWN_ENABLED="1"
			;;
		0|false|FALSE|no|NO|n|N|off|OFF)
			KEY_LOCKDOWN_ENABLED="0"
			;;
		ask|ASK|"")
			echo
			echo "The kiosk can disable many X11-visible special keys, such as PrintScreen, volume, brightness, sleep, display, and touchpad toggle."
			echo "This does not affect normal letter or number keys, and Ctrl+Alt+F2 recovery remains available."
			if confirm "Enable special-key lockdown for the kiosk session?"; then
				KEY_LOCKDOWN_ENABLED="1"
			else
				KEY_LOCKDOWN_ENABLED="0"
			fi
			;;
		*)
			echo "Invalid KIOSK_LOCKDOWN_KEYS value: $KIOSK_LOCKDOWN_KEYS"
			echo "Use one of: ask, yes, no, 1, 0, true, false."
			exit 1
			;;
	esac

	if [ "$KEY_LOCKDOWN_ENABLED" = "1" ]; then
		if ! command -v xmodmap >/dev/null 2>&1; then
			echo "Special-key lockdown requires xmodmap."
			echo "Install the Debian package that provides it, usually: sudo apt install x11-xserver-utils"
			exit 1
		fi
	fi
}

create_kiosk_user() {
	if id "$KIOSK_USER" >/dev/null 2>&1; then
		echo "Using existing kiosk user: $KIOSK_USER"
		return
	fi

	echo "Creating kiosk user: $KIOSK_USER"
	useradd --create-home --shell /bin/bash "$KIOSK_USER"
}

install_app_files() {
	local temp_file
	local actual_sha256
	local systemctl_path

	echo "Installing app into: $APP_DIR"
	install -d -m 0755 "$APP_DIR"
	systemctl_path="$(command -v systemctl)"

	if [ -z "$RELEASE_SHA256" ]; then
		echo "RELEASE_SHA256 must be set to the expected SHA-256 digest for:"
		echo "$RELEASE_URL"
		exit 1
	fi

	temp_file="$(mktemp)"
	echo "Downloading latest release:"
	echo "$RELEASE_URL"
	wget -O "$temp_file" "$RELEASE_URL"
	actual_sha256="$(sha256sum "$temp_file" | cut -d' ' -f1)"
	if [ "$actual_sha256" != "$RELEASE_SHA256" ]; then
		rm -f "$temp_file"
		echo "Downloaded release checksum did not match RELEASE_SHA256."
		echo "Expected: $RELEASE_SHA256"
		echo "Actual:   $actual_sha256"
		exit 1
	fi
	install -m 0755 "$temp_file" "$APP_EXE"
	rm -f "$temp_file"

	cat >"$LAUNCH_SCRIPT" <<EOF
#!/usr/bin/env bash
set -euo pipefail

cd "$APP_DIR"
set +e
"$APP_EXE"
app_status="\$?"
set -e

printf '%s\n' "\$app_status" >"$APP_EXIT_STATUS_FILE" || true
exit "\$app_status"
EOF

	if [ "$KEY_LOCKDOWN_ENABLED" = "1" ]; then
		cat >"$KEY_LOCKDOWN_SCRIPT" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

if ! command -v xmodmap >/dev/null 2>&1; then
	echo "xmodmap is not installed; special-key lockdown was skipped." >&2
	exit 0
fi

disable_keysym() {
	local keysym="$1"

	if xmodmap -pke | grep -Eq "(^|[[:space:]])${keysym}($|[[:space:]])"; then
		xmodmap -e "keysym ${keysym} = NoSymbol" || true
	fi
}

disable_keysym Print
disable_keysym Sys_Req
disable_keysym XF86AudioMute
disable_keysym XF86AudioLowerVolume
disable_keysym XF86AudioRaiseVolume
disable_keysym XF86MonBrightnessUp
disable_keysym XF86MonBrightnessDown
disable_keysym XF86Sleep
disable_keysym XF86PowerOff
disable_keysym XF86Display
disable_keysym XF86TouchpadToggle
disable_keysym XF86WLAN
EOF
	else
		rm -f "$KEY_LOCKDOWN_SCRIPT"
	fi

	cat >"$XSESSION_SCRIPT" <<EOF
#!/usr/bin/env bash
set -euo pipefail

xset s off
xset -dpms
xset s noblank

if [ -x "$KEY_LOCKDOWN_SCRIPT" ]; then
	"$KEY_LOCKDOWN_SCRIPT"
fi

exec "$LAUNCH_SCRIPT"
EOF

	cat >"$STARTX_WRAPPER_SCRIPT" <<EOF
#!/usr/bin/env bash
set -euo pipefail

log_file="$STARTX_LOG_FILE"
: >"\$log_file" || true
exec >>"\$log_file" 2>&1

log() {
	printf '%s %s\n' "\$(date '+%Y-%m-%d %H:%M:%S')" "run-startx: \$*"
}

log "wrapper started as user \$(id -un) uid \$(id -u)"
log "tty: \$(tty 2>/dev/null || echo unknown)"
log "DISPLAY: \${DISPLAY:-unset}"
log "XAUTHORITY: \${XAUTHORITY:-unset}"
log "HOME: \${HOME:-unset}"

rm -f "$APP_EXIT_STATUS_FILE"

startx_status="1"

for attempt in 1 2 3; do
	log "starting X session attempt \$attempt"
	pkill -u "$(id -u "$KIOSK_USER")" -x startx >/dev/null 2>&1 || true
	pkill -u "$(id -u "$KIOSK_USER")" -x xinit >/dev/null 2>&1 || true
	pkill -u "$(id -u "$KIOSK_USER")" -x Xorg >/dev/null 2>&1 || true
	pkill -u "$(id -u "$KIOSK_USER")" -x X >/dev/null 2>&1 || true
	set +e
	"$(command -v startx)" "$XSESSION_SCRIPT" -- :0 vt1 -keeptty -nolisten tcp
	startx_status="\$?"
	set -e
	log "startx exited with status \$startx_status"

	if [ -r "$APP_EXIT_STATUS_FILE" ]; then
		break
	fi

	if [ "\$startx_status" = "0" ]; then
		break
	fi

	sleep 1
done

if [ -r "$APP_EXIT_STATUS_FILE" ]; then
	app_status="\$(cat "$APP_EXIT_STATUS_FILE" 2>/dev/null || true)"
	rm -f "$APP_EXIT_STATUS_FILE"
	log "app exited with status \${app_status:-unknown}"

	case "\$app_status" in
		0)
			exit 0
			;;
		""|*[!0-9]*)
			;;
		*)
			exit "\$app_status"
			;;
	esac
fi

exit "\$startx_status"
EOF

	cat >"$PRESTART_SCRIPT" <<EOF
#!/usr/bin/env bash
set -euo pipefail

"$systemctl_path" stop getty@tty1.service >/dev/null 2>&1 || true

if command -v chvt >/dev/null 2>&1; then
	chvt 1 || true
fi

if [ -f /tmp/.X0-lock ]; then
	x_pid="\$(tr -d '[:space:]' </tmp/.X0-lock 2>/dev/null || true)"
	if [ -z "\$x_pid" ] || ! kill -0 "\$x_pid" >/dev/null 2>&1; then
		rm -f /tmp/.X0-lock /tmp/.X11-unix/X0
	fi
fi

sleep 1
EOF

	cat >"$RECOVERY_HINT_SCRIPT" <<EOF
#!/usr/bin/env bash
set -euo pipefail

if [ "\${SERVICE_RESULT:-}" != "success" ]; then
	cat >/dev/tty1 <<'MESSAGE'

Toddler Laptop Kiosk failed to start.

To run commands, switch away from tty1 first:
  Press Ctrl+Alt+F2, then log in as an admin user.

Check the service status and logs from tty2:
  sudo systemctl status $SERVICE_NAME --no-pager -l
  sudo journalctl -u $SERVICE_NAME -b --no-pager -n 120
  sudo cat $STARTX_LOG_FILE

If systemd says "start request repeated too quickly", clear the failure state before retrying:
  sudo systemctl reset-failed $SERVICE_NAME
  sudo systemctl start $SERVICE_NAME

Restore the tty1 login prompt:
  sudo systemctl stop $SERVICE_NAME
  sudo systemctl restart getty@tty1.service

MESSAGE

	"$systemctl_path" --no-block restart getty@tty1.service >/dev/null 2>&1 || true
	exit 0
fi

cat >/dev/tty1 <<'MESSAGE'

Toddler Laptop Kiosk exited.

To run commands, switch away from tty1 first:
  Press Ctrl+Alt+F2, then log in as an admin user.

Start kiosk again from tty2:
  sudo systemctl reset-failed $SERVICE_NAME
  sudo systemctl start $SERVICE_NAME

Or reboot; the kiosk starts automatically on the next boot:
  sudo reboot

Restore graphical login instead from tty2:
  sudo systemctl enable --now display-manager.service

If that does not work, try the display manager this laptop uses:
  sudo systemctl enable --now gdm.service
  sudo systemctl enable --now gdm3.service
  sudo systemctl enable --now lightdm.service
  sudo systemctl enable --now sddm.service

MESSAGE

"$systemctl_path" --no-block restart getty@tty1.service >/dev/null 2>&1 || true
EOF

	chmod 0755 "$LAUNCH_SCRIPT" "$XSESSION_SCRIPT" "$STARTX_WRAPPER_SCRIPT" "$PRESTART_SCRIPT" "$RECOVERY_HINT_SCRIPT"
	if [ "$KEY_LOCKDOWN_ENABLED" = "1" ]; then
		chmod 0755 "$KEY_LOCKDOWN_SCRIPT"
	fi
	chown -R root:root "$APP_DIR"
}

write_service() {
	local systemctl_path
	local user_home

	systemctl_path="$(command -v systemctl)"
	user_home="$(getent passwd "$KIOSK_USER" | cut -d: -f6)"
	if [ -z "$user_home" ]; then
		echo "Could not determine home directory for user: $KIOSK_USER"
		exit 1
	fi

	echo "Writing systemd service: $SERVICE_PATH"
	cat >"$SERVICE_PATH" <<EOF
[Unit]
Description=Toddler Laptop Kiosk
After=systemd-user-sessions.service getty@tty1.service
Conflicts=getty@tty1.service
StartLimitIntervalSec=60
StartLimitBurst=5

[Service]
User=$KIOSK_USER
WorkingDirectory=$APP_DIR
Environment=HOME=$user_home
Environment=XAUTHORITY=$user_home/.Xauthority
RuntimeDirectory=$RUNTIME_DIRECTORY_NAME
RuntimeDirectoryMode=0755
TTYPath=/dev/tty1
TTYReset=yes
TTYVHangup=yes
PAMName=login
StandardInput=tty
StandardOutput=journal
StandardError=journal
ExecStartPre=+$PRESTART_SCRIPT
ExecStart=$STARTX_WRAPPER_SCRIPT
ExecStopPost=+$RECOVERY_HINT_SCRIPT
Restart=on-failure
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF
}

display_manager_active_or_enabled() {
	systemctl is-active --quiet display-manager.service && return 0
	systemctl is-enabled --quiet display-manager.service >/dev/null 2>&1 && return 0
	return 1
}

detect_display_manager_unit() {
	local link_target
	local unit_name

	if command -v readlink >/dev/null 2>&1 && [ -L /etc/systemd/system/display-manager.service ]; then
		link_target="$(readlink -f /etc/systemd/system/display-manager.service 2>/dev/null || true)"
		unit_name="$(basename "$link_target")"
		case "$unit_name" in
			*.service)
				echo "$unit_name"
				return 0
				;;
		esac
	fi

	echo "display-manager.service"
}

handle_display_manager() {
	local disabled_display_manager="0"
	local display_manager_unit

	if display_manager_active_or_enabled; then
		display_manager_unit="$(detect_display_manager_unit)"

		echo
		echo "A graphical display manager is active or enabled."
		echo "For bare kiosk boot, it should be disabled so tty1 can run only the kiosk app."
		if confirm "Disable display-manager.service now?"; then
			cat >"$STATE_FILE" <<EOF
DISPLAY_MANAGER_DISABLED=1
DISPLAY_MANAGER_UNIT=$display_manager_unit
EOF
			enable_kiosk_service
			systemctl disable --now display-manager.service
			return 0
		else
			cat >"$STATE_FILE" <<EOF
DISPLAY_MANAGER_DISABLED=0
EOF
			echo
			echo "Leaving the kiosk service installed but disabled."
			echo "After handling the display manager manually, enable it with:"
			echo "  sudo systemctl enable --now $SERVICE_NAME"
			return 1
		fi
	fi

	cat >"$STATE_FILE" <<EOF
DISPLAY_MANAGER_DISABLED=$disabled_display_manager
EOF
}

reload_systemd() {
	echo "Reloading systemd."
	systemctl daemon-reload
}

enable_kiosk_service() {
	echo "Enabling kiosk service."
	systemctl enable "$SERVICE_NAME"
}

main() {
	require_root
	require_command startx
	require_command xinit
	require_command xset
	require_command wget
	require_command sha256sum
	require_command cut
	require_command systemctl
	require_command getent
	require_command useradd

	echo "Toddler Laptop Kiosk installer"
	echo
	echo "User:        $KIOSK_USER"
	echo "App dir:     $APP_DIR"
	echo "Service:     $SERVICE_NAME"
	echo "Release URL: $RELEASE_URL"
	echo "SHA-256:     $RELEASE_SHA256"
	echo

	configure_key_lockdown
	create_kiosk_user
	install_app_files
	write_service
	reload_systemd

	if handle_display_manager; then
		if ! display_manager_active_or_enabled; then
			enable_kiosk_service
		fi
		echo
		echo "Kiosk setup complete. Reboot to start the app on tty1:"
		echo "  sudo reboot"
	fi
}

main "$@"
