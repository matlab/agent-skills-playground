# Available Design Styles

## Built-in Styles

| Style | File | Description |
|-------|------|-------------|
| Clean | `styles/clean.md` | Frosted glass, system typography, depth layers, spring animations |
| Material | `styles/material.md` | Material Design 3: tonal surfaces, elevation, ripple effects, rounded shapes |
| Cosmic Dark | `styles/cosmic-dark.md` | Deep space aesthetic: dark purples, neon glow, glassmorphism, particle-feel |
| Neumorphic Dark | `styles/neumorphic-dark.md` | Soft shadows on charcoal, embossed/debossed surfaces, tactile physical feel |
| Dashboard Light | `styles/dashboard-light.md` | Clean white cards on lavender-gray, indigo accent, data-dense, professional |
| Midnight Gradient | `styles/midnight-gradient.md` | Near-black with blue-to-purple gradient accents, luxury premium feel |
| Minimal Mono | `styles/minimal-mono.md` | Ultra-dark teal, single muted lavender accent, compact pill shapes, flat |
| Warm Dark | `styles/warm-dark.md` | Warm neutral darks with amber/yellow accent, smart home feel, friendly |

## Requesting a Style

Users can specify a style in several ways:

- **By name**: "Use the Clean style", "Make it Midnight Gradient"
- **By description**: "I want a clean, bright, frosted-glass feel" → maps to Clean; "dark with yellow accents" → maps to Warm Dark; "soft embossed buttons" → maps to Neumorphic Dark
- **Custom**: "Give it a retro-futuristic neon look" → apply creative design thinking from SKILL.md

## Adding Custom Styles

To add a new built-in style, create a new `.md` file in `references/styles/` following the 9-section DESIGN.md format:

1. Visual Theme & Atmosphere
2. Color Palette & Roles
3. Typography Rules
4. Component Stylings
5. Layout Principles
6. Depth & Elevation
7. Motion & Interaction
8. Do's and Don'ts
9. Agent Prompt Guide

## Style Selection Logic

1. If user explicitly names a built-in style → load that style's reference file
2. If user describes an aesthetic that clearly maps to a built-in style → load it
3. If user describes a novel aesthetic → generate the design system creatively without a reference file
4. If no style mentioned → ask the user, or default to Clean for a polished starting point
