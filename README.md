# Toddler Laptop Kiosk

A fullscreen toddler-safe toy laptop app built with Godot 4.2.x.

The app turns keyboard, mouse, and touchpad input into colourful visual reactions. It has no text entry, menus, scores, fail states, accounts, or network features. It is intended to feel like a dedicated toy appliance on an older Debian-based laptop.

## Current MVP

The current build launches straight into one fullscreen interactive scene.

- Pressing any key creates glowing bubbles and light particles.
- Pressing larger keys, such as Space, Enter, or Backspace, creates a bigger burst.
- Holding a key for about one second creates a larger bloom at the original key burst position.
- Moving the mouse or touchpad creates glowing trails.
- Clicking creates a stronger burst at the cursor.
- Holding the mouse button continuously emits trail particles.
- The background has gentle ambient glow and ribbon motion so the scene does not feel static.

Keyboard effects are guided by an invisible drifting focus area. The focus area is not drawn on screen; it only helps keep effects visually coherent instead of completely random.

## Who This Is For

There are three useful ways to use this repo:

- **Set up and run the app on a laptop:** use an exported Linux build and run the executable. The laptop does not need Godot installed.
- **Turn a Debian laptop into a kiosk appliance:** use the setup scripts to install the latest release and start it automatically on boot.
- **Use it as a starting point:** install Godot 4.2.x, edit the project, then export your own Linux build.

The target deployment platform is a Debian-based Linux laptop with integrated graphics. The app is offline and self-contained once exported.

## Run the app

Use this path when you just want the app running on the child-facing machine.

Download the latest Linux executable from the project's GitHub Releases page:

```text
https://github.com/smurph7/toddler-laptop-kiosk/releases
```

Or download the latest release asset directly from the command line:

```sh
wget https://github.com/smurph7/toddler-laptop-kiosk/releases/latest/download/toddler-laptop-kiosk.x86_64
```

Then make it executable and run it:

```sh
chmod +x toddler-laptop-kiosk.x86_64
./toddler-laptop-kiosk.x86_64
```

The laptop does not need the Godot editor for this path.

## Boot To Kiosk

Use this path when the laptop's only job is to run this app.

The kiosk setup scripts are Debian-focused. They install the latest release executable, create a dedicated kiosk user, and configure systemd to start the app on boot in a bare X session.

Read the full walkthrough first:

```text
docs/kiosk-setup.md
```

Then, from this repository on the target laptop:

```sh
sudo RELEASE_SHA256=<expected-sha256> scripts/install-kiosk.sh
```

During install, you can enable special-key lockdown for the kiosk session. This uses X11 `xmodmap` to disable common X-visible keys such as PrintScreen, volume, brightness, sleep, display toggle, touchpad toggle, and Wi-Fi toggle before the app starts:

```sh
sudo RELEASE_SHA256=<expected-sha256> KIOSK_LOCKDOWN_KEYS=yes scripts/install-kiosk.sh
```

Some laptop Fn/media keys are handled by firmware or hardware before Godot can see them. Those may need BIOS/UEFI or hardware-specific settings. Power-button behaviour is a separate Linux `logind` policy choice and is not changed by the default installer.

To reverse the setup:

```sh
sudo scripts/uninstall-kiosk.sh
```

## Controls

Child-facing controls:

- Any key: create a colourful burst.
- Space, Enter, Backspace: create a larger burst.
- Hold any key: create a larger bloom after about one second.
- Move mouse or touchpad: create trails.
- Click: create a burst at the cursor.
- Hold mouse button: continuously emit trails.

Adult-only control:

- `Ctrl + Alt + Q`: quit the app.

There is no visible quit button or settings menu.

## Fullscreen And Cursor Behaviour

The app requests fullscreen mode on launch and uses a borderless fullscreen project configuration. The mouse cursor is visible while moving, then hides after a short period of inactivity.

Linux kiosk lockdown, boot-to-app setup, desktop hiding, and system-level controls are handled outside the Godot gameplay code. The kiosk installer can disable many X11-visible special keys, but Godot cannot reliably block operating-system, firmware, or hardware-level keys by itself.

## For Devs - Customize Or Rebuild

Use this path when you want to change the app or create a fresh exported build yourself.

Requirements on the development machine:

- Godot 4.2.x
- Godot 4.2.x export templates
- Git, if cloning the repo

Open this project in Godot 4.2.x. The main scene is:

```text
res://scenes/main.tscn
```

To run the project source from a terminal:

```sh
godot --path .
```

If your Godot executable is named `godot4`, use:

```sh
godot4 --path .
```

### Export A Linux Build

In Godot:

1. Open this project.
2. Go to `Project > Export`.
3. Select the `Linux Desktop` preset.
4. Click `Export Project`.
5. Export to:

```text
toddler-laptop-kiosk.x86_64
```

The preset embeds the PCK data into the executable, so the build should be a single Linux executable.

After exporting locally, you can run the exported build from the repo root with:

```sh
./toddler-laptop-kiosk.sh
```

## Project Structure

```text
export_presets.cfg       Linux export preset
toddler-laptop-kiosk.sh  Convenience launcher for local exported builds
project.godot            Godot project configuration
scenes/main.tscn         Main interactive scene
scripts/main.gd          Input handling, effect spawning, drawing, limits
scripts/install-kiosk.sh Debian kiosk installer
scripts/uninstall-kiosk.sh Debian kiosk uninstaller
docs/mvp.md              Current build target
docs/kiosk-setup.md      Debian boot-to-kiosk walkthrough
docs/roadmap.md          Future ideas, not active requirements
AGENTS.md                Project rules for coding agents
```

## Development Notes

- Keep the app offline and self-contained.
- Keep rendering lightweight for old laptops.
- Cap and clean up active effects so keyboard smashing stays responsive.
- Treat Godot parser warnings as build-blocking errors.
- Avoid inferred `Variant` types in GDScript where Godot warns.
- Do not implement roadmap items unless they are explicitly moved into `docs/mvp.md`.
