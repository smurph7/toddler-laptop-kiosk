# Kiosk Setup

This guide turns a Debian-based laptop into a bare Toddler Laptop Kiosk appliance.

The setup script installs the latest GitHub release executable, creates a dedicated kiosk user, and starts the app on boot through a systemd-managed X session on `tty1`.

This is separate from the Godot gameplay code. It changes Linux system configuration and should be run only by an adult installer who can recover the machine from a text console.

## Before You Start

Use a Debian-based laptop with a working X/startx setup.

The installer expects these commands to already exist:

```sh
startx
xinit
xset
wget
systemctl
```

If any are missing, install the relevant Debian packages first. Common package names include `xorg`, `xinit`, `x11-xserver-utils`, and `wget`.

The optional special-key lockdown also uses `xmodmap`, which is usually included in `x11-xserver-utils`.

The laptop needs network access during setup so it can download the latest release. After installation, the app itself runs offline.

Get the expected SHA-256 digest for the release executable before installing. The installer refuses to install a downloaded executable unless `RELEASE_SHA256` matches the file.

## Install

Download or clone this repository onto the target laptop.

From the repository root, run with the expected release digest:

```sh
sudo RELEASE_SHA256=<expected-sha256> scripts/install-kiosk.sh
```

By default, the installer:

- creates or reuses the `toddlerkiosk` user
- installs the app into `/opt/toddler-laptop-kiosk`
- downloads the latest release executable from GitHub
- verifies the executable against `RELEASE_SHA256`
- asks whether to disable common X11-visible special keys for the kiosk session
- writes `/etc/systemd/system/toddler-laptop-kiosk.service`
- asks before disabling `display-manager.service`
- enables the kiosk service before making display-manager changes

If the installer asks about disabling `display-manager.service`, choose `y` only when this laptop is intended to boot straight into the kiosk app.

Then reboot:

```sh
sudo reboot
```

On the next boot, the app should start fullscreen on `tty1`.

## Special-Key Lockdown

Godot receives normal keyboard input after Linux and the X session have handled system keys. It cannot reliably block keys that are handled by the operating system, desktop shortcuts, firmware, or laptop hardware before they reach the app.

During install, you can enable special-key lockdown for the bare X kiosk session. When enabled, the installer writes a small startup script that uses `xmodmap` before launching the app. It disables common X11-visible keys such as PrintScreen, SysRq, volume up/down/mute, brightness up/down, sleep, power, display toggle, touchpad toggle, and Wi-Fi toggle.

You can choose the option interactively, or set it explicitly:

```sh
sudo RELEASE_SHA256=<expected-sha256> KIOSK_LOCKDOWN_KEYS=yes scripts/install-kiosk.sh
```

To skip it explicitly:

```sh
sudo RELEASE_SHA256=<expected-sha256> KIOSK_LOCKDOWN_KEYS=no scripts/install-kiosk.sh
```

This keeps `Ctrl + Alt + F2` recovery available. Some Fn/media keys may still work if the laptop firmware handles them below Linux/X11; those need BIOS/UEFI or hardware-specific settings. Power-button behaviour is also separate and should be managed with Linux `logind` policy only if the adult installer wants that extra lockdown.

## Recovery

If you need to leave the kiosk app:

1. Press `Ctrl + Alt + F2` to switch to another text console.
2. Log in as an admin user.
3. Stop the kiosk service:

```sh
sudo systemctl stop toddler-laptop-kiosk.service
```

To keep it from starting on future boots:

```sh
sudo systemctl disable toddler-laptop-kiosk.service
```

The app also has an adult-only quit shortcut:

```text
Ctrl + Alt + Q
```

Because the systemd service restarts the app automatically, quitting the app is mainly useful for quick checks. Use `systemctl stop` when you want it to stay stopped.

## Uninstall

From the repository root, run:

```sh
sudo scripts/uninstall-kiosk.sh
```

The uninstaller:

- stops and disables the kiosk service
- removes the systemd unit
- removes `/opt/toddler-laptop-kiosk`
- asks before deleting the `toddlerkiosk` user and home directory
- offers to re-enable `display-manager.service` if the installer disabled it

Reboot after uninstalling if you want to confirm normal boot behaviour.

## Maintainer Overrides

The scripts support a few environment overrides for testing or custom installs:

```sh
KIOSK_USER=childkiosk APP_DIR=/opt/toddler-laptop-kiosk sudo -E scripts/install-kiosk.sh
```

Use the same overrides for uninstalling a custom install:

```sh
KIOSK_USER=childkiosk APP_DIR=/opt/toddler-laptop-kiosk sudo -E scripts/uninstall-kiosk.sh
```

You can also override the release URL:

```sh
RELEASE_URL=https://example.com/toddler-laptop-kiosk.x86_64 RELEASE_SHA256=<expected-sha256> sudo -E scripts/install-kiosk.sh
```

You can preselect special-key lockdown for scripted installs:

```sh
KIOSK_LOCKDOWN_KEYS=yes RELEASE_SHA256=<expected-sha256> sudo -E scripts/install-kiosk.sh
```

For safety, the uninstaller only removes `APP_DIR` when it is `/opt/toddler-laptop-kiosk` or a child path under that directory.

## Current Limits

This setup handles booting into the app and can disable many X11-visible special keys. It does not configure deeper lockdown such as BIOS settings, a custom splash screen, package removal, browser removal, power-button policy, firmware-handled Fn keys, or a child-proof shutdown flow.
