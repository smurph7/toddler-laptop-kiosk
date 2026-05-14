# AGENTS.md

## Project Overview

This project is a fullscreen toddler-safe toy laptop application built with Godot 4.2.x.

The application is designed for old Debian-based Linux laptops and should behave more like a dedicated toy appliance than a traditional computer application.

The experience is intentionally simple:

- keyboard input creates colourful visual reactions
- mouse/touchpad movement creates trails and bursts
- there are no fail states
- there is no text entry
- there are no menus visible to children
- all interactions should feel immediate and rewarding

The app is fully offline and self-contained.

---

# Core Technical Rules

## Engine

- Use Godot 4.2.x only
- Do not upgrade engine versions unless explicitly requested
- Use lightweight 2D rendering only
- Avoid heavy shaders or expensive effects
- Prioritise stable framerate over visual complexity

## GDScript

- Treat Godot parser warnings as build-blocking errors
- Do not rely on inferred `Variant` types
- Add explicit type annotations for variables assigned from dictionaries, arrays, `clamp`, `min`, `max`, or other Variant-returning APIs
- Prefer typed helpers such as `clampf`, `minf`, and `maxf` for numeric values

## Platform Target

Target hardware:

- old laptops
- integrated graphics
- lower-end CPUs

Target operating system:

- Debian-based Linux
- landscape orientation only

Input methods:

- keyboard
- mouse
- touchpad

Touchscreen support is optional and not required.

---

# Design Principles

## Immediate Feedback

Every user input should create an obvious visible reaction.

Examples:

- key press → bubbles/glow/burst
- mouse movement → visible trail
- mouse click → burst at cursor
- key hold → larger special effect

The connection between action and response should always feel clear.

## No Fail States

The application must never:

- punish the user
- show failure messages
- block progression
- require accuracy
- require reading ability

The app is exploratory and responsive, not goal-oriented.

## Toddler-Safe UX

The app should:

- avoid overwhelming UI
- avoid small buttons
- avoid menus for children
- avoid accidental exits
- avoid hidden mechanics required for fun

Fun should happen immediately and continuously.

## Offline First

The application should:

- work fully offline
- have no required network connection
- have no accounts or login systems
- avoid cloud dependencies

## Kiosk Behaviour

The app should behave like a toy appliance:

- fullscreen by default
- no visible desktop UI
- no visible browser UI
- no visible operating system controls

Linux lockdown/setup is handled separately from the Godot app itself.

---

# Performance Rules

## Stable Performance Is More Important Than Fancy Effects

Always prioritise:

- responsiveness
- low latency
- stable framerate
- graceful degradation

Over:

- high particle counts
- expensive rendering
- complex post-processing

## Effect Limits

The app should:

- cap active particles/effects
- clean up expired effects automatically
- remove oldest effects first if limits are exceeded
- reduce visual density if performance drops

The application must remain responsive even during aggressive keyboard smashing.

---

# Input Philosophy

The app should encourage experimentation.

Input should feel:

- playful
- forgiving
- obvious
- magical
- reactive

Random keyboard smashing should still feel satisfying.

Unknown keys should still produce valid effects.

---

# Non-Goals

Do not add unless explicitly requested:

- accounts
- analytics
- online services
- advertisements
- educational gating systems
- fail/win screens
- microtransactions
- browser-based implementation
- Electron
- Docker runtime dependency
- backend/server architecture

---

# Documentation Structure

Use:

- `docs/mvp.md` for the current build target
- `docs/roadmap.md` for future ideas
- `README.md` for setup, running, export, and kiosk deployment notes

Do not treat roadmap items as active requirements.
