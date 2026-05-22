# Neumorphic Dark Design System

## 1. Visual Theme & Atmosphere

A soft, tactile interface where elements appear physically extruded from or pressed into a dark surface. Inspired by physical button panels, embossed controls, and premium audio equipment.

- **Tactility**: Controls look and feel like physical objects: raised buttons, recessed tracks, embossed panels
- **Softness**: Paired light/dark shadows create the illusion of a continuous soft surface
- **Physicality**: No flat colors. Every surface interacts with a simulated overhead light source

The overall feeling is premium, tactile, and satisfying. Elements have weight and dimension. Interactions feel like pressing real buttons. Surfaces compress inward on click. The monochromatic palette keeps the focus on form and shadow rather than color.

## 2. Color Palette & Roles

### Dark Mode (Primary)
| Role | Value | Usage |
|------|-------|-------|
| Background | `#2d2d3d` | Page background (the "surface material") |
| Surface Same | `#2d2d3d` | Cards match background (neumorphism requirement) |
| Shadow Dark | `rgba(0, 0, 0, 0.4)` | Bottom-right shadow |
| Shadow Light | `rgba(255, 255, 255, 0.03)` | Top-left highlight |
| Shadow Dark Inset | `rgba(0, 0, 0, 0.35)` | Inset bottom-right |
| Shadow Light Inset | `rgba(255, 255, 255, 0.02)` | Inset top-left |
| Accent | `#4ade80` | Active states, positive |
| Accent Dim | `#22c55e` | Hover accent |
| Danger | `#f87171` | Stop, destructive |
| Warning | `#fbbf24` | Caution states |
| Text Primary | `#e2e8f0` | Headings, labels |
| Text Secondary | `#94a3b8` | Descriptions |
| Text Muted | `#475569` | Placeholders |
| Track Fill | `#4ade80` | Colored portion of sliders |

### Light Mode (Adapted)
| Role | Value | Usage |
|------|-------|-------|
| Background | `#e0e5ec` | Page background |
| Shadow Dark | `rgba(0, 0, 0, 0.15)` | Bottom-right |
| Shadow Light | `rgba(255, 255, 255, 0.8)` | Top-left highlight |
| Shadow Dark Inset | `rgba(0, 0, 0, 0.12)` | Inset dark |
| Shadow Light Inset | `rgba(255, 255, 255, 0.7)` | Inset light |
| Accent | `#16a34a` | Deeper green for contrast |
| Text Primary | `#1e293b` | Headings |
| Text Secondary | `#64748b` | Descriptions |

## 3. Typography Rules

**Font Stack**: `-apple-system, BlinkMacSystemFont, 'Segoe UI', system-ui, sans-serif`

| Level | Size | Weight | Letter Spacing | Usage |
|-------|------|--------|---------------|-------|
| Title | 18px | 700 | -0.3px | Panel headers |
| Subtitle | 14px | 600 | 0 | Card titles |
| Label | 12px | 500 | 0.3px | Slider/control labels |
| Section | 10px | 700 | 2px | Uppercase section dividers |
| Body | 14px | 400 | 0 | Descriptions |
| Value | 14px | 700 | 0 | Data readouts |
| Value Large | 24px | 700 | -0.5px | Hero metrics |
| Caption | 11px | 400 | 0.2px | Footnotes |

## 4. Component Stylings

### Buttons

**Raised (Primary)**
```css
.btn-raised {
    background: var(--bg);
    color: var(--accent);
    border: none;
    border-radius: 12px;
    padding: 12px 24px;
    font-size: 14px;
    font-weight: 600;
    box-shadow: 6px 6px 12px var(--shadow-dark),
                -6px -6px 12px var(--shadow-light);
    transition: all 200ms cubic-bezier(0.4, 0, 0.2, 1);
}
.btn-raised:hover {
    color: var(--accent-dim);
}
.btn-raised:active {
    box-shadow: inset 4px 4px 8px var(--shadow-dark-inset),
                inset -4px -4px 8px var(--shadow-light-inset);
}
```

**Flat (Secondary)**
```css
.btn-flat {
    background: var(--bg);
    color: var(--text-secondary);
    border: none;
    border-radius: 12px;
    padding: 12px 24px;
    font-size: 14px;
    font-weight: 500;
    box-shadow: 3px 3px 6px var(--shadow-dark),
                -3px -3px 6px var(--shadow-light);
    transition: all 200ms ease;
}
.btn-flat:active {
    box-shadow: inset 3px 3px 6px var(--shadow-dark-inset),
                inset -3px -3px 6px var(--shadow-light-inset);
}
```

**Danger**
```css
.btn-danger {
    background: var(--bg);
    color: var(--danger);
    border: none;
    border-radius: 12px;
    padding: 12px 24px;
    font-weight: 600;
    box-shadow: 6px 6px 12px var(--shadow-dark),
                -6px -6px 12px var(--shadow-light);
}
.btn-danger:active {
    box-shadow: inset 4px 4px 8px var(--shadow-dark-inset),
                inset -4px -4px 8px var(--shadow-light-inset);
}
```

### Sliders

```css
.slider-track {
    width: 100%;
    height: 8px;
    border-radius: 4px;
    background: var(--bg);
    box-shadow: inset 3px 3px 6px var(--shadow-dark-inset),
                inset -3px -3px 6px var(--shadow-light-inset);
    position: relative;
}
input[type="range"] {
    -webkit-appearance: none;
    width: 100%;
    height: 8px;
    border-radius: 4px;
    background: transparent;
    outline: none;
    position: relative;
}
input[type="range"]::-webkit-slider-thumb {
    -webkit-appearance: none;
    width: 24px;
    height: 24px;
    border-radius: 50%;
    background: var(--bg);
    box-shadow: 4px 4px 8px var(--shadow-dark),
                -4px -4px 8px var(--shadow-light),
                inset 1px 1px 2px var(--shadow-light);
    cursor: pointer;
    transition: box-shadow 150ms ease;
}
input[type="range"]:active::-webkit-slider-thumb {
    box-shadow: 2px 2px 4px var(--shadow-dark),
                -2px -2px 4px var(--shadow-light);
}
input[type="range"]::-moz-range-thumb {
    width: 24px;
    height: 24px;
    border-radius: 50%;
    background: var(--bg);
    border: none;
    box-shadow: 4px 4px 8px var(--shadow-dark),
                -4px -4px 8px var(--shadow-light);
}
```

### Toggles

```css
.toggle {
    width: 52px;
    height: 28px;
    border-radius: 14px;
    background: var(--bg);
    box-shadow: inset 4px 4px 8px var(--shadow-dark-inset),
                inset -4px -4px 8px var(--shadow-light-inset);
    position: relative;
    cursor: pointer;
    transition: all 300ms cubic-bezier(0.4, 0, 0.2, 1);
}
.toggle.active {
    background: var(--accent);
    box-shadow: inset 4px 4px 8px rgba(0, 0, 0, 0.2),
                inset -4px -4px 8px rgba(255, 255, 255, 0.05);
}
.toggle::after {
    content: '';
    position: absolute;
    width: 22px;
    height: 22px;
    border-radius: 50%;
    background: var(--bg);
    top: 3px;
    left: 3px;
    box-shadow: 3px 3px 6px var(--shadow-dark),
                -3px -3px 6px var(--shadow-light);
    transition: transform 300ms cubic-bezier(0.4, 0, 0.2, 1);
}
.toggle.active::after {
    transform: translateX(24px);
    background: #FFFFFF;
    box-shadow: 2px 2px 4px rgba(0, 0, 0, 0.2);
}
```

### Cards / Panels

```css
.panel {
    background: var(--bg);
    border-radius: 16px;
    padding: 20px;
    box-shadow: 8px 8px 16px var(--shadow-dark),
                -8px -8px 16px var(--shadow-light);
    border: none;
    animation: fadeIn 0.4s ease-out both;
}
```

## 5. Layout Principles

- **Base unit**: 8px; common spacings: 8, 12, 16, 20, 24, 32
- **Content margins**: 20px outer padding
- **Panel padding**: 20px internal
- **Panel gap**: 24px between panels (extra gap needed; shadows need breathing room)
- **Border radius**: 16px on panels, 12px on buttons, 50% on circular elements
- **Critical rule**: Card background MUST match page background color. Neumorphism breaks if they differ
- **Alignment**: Left-aligned labels; right-aligned values

## 6. Depth & Elevation

Neumorphism creates depth exclusively through shadow pairs:

| State | Treatment |
|-------|-----------|
| Raised (default) | `8px 8px 16px dark, -8px -8px 16px light` |
| Slightly raised | `4px 4px 8px dark, -4px -4px 8px light` |
| Flat (pressed) | `inset 4px 4px 8px dark, inset -4px -4px 8px light` |
| Recessed (track) | `inset 3px 3px 6px dark, inset -3px -3px 6px light` |
| Floating thumb | `4px 4px 8px dark, -4px -4px 8px light, inset 1px 1px 2px light` |

Light source is always **top-left**. Dark shadows fall bottom-right, light highlights top-left.

**Never use:**
- `border` (breaks the continuous-surface illusion)
- Colored shadows (except on accent-filled elements)
- Flat backgrounds without any shadow treatment

## 7. Motion & Interaction

**Timing curves:**
- Standard: `cubic-bezier(0.4, 0, 0.2, 1)`, 200ms
- Toggle: `cubic-bezier(0.4, 0, 0.2, 1)`, 300ms
- Spring (optional): `cubic-bezier(0.34, 1.56, 0.64, 1)`, 250ms

**Key interactions:**
- **Press (button)**: Shadow transitions from outset to inset; element "pushes in"
- **Release**: Shadow returns to outset; element "pops back out"
- **Hover**: No visual change (neumorphism doesn't use hover highlights)
- **Toggle**: Track fills with accent color, thumb slides
- **Slider drag**: Thumb shadow slightly reduces (pressing down)
- **Appear**: Simple opacity fade (0 to 1, 400ms), no translation

Motion is subtle and physical. The shadow shift on press IS the interaction feedback.

## 8. Do's and Don'ts

### Do
- Match card/panel background to page background exactly (critical for neumorphism)
- Use paired shadows: one dark (bottom-right) + one light (top-left)
- Transition between outset and inset shadows for press interactions
- Keep the color palette monochromatic (one accent only)
- Use inset shadows for recessed elements (tracks, inputs)
- Apply larger shadow spreads on bigger elements, smaller on small ones
- Use green accent for active/positive, red for danger; minimal color

### Don't
- Use borders; they break the continuous-surface illusion
- Apply different background colors to cards vs page background
- Use transparency/blur effects; this style is about solid surfaces
- Apply colored shadows (except subtle accent glow on active elements)
- Use more than one accent color family
- Mix flat elements with neumorphic ones; commit fully to the style
- Add gradient backgrounds; surfaces must be flat solid colors
- Use translateY animations; this style is about shadow depth, not position

## 9. Agent Prompt Guide

When generating Neumorphic Dark style uihtml components:

1. Set ONE background color for both body and all panels (#2d2d3d)
2. Define shadow pairs as CSS variables (dark + light, both outset and inset variants)
3. Panels: same bg color + outset shadow pair (8px spread), NO borders
4. Buttons: same bg, colored text, outset shadow → inset shadow on :active
5. Sliders: inset recessed track (8px height), raised thumb with outset shadows
6. Toggles: inset track, raised thumb, accent fill on active
7. NO borders anywhere; depth comes purely from shadows
8. Accent color appears only as text color or fill, never as shadow
9. Entry: opacity fade only, no translation
10. Extra gap between panels (24px+); shadows need visual breathing room
