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

There are two useful ways to use this repo:

- **Set it up as-is on a toddler laptop:** use an exported Linux build and run the executable. The laptop does not need Godot installed.
- **Use it as a starting point:** install Godot 4.2.x, edit the project, then export your own Linux build.

The target deployment platform is a Debian-based Linux laptop with integrated graphics. The app is offline and self-contained once exported.

## Set Up The Laptop As-Is

Use this path when you just want the toy laptop app running on the child-facing machine.

You need an exported Linux executable:

- If someone has already given you `toddler-laptop-kiosk.x86_64`, use that.
- If you only have the source repo, follow [Customize Or Rebuild](#customize-or-rebuild) once to create `builds/toddler-laptop-kiosk.x86_64`.

On the Debian laptop, create an app folder:

```sh
mkdir -p ~/toddler-laptop-kiosk
```

Copy the exported file into that folder. For example, from another machine:

```sh
scp builds/toddler-laptop-kiosk.x86_64 user@laptop.local:~/toddler-laptop-kiosk/
```

Use the laptop username, hostname, or IP address that matches your setup.

Then run it on the laptop:

```sh
cd ~/toddler-laptop-kiosk
chmod +x toddler-laptop-kiosk.x86_64
./toddler-laptop-kiosk.x86_64
```

The laptop does not need the Godot editor for this path.

## Customize Or Rebuild

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
builds/toddler-laptop-kiosk.x86_64
```

The preset embeds the PCK data into the executable, so the build should be a single Linux executable.

After exporting locally, you can run the exported build from the repo root with:

```sh
./toddler-laptop-kiosk.sh
```

Do not use Docker as the runtime for the toddler laptop. This is a fullscreen graphical kiosk app, and the project explicitly avoids Docker as a runtime dependency.

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

Linux kiosk lockdown, boot-to-app setup, desktop hiding, and system-level controls are handled outside this Godot project.

## Project Structure

```text
export_presets.cfg       Linux export preset
toddler-laptop-kiosk.sh  Convenience launcher for local exported builds
project.godot            Godot project configuration
scenes/main.tscn         Main interactive scene
scripts/main.gd          Input handling, effect spawning, drawing, limits
docs/mvp.md              Current build target
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
