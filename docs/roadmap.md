# docs/roadmap.md

# Roadmap

This document contains future ideas and possible directions for the toddler toy laptop project.

These are intentionally out of scope for the current MVP.

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

Future deployment improvements:

- boot directly into app
- custom splash screen
- hidden Linux desktop
- simplified shutdown flow
- kiosk appliance packaging
- optional repo-managed setup scripts for the target laptop

These are deployment enhancements rather than gameplay features.

## Kiosk Setup Scripts

Future scripts may live in this repository and be run manually on the Debian laptop by an adult installer.

Possible responsibilities:

- create or configure a dedicated kiosk user
- install the latest release executable into a stable local app directory
- create a desktop autostart entry or systemd user service
- launch the app automatically after login or boot
- configure display sleep, cursor visibility, and basic power behaviour
- provide a reversible uninstall/reset script

Scripts should:

- be explicit about the system changes they make
- avoid destructive changes without confirmation
- remain Debian-focused
- avoid Docker as a runtime dependency
- keep Linux lockdown separate from Godot gameplay code

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
