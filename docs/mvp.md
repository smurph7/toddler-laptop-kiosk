# docs/mvp.md

# MVP

This is the active build-target document for the toddler toy laptop MVP.

Use this file to tell AI agents what is currently being built. Keep `docs/roadmap.md` for future ideas that are not active requirements.

The MVP should continue to prove:

- fullscreen kiosk-style behaviour
- responsive visual feedback
- stable performance on old laptops
- satisfying keyboard/mouse interaction
- toddler-safe interaction design

---

# Current State

The first playable baseline is implemented.

Current implemented behaviour:

- launches straight into `res://scenes/main.tscn`
- requests fullscreen at startup
- uses a borderless fullscreen project configuration
- uses Godot 4.2 project settings
- uses lightweight 2D canvas drawing
- uses the GL Compatibility renderer for older Linux laptops
- responds to keyboard presses with colourful glowing bursts
- makes Space, Enter, and Backspace noticeably larger
- creates a one-shot held-key bloom after about 1 second
- creates mouse/touchpad trails
- creates mouse click bursts
- continuously emits trail particles while the mouse button is held
- uses an invisible drifting focus area for keyboard effects
- hides the cursor after a short idle period
- shows the cursor again on mouse movement/click
- caps particles, trails, and rings
- removes expired effects and trims oldest effects first
- dynamically lowers effect density when framerate drops
- provides the adult-only `Ctrl + Alt + Q` quit shortcut

Current known limits:

- No automated Godot test suite is present.
- Touchscreen support has not been implemented or verified.
- Kiosk hardening is handled by the Linux setup scripts, not by the Godot scene.
- The app does not yet include polished art, audio, progression systems, or educational content.

---

# Current Goal

The current goal is to keep the implemented baseline stable while adding only features explicitly requested by the user.

When adding a feature:

- update this section with the immediate target before implementation if the request changes MVP scope
- preserve all baseline behaviours listed above
- keep the feature toddler-safe, offline, lightweight, and failure-free
- avoid pulling roadmap ideas into the MVP unless the user explicitly asks for them

Active feature target:

- None. Await the next explicit user-requested MVP feature.

---

# Engine + Platform Requirements

## Engine

- Godot 4.2.x
- 2D only

## Target Platform

- Debian-based Linux
- old laptops
- integrated graphics
- landscape orientation

## Input Methods

Supported:

- keyboard
- mouse
- touchpad

Not required:

- touchscreen
- controllers
- internet connection

---

# Current Experience

The application should launch directly into one fullscreen interactive scene.

The screen should feel:

- magical
- reactive
- colourful
- alive
- easy to understand

The player should immediately discover:

- pressing keys creates effects
- moving the cursor creates trails
- clicking creates bursts
- holding keys creates larger reactions

No instructions are required.

---

# Visual Direction

## Background

Use:

- dark background
- subtle animated glow/ribbon motion
- gentle ambient movement

The screen should not feel static even when idle.

Avoid:

- visually noisy backgrounds
- excessive flashing
- high-frequency strobing

---

# Input Reactions

## Keyboard Presses

Any key press should:

- create visible glowing bubbles/light particles
- feel immediate
- appear near the current focus area

Effects should:

- vary slightly in size and direction
- remain visually coherent
- avoid feeling completely random

## Large Keys

Special keys should create larger effects.

Examples:

- Space
- Enter
- Backspace

These should feel noticeably more dramatic than standard keys.

## Key Holding

Holding a key should trigger a larger event after approximately 1 second.

Example behaviour:

- large screen-wide bloom
- ripple/ring wave
- intensified particle burst

This should:

- fire once per hold
- feel rewarding
- not destroy performance

## Mouse / Touchpad Movement

Moving the cursor should:

- create glowing trails
- visibly follow cursor motion
- scale effect intensity slightly with movement speed

## Mouse Clicks

Clicking should:

- create a burst directly at the cursor position
- feel stronger than passive movement trails

Holding the mouse button may continuously emit particles/trails.

---

# Focus Behaviour

The scene should contain an invisible drifting "focus area".

Keyboard effects should:

- usually appear near the focus area
- occasionally appear globally/randomly
- periodically jump to new locations

This helps:

- maintain visual coherence
- keep the screen feeling alive
- prevent repetitive clustering

The focus movement should feel organic and slow.

---

# Performance Requirements

## Framerate

Target:

- stable responsive framerate on older laptops

Visual density may reduce dynamically if performance drops.

## Particle Limits

The application must:

- cap active particle/effect counts
- remove oldest effects first
- clean up expired effects automatically

Keyboard smashing should not crash or freeze the application.

## Rendering Constraints

Avoid:

- heavy shaders
- expensive post-processing
- high-resolution textures
- excessive transparency stacking

Prefer:

- lightweight glow effects
- simple particles
- efficient animation

---

# Fullscreen Behaviour

The application should:

- launch fullscreen by default
- hide the mouse cursor after inactivity
- avoid visible window chrome/borders where possible

---

# Exit Behaviour

There should be:

- no visible quit button
- no visible settings menu

A hidden adult-only quit shortcut should exist.

Example:

- Ctrl + Alt + Q

The shortcut should not trigger accidentally during normal child interaction.

---

# MVP Non-Goals

Do not build yet:

- audio
- friendly blob/familiar
- calm mode
- palette switching
- parent menu
- progression systems
- save systems
- educational gameplay
- accounts
- networking
- online updates
- achievements
- minigames

---

# MVP Success Criteria

The MVP is successful if:

- the app launches fullscreen on Linux
- input always creates obvious visible reactions
- keyboard smashing feels fun
- mouse movement feels playful
- holding keys creates satisfying large effects
- the app remains stable during aggressive input
- the experience feels intuitive without explanation
- toddlers can interact freely without fail states
