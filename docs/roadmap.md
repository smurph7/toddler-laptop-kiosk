# docs/roadmap.md

# Roadmap

This document contains future ideas and possible directions for the toddler toy laptop project, plus a short record of completed non-gameplay infrastructure.

Future ideas in this document are intentionally out of scope for the current MVP.

Roadmap items should not be implemented unless explicitly moved into `docs/mvp.md`.

---

# Philosophy

Future additions should continue to follow the core project principles:

- immediate feedback
- toddler-safe UX
- no fail states
- offline-first
- lightweight performance
- exploratory play
- visually rewarding interaction

Complexity should be added carefully.

The application should remain approachable for very young children.

---

# Completed Baseline

The current MVP already includes:

- fullscreen Godot 4.2.x 2D scene
- keyboard bursts for all keys
- larger Space, Enter, and Backspace bursts
- one-shot held-key blooms after about 1 second
- mouse/touchpad trails and click bursts
- invisible drifting focus area for keyboard effects
- cursor hiding after inactivity
- adult-only `Ctrl + Alt + Q` quit shortcut
- bounded particles, trails, and rings
- dynamic effect-density reduction when framerate drops
- Debian-focused kiosk install and uninstall scripts
- optional X11-visible special-key lockdown during kiosk startup
- checksum verification for downloaded release installs

Future work should build from this baseline rather than re-specifying it.

---

# Friendly Blob / Familiar

## Concept

Add a simple friendly glowing creature or blob that lives on the screen.

The blob should:

- wander slowly around the scene
- react to input
- act as a visual anchor for effects
- feel alive but calming

Keyboard effects may:

- appear near the blob
- attract the blob
- push/pull the blob slightly

Mouse movement may:

- attract the blob toward the cursor
- encourage playful chasing behaviour

## Design Goals

The familiar should:

- feel soft and friendly
- avoid uncanny facial animation
- remain readable at a distance
- not require interaction to be fun

The familiar should enhance the scene rather than dominate it.

---

# Calm Mode

## Concept

An alternate softer interaction mode.

Possible changes:

- slower movement
- softer colours
- larger slower particles
- reduced visual intensity
- calmer background animation

Potential hidden toggle:

- Ctrl + Alt + C

## Design Goal

Calm mode should:

- feel soothing
- remain engaging
- reduce overstimulation
- still respond clearly to input

---

# Palette Themes

## Concept

Different visual themes or palettes.

Examples:

- neon candy
- soft pastel glow
- deep ocean
- space
- warm sunset
- magical forest

Palette changes should:

- preserve readability
- preserve visual clarity
- avoid overly dark combinations

---

# Parent Menu

## Concept

A hidden adult-only menu.

Potential functionality:

- quit app
- toggle fullscreen
- switch visual themes
- toggle calm mode
- adjust effect intensity
- restart scene

This should remain hidden from children.

---

# Additional Input Behaviours

Potential future interactions:

- ripple effects
- directional particle pushes
- screen-wide waves
- gravity-like attraction
- bouncing particles
- cursor magnetism
- glowing paint behaviour

Any additions should remain:

- obvious
- responsive
- low-frustration

---

# Visual Enhancements

Possible future improvements:

- improved glow rendering
- better particle textures
- animated gradients
- layered parallax backgrounds
- more organic movement systems
- procedural visual patterns

Performance should always remain the priority.

---

# Simple Cause-and-Effect Toys

Potential future toy-like interactions:

- floating shapes that react to bursts
- stars that scatter when clicked
- sleepy glowing creatures
- bubbles that merge/pop
- drifting lanterns
- paint clouds
- simple physics objects

These should remain:

- open-ended
- non-competitive
- non-verbal

---

# Educational Layer (Optional Future)

Potential very-light educational interactions:

- large letters appearing on keypress
- number reactions
- colour recognition
- shape reactions

Educational features should:

- remain playful
- avoid testing mechanics
- avoid scoring systems
- avoid pressure

The app should still primarily feel like a toy, not school software.

---

# Multiple Modes / Scenes

Possible future modes:

- light painting
- bubble mode
- star field
- blob playground
- sleepy night mode
- colour splash mode

Scene switching should remain:

- simple
- hidden from toddlers
- quick to load

---

# Save Data / Preferences

Potential future persistence:

- preferred palette
- calm mode state
- fullscreen preferences
- selected toy mode

The app should continue working fully offline.

No accounts or cloud systems should be required.

---

# Linux Appliance Setup

The initial Debian appliance setup is implemented. These are deployment features rather than gameplay features.

## Kiosk Setup Scripts

Debian-focused scripts live in this repository and can be run manually on the target laptop by an adult installer.

Implemented responsibilities:

- create or reuse a dedicated kiosk user
- install the latest release executable into a stable local app directory
- verify the downloaded release executable against a required SHA-256 checksum
- create a systemd service that starts a bare X session on boot
- launch the app automatically after boot
- configure X screen blanking and DPMS for the kiosk session
- optionally disable common X11-visible special keys before launching the app
- provide a reversible uninstall script

Scripts should:

- be explicit about the system changes they make
- avoid destructive changes without confirmation
- remain Debian-focused
- avoid Docker as a runtime dependency
- keep Linux lockdown separate from Godot gameplay code

Future appliance setup ideas:

- custom splash screen
- deeper desktop hiding and package lockdown
- simplified adult shutdown flow
- display manager support beyond the current prompt-and-disable path
- kiosk appliance packaging
- optional Linux power-button/logind policy guidance

---

# Explicit Non-Goals

The project should avoid becoming:

- ad-supported
- online-service dependent
- achievement-focused
- score-focused
- stressful
- competitive
- menu-heavy
- cluttered

The experience should remain:

- immediate
- playful
- tactile
- exploratory
- calming
- visually magical
