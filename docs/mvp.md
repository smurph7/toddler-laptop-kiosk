# docs/mvp.md

# MVP Goal

Build the first playable version of the toddler toy laptop experience.

The MVP should prove:

- fullscreen kiosk-style behaviour
- responsive visual feedback
- stable performance on old laptops
- satisfying keyboard/mouse interaction
- toddler-safe interaction design

The MVP does not need polished art, audio, progression systems, or educational content.

---

# Engine + Platform

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

# Core Experience

The application should launch directly into a fullscreen interactive scene.

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
