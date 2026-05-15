# Kiosk Setup

This guide turns a Debian-based laptop into a bare Toddler Laptop Kiosk appliance.

The setup script installs the latest GitHub release executable, creates a dedicated kiosk user, and starts the app on boot through a systemd-managed X session on `tty1`.

This is separate from the Godot gameplay code. It changes Linux system configuration and should be run only by an adult installer who can recover the machine from a text console.

## Before You Start

Use a Debian-based laptop with a working X/startx setup.

The installer expects these commands to already exist on the target laptop:

```sh
startx
xinit
xset
wget
systemctl
sha256sum
sudo
```

If any are missing, install the relevant Debian packages first. Common package names include `xorg`, `xinit`, `x11-xserver-utils`, `wget`, and `coreutils`.

The optional special-key lockdown also uses `xmodmap`, which is usually included in `x11-xserver-utils`.

The laptop needs network access during setup so it can download the latest release. After installation, the app itself runs offline.

## Install

Download or clone this repository onto the target laptop.

Open a terminal in the repository root. That means the project folder that contains `README.md`, `project.godot`, and the `scripts/` directory.

The easiest install path calculates the release checksum for you, prints it, and passes it to the kiosk installer:

```sh
scripts/install-latest-kiosk.sh
```

You can still preselect special-key lockdown:

```sh
KIOSK_LOCKDOWN_KEYS=yes scripts/install-latest-kiosk.sh
```

The helper downloads the release once to calculate its SHA-256 checksum, then runs `scripts/install-kiosk.sh` with `sudo`.

## Manual Checksum Install

Use this path if you want to calculate or verify the checksum yourself before installing.

Before running the installer, get the SHA-256 checksum for the release executable. The installer uses this checksum to make sure the file it downloads is the same file you meant to install.

Best option: use a checksum published alongside the GitHub release, if one exists.

If there is no published checksum, download the release executable yourself and calculate it:

```sh
wget -O toddler-laptop-kiosk.x86_64 https://github.com/smurph7/toddler-laptop-kiosk/releases/latest/download/toddler-laptop-kiosk.x86_64
sha256sum toddler-laptop-kiosk.x86_64
```

The output looks like this:

```text
abc123...  toddler-laptop-kiosk.x86_64
```

Copy the long checksum before the filename. Use that value as `RELEASE_SHA256`:

```sh
sudo env RELEASE_SHA256=<sha256-from-previous-step> scripts/install-kiosk.sh
```

This checksum step catches accidental wrong, changed, or incomplete downloads during install. If the GitHub release itself is not trusted, calculate the checksum from a build you made yourself and host that exact file somewhere the target laptop can download with `wget`, then pass its URL with `RELEASE_URL`.

## What The Installer Does

By default, the installer:

- creates or reuses the `toddlerkiosk` user
- installs the app into `/opt/toddler-laptop-kiosk`
- downloads the latest release executable from GitHub
- verifies the executable against `RELEASE_SHA256`
- asks whether to disable common X11-visible special keys for the kiosk session
- writes `/etc/systemd/system/toddler-laptop-kiosk.service`
- records the Godot app exit status so an intentional app quit is treated as a clean service stop
- stops `getty@tty1.service` while the kiosk owns `tty1`, then restores it after a clean quit
- clears stale X display `:0` lock files only when no matching X process is still alive
- asks before disabling `display-manager.service`, and records the underlying display manager unit when possible
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
sudo env RELEASE_SHA256=<sha256-from-previous-step> KIOSK_LOCKDOWN_KEYS=yes scripts/install-kiosk.sh
```

To skip it explicitly:

```sh
sudo env RELEASE_SHA256=<sha256-from-previous-step> KIOSK_LOCKDOWN_KEYS=no scripts/install-kiosk.sh
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

This intentionally exits the app and leaves the kiosk service stopped until the next boot or manual restart. The launcher records the Godot app's exit status, so `Ctrl + Alt + Q` is treated as a clean service stop even if `startx` returns a non-zero status while tearing down X.

The service does not prompt to restore the desktop login, because it is not an interactive admin session. Instead, it prints recovery commands on `tty1` after a clean quit and asks systemd to restore the `tty1` login prompt without blocking service shutdown.

Do not run the restart command from `tty1` itself. The kiosk service owns `tty1`, so starting it there can reset the login session you are typing in.

To start the kiosk again without rebooting:

1. Press `Ctrl + Alt + F2`.
2. Log in as an admin user.
3. Clear any previous failure state and start the hyphenated service name:

```sh
sudo systemctl reset-failed toddler-laptop-kiosk.service
sudo systemctl start toddler-laptop-kiosk.service
```

Or just reboot; the kiosk starts automatically on the next boot:

```sh
sudo reboot
```

To restore graphical login instead, run this from `tty2`:

```sh
sudo systemctl enable --now display-manager.service
```

If that does not work, try the display manager this laptop uses:

```sh
sudo systemctl enable --now gdm.service
sudo systemctl enable --now gdm3.service
sudo systemctl enable --now lightdm.service
sudo systemctl enable --now sddm.service
```

If the app or X session crashes unexpectedly, systemd retries it a few times. If startup keeps failing, systemd stops retrying so the laptop does not get stuck flashing between tty1 and the app.

If `systemctl status` says `start request repeated too quickly`, systemd has hit that retry limit. Check the logs before retrying:

```sh
sudo systemctl status toddler-laptop-kiosk.service --no-pager -l
sudo journalctl -u toddler-laptop-kiosk.service -b --no-pager -n 120
```

After reading the error, clear the failure state before starting it again:

```sh
sudo systemctl reset-failed toddler-laptop-kiosk.service
sudo systemctl start toddler-laptop-kiosk.service
```

If `tty1` is left as a black screen with a blinking cursor, switch to another console and restart the login prompt:

```sh
sudo systemctl stop toddler-laptop-kiosk.service
sudo systemctl restart getty@tty1.service
```

Then press `Ctrl + Alt + F1` to return to the restored `tty1` login prompt.

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
- offers to re-enable the graphical display manager if the installer disabled it, or if no active/enabled display manager is detected during uninstall
- starts the graphical display manager only after uninstall cleanup finishes, so it does not interrupt the terminal prompts

Different Debian installs expose the display manager under different systemd unit names. The uninstaller first tries the unit recorded during install, then common units such as `gdm.service`, `gdm3.service`, `lightdm.service`, and `sddm.service`.

If you end up at a text console and need the normal graphical login back manually, try the unit your laptop uses:

```sh
sudo systemctl enable --now gdm.service
sudo systemctl enable --now gdm3.service
sudo systemctl enable --now lightdm.service
sudo systemctl enable --now sddm.service
```

You only need one of these commands. On some systems `start` works for the current boot, but `enable --now` is better when you also want it to come back after reboot.

Reboot after uninstalling if you want to confirm normal boot behaviour.

## Maintainer Overrides

The scripts support a few environment overrides for testing or custom installs:

```sh
sudo env KIOSK_USER=childkiosk APP_DIR=/opt/toddler-laptop-kiosk RELEASE_SHA256=<sha256-from-previous-step> scripts/install-kiosk.sh
```

Use the same overrides for uninstalling a custom install:

```sh
sudo env KIOSK_USER=childkiosk APP_DIR=/opt/toddler-laptop-kiosk scripts/uninstall-kiosk.sh
```

You can also override the release URL:

```sh
sudo env RELEASE_URL=https://example.com/toddler-laptop-kiosk.x86_64 RELEASE_SHA256=<sha256-for-that-file> scripts/install-kiosk.sh
```

You can preselect special-key lockdown for scripted installs:

```sh
sudo env KIOSK_LOCKDOWN_KEYS=yes RELEASE_SHA256=<sha256-from-previous-step> scripts/install-kiosk.sh
```

For safety, the uninstaller only removes `APP_DIR` when it is `/opt/toddler-laptop-kiosk` or a child path under that directory.

## Current Limits

This setup handles booting into the app and can disable many X11-visible special keys. It does not configure deeper lockdown such as BIOS settings, a custom splash screen, package removal, browser removal, power-button policy, firmware-handled Fn keys, or a child-proof shutdown flow.
