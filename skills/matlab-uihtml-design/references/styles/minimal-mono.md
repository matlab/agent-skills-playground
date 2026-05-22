# Minimal Mono Design System

## 1. Visual Theme & Atmosphere

An ultra-minimal, high-density aesthetic built on monochromatic dark teal-black with a single muted accent color. Inspired by fitness trackers, training apps, and developer tools.

- **Restraint**: Color is used sparingly. Almost everything is gray-scale with one muted lavender accent
- **Density**: Compact typography (11-13px), tight spacing, maximum information per pixel
- **Precision**: Pill shapes, thin rules, mechanical consistency

The overall feeling is technical and focused. The monochromatic palette keeps attention on content and data. The single accent color (muted lavender) appears only where interaction is needed, making affordances immediately clear.

## 2. Color Palette & Roles

### Dark Mode (Primary)
| Role | Value | Usage |
|------|-------|-------|
| Background | `#0a1a1a` | Page background |
| Background Alt | `#0d1f1f` | Subtle variation |
| Surface | `rgba(255, 255, 255, 0.02)` | Cards (barely visible) |
| Surface Hover | `rgba(255, 255, 255, 0.04)` | Card hover |
| Surface Active | `rgba(255, 255, 255, 0.06)` | Pressed/selected |
| Accent | `#a5b4fc` | Interactive elements, active states |
| Accent Muted | `rgba(165, 180, 252, 0.15)` | Accent backgrounds |
| Accent Dim | `#818cf8` | Secondary accent |
| Text Primary | `#e2e8f0` | Headings, data |
| Text Secondary | `#64748b` | Labels, descriptions |
| Text Muted | `#374151` | Disabled, placeholders |
| Border | `rgba(255, 255, 255, 0.06)` | Subtle dividers |
| Track | `rgba(255, 255, 255, 0.08)` | Slider/progress tracks |

### Light Mode (Adapted)
| Role | Value | Usage |
|------|-------|-------|
| Background | `#f0fafa` | Page background (teal-tinted) |
| Surface | `rgba(0, 0, 0, 0.02)` | Cards |
| Accent | `#6366f1` | Interactive elements |
| Accent Muted | `rgba(99, 102, 241, 0.1)` | Accent backgrounds |
| Text Primary | `#0f172a` | Headings |
| Text Secondary | `#475569` | Labels |
| Border | `rgba(0, 0, 0, 0.06)` | Dividers |

## 3. Typography Rules

**Font Stack**: `'SF Mono', 'JetBrains Mono', 'Fira Code', ui-monospace, monospace` for values; `'Inter', -apple-system, system-ui, sans-serif` for labels

| Level | Size | Weight | Letter Spacing | Usage |
|-------|------|--------|---------------|-------|
| Section Label | 9px | 700 | 3px | Uppercase panel headers |
| Label | 11px | 500 | 0.5px | Component labels |
| Body | 13px | 400 | 0 | Descriptions |
| Value Large | 28px | 700 | -1px | Hero metrics |
| Value Medium | 16px | 700 | -0.5px | Key data |
| Value Small | 11px | 600 | 0 | Secondary readouts |
| Caption | 10px | 400 | 0.5px | Timestamps, footnotes |
| Button | 12px | 600 | 0.5px | Button labels |

All labels in uppercase with wide letter-spacing. Numeric values use monospace font with `font-variant-numeric: tabular-nums`.

## 4. Component Stylings

### Buttons

**Primary (Pill)**
```css
.btn-primary {
    background: var(--accent);
    color: #0a1a1a;
    border: none;
    border-radius: 9999px;
    padding: 8px 20px;
    font-size: 12px;
    font-weight: 600;
    letter-spacing: 0.5px;
    transition: all 200ms cubic-bezier(0.4, 0, 0.2, 1);
}
.btn-primary:hover { opacity: 0.85; }
.btn-primary:active { transform: scale(0.96); opacity: 0.7; }
```

**Secondary (Ghost Pill)**
```css
.btn-secondary {
    background: transparent;
    color: var(--text-secondary);
    border: 1px solid var(--border);
    border-radius: 9999px;
    padding: 8px 20px;
    font-size: 12px;
    font-weight: 600;
    letter-spacing: 0.5px;
    transition: all 200ms ease;
}
.btn-secondary:hover {
    color: var(--text-primary);
    border-color: var(--accent);
}
.btn-secondary:active { transform: scale(0.96); }
```

**Muted (Barely-there)**
```css
.btn-muted {
    background: var(--surface-active);
    color: var(--text-secondary);
    border: none;
    border-radius: 9999px;
    padding: 8px 20px;
    font-size: 12px;
    font-weight: 500;
}
.btn-muted:hover { color: var(--text-primary); }
```

### Sliders

```css
input[type="range"] {
    -webkit-appearance: none;
    width: 100%;
    height: 3px;
    border-radius: 1.5px;
    background: var(--track);
    outline: none;
}
input[type="range"]::-webkit-slider-thumb {
    -webkit-appearance: none;
    width: 12px;
    height: 12px;
    border-radius: 50%;
    background: var(--accent);
    cursor: pointer;
    transition: transform 150ms ease;
}
input[type="range"]:active::-webkit-slider-thumb {
    transform: scale(1.3);
}
input[type="range"]::-moz-range-thumb {
    width: 12px;
    height: 12px;
    border-radius: 50%;
    background: var(--accent);
    border: none;
}
```

### Toggles

```css
.toggle {
    width: 36px;
    height: 20px;
    border-radius: 10px;
    background: var(--track);
    position: relative;
    cursor: pointer;
    transition: background 250ms ease;
}
.toggle.active {
    background: var(--accent);
}
.toggle::after {
    content: '';
    position: absolute;
    width: 14px;
    height: 14px;
    border-radius: 50%;
    background: var(--text-muted);
    top: 3px;
    left: 3px;
    transition: all 250ms cubic-bezier(0.4, 0, 0.2, 1);
}
.toggle.active::after {
    transform: translateX(16px);
    background: #0a1a1a;
}
```

### Cards / Panels

```css
.panel {
    background: var(--surface);
    border-radius: 12px;
    padding: 14px 16px;
    border: 1px solid var(--border);
    animation: fadeIn 0.3s ease-out both;
}
```

### Progress Bars

```css
.progress {
    width: 100%;
    height: 3px;
    border-radius: 1.5px;
    background: var(--track);
    overflow: hidden;
}
.progress-fill {
    height: 100%;
    border-radius: 1.5px;
    background: var(--accent);
    transition: width 400ms cubic-bezier(0.4, 0, 0.2, 1);
}
```

## 5. Layout Principles

- **Base unit**: 4px; common spacings: 4, 8, 12, 14, 16, 20
- **Content padding**: 12-16px outer container
- **Panel padding**: 14-16px internal
- **Component spacing**: 12px between controls within a section
- **Panel gap**: 12px between panels
- **Compact density**: Favor tight spacing; controls should feel packed but not cramped
- **Alignment**: Left-aligned labels; right-aligned values
- **Max width**: 360px for control panels (narrow, focused)

## 6. Depth & Elevation

Depth is almost non-existent; flatness IS the aesthetic:

| Layer | Treatment |
|-------|-----------|
| Background | Solid dark teal-black |
| Panels | 2% white overlay + 1px border, barely distinguishable |
| Hover | 4% white overlay, just noticeable |
| Active/Focus | Accent color border or background tint |
| No shadows | This style never uses box-shadow for elevation |

The only depth cue is opacity variation in surfaces.

## 7. Motion & Interaction

**Timing curves:**
- Standard: `cubic-bezier(0.4, 0, 0.2, 1)` at 200ms
- Quick: `ease` at 150ms

**Key interactions:**
- **Press**: Scale 0.96 for a quick, mechanical feel
- **Hover (button)**: Color/opacity shift only, no movement
- **Hover (card)**: Surface opacity increase (0.02 → 0.04)
- **Toggle**: Smooth slide, no bounce
- **Appear**: Simple fade (300ms), no translation
- **Data change**: Opacity flash (0 → 1 in 200ms)

Motion is deliberately minimal. No spring physics, no overshoot, no stagger.

## 8. Do's and Don'ts

### Do
- Use `border-radius: 9999px` on ALL buttons (pill shape is mandatory)
- Apply uppercase + wide letter-spacing (2-3px) on section labels
- Keep accent color to ONE hue (lavender); never introduce a second accent
- Use monospace font for numeric values
- Keep font sizes in 10-13px range for controls (compact density)
- Use 3px track height for sliders and progress bars
- Apply `font-variant-numeric: tabular-nums` on all numbers

### Don't
- Use shadows; this style is shadow-free
- Apply gradients of any kind
- Use font sizes above 14px for controls (except hero metrics)
- Add glow effects or colored shadows
- Use rounded corners other than 9999px (pills) or 12px (cards)
- Apply entrance animations with translation; fade only
- Use more than 6% white opacity for surfaces
- Add decorative elements; every pixel must be functional

## 9. Agent Prompt Guide

When generating Minimal Mono style uihtml components:

1. Start with CSS variables: dark teal-black background, single lavender accent
2. Background: solid #0a1a1a (dark teal-black, no gradients)
3. Panels: `rgba(255,255,255,0.02)` + 1px border + 12px radius, barely visible
4. ALL buttons: pill shape (9999px), small (8px 20px padding), 12px font
5. Sliders: 3px track, 12px accent-colored thumb
6. Toggles: compact 36x20px, accent when active
7. Labels: 9-11px uppercase with 2-3px letter-spacing
8. No shadows, no gradients, no glow; absolute flatness
9. Monospace font for numeric displays
10. Entry: simple fade only, no translateY, no stagger
