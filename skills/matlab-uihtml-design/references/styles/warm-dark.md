# Warm Dark Design System

## 1. Visual Theme & Atmosphere

A dark interface with warm neutral tones and energetic amber/yellow accents. Inspired by smart home apps, IoT dashboards, and health/wellness trackers.

- **Warmth**: Neutral warm grays (not blue-tinted) create a cozy, approachable dark mode
- **Energy**: Bright amber/yellow accents pop against dark surfaces, drawing attention to actions
- **Friendliness**: Rounded shapes, comfortable spacing, and warm whites feel inviting rather than clinical

The overall feeling is modern, approachable, and action-oriented. The amber accent is the star — used for CTAs, active states, and key data. Everything else recedes into warm neutral darks.

## 2. Color Palette & Roles

### Dark Mode (Primary)
| Role | Value | Usage |
|------|-------|-------|
| Background | `#1a1a1a` | Page background |
| Background Alt | `#212121` | Slight variation |
| Surface | `#2a2a2a` | Card backgrounds |
| Surface Elevated | `#333333` | Hover/active cards |
| Accent | `#fbbf24` | Primary actions, active toggles |
| Accent Hover | `#f59e0b` | Hover state |
| Accent Container | `rgba(251, 191, 36, 0.12)` | Tinted backgrounds |
| On Accent | `#1a1a1a` | Text on amber buttons |
| Secondary | `#f97316` | Secondary emphasis (orange) |
| Danger | `#ef4444` | Destructive actions |
| Success | `#22c55e` | Positive states |
| Text Primary | `#fafaf9` | Headings, labels |
| Text Secondary | `#a8a29e` | Descriptions |
| Text Muted | `#57534e` | Placeholders, disabled |
| Border | `rgba(168, 162, 158, 0.15)` | Card borders |
| Track | `rgba(168, 162, 158, 0.2)` | Slider/toggle tracks |

### Light Mode (Adapted)
| Role | Value | Usage |
|------|-------|-------|
| Background | `#fafaf9` | Page background (warm white) |
| Surface | `#FFFFFF` | Cards |
| Accent | `#d97706` | Deeper amber for contrast |
| Accent Hover | `#b45309` | Hover |
| On Accent | `#FFFFFF` | Text on amber buttons |
| Text Primary | `#1c1917` | Headings |
| Text Secondary | `#78716c` | Descriptions |
| Border | `rgba(28, 25, 23, 0.08)` | Borders |

## 3. Typography Rules

**Font Stack**: `-apple-system, BlinkMacSystemFont, 'Segoe UI', system-ui, sans-serif`

| Level | Size | Weight | Letter Spacing | Usage |
|-------|------|--------|---------------|-------|
| Title | 20px | 700 | -0.3px | Panel titles |
| Subtitle | 16px | 600 | 0 | Card headers |
| Body | 14px | 400 | 0.1px | Descriptions |
| Label | 12px | 500 | 0.2px | Component labels |
| Section Label | 10px | 700 | 2px | Uppercase section dividers |
| Value Large | 24px | 700 | -0.5px | Key metrics |
| Value Small | 14px | 600 | 0 | Data readouts |
| Caption | 11px | 400 | 0.2px | Timestamps |

## 4. Component Stylings

### Buttons

**Primary (Amber Filled)**
```css
.btn-primary {
    background: var(--accent);
    color: var(--on-accent);
    border: none;
    border-radius: 12px;
    padding: 12px 24px;
    font-size: 14px;
    font-weight: 600;
    transition: all 200ms cubic-bezier(0.4, 0, 0.2, 1);
    box-shadow: 0 2px 8px rgba(251, 191, 36, 0.2);
}
.btn-primary:hover {
    background: var(--accent-hover);
    box-shadow: 0 4px 16px rgba(251, 191, 36, 0.3);
}
.btn-primary:active { transform: scale(0.97); }
```

**Secondary (Ghost)**
```css
.btn-secondary {
    background: var(--surface-elevated);
    color: var(--text-primary);
    border: 1px solid var(--border);
    border-radius: 12px;
    padding: 12px 24px;
    font-size: 14px;
    font-weight: 500;
    transition: all 200ms ease;
}
.btn-secondary:hover {
    border-color: var(--accent);
    color: var(--accent);
}
.btn-secondary:active { transform: scale(0.97); }
```

**Danger**
```css
.btn-danger {
    background: var(--danger);
    color: #FFFFFF;
    border: none;
    border-radius: 12px;
    padding: 12px 24px;
    box-shadow: 0 2px 8px rgba(239, 68, 68, 0.2);
}
```

**Circular (Icon/Media control)**
```css
.btn-circle {
    width: 48px;
    height: 48px;
    border-radius: 50%;
    background: var(--accent);
    color: var(--on-accent);
    border: none;
    display: flex;
    align-items: center;
    justify-content: center;
    box-shadow: 0 2px 12px rgba(251, 191, 36, 0.25);
    transition: all 200ms ease;
}
.btn-circle:hover { transform: scale(1.05); }
.btn-circle:active { transform: scale(0.95); }
```

### Sliders

```css
input[type="range"] {
    -webkit-appearance: none;
    width: 100%;
    height: 5px;
    border-radius: 2.5px;
    background: var(--track);
    outline: none;
}
input[type="range"]::-webkit-slider-thumb {
    -webkit-appearance: none;
    width: 18px;
    height: 18px;
    border-radius: 50%;
    background: var(--accent);
    cursor: pointer;
    box-shadow: 0 2px 6px rgba(251, 191, 36, 0.3);
    transition: transform 150ms ease;
}
input[type="range"]:active::-webkit-slider-thumb {
    transform: scale(1.2);
}
input[type="range"]::-moz-range-thumb {
    width: 18px;
    height: 18px;
    border-radius: 50%;
    background: var(--accent);
    border: none;
    box-shadow: 0 2px 6px rgba(251, 191, 36, 0.3);
}
```

### Toggles

```css
.toggle {
    width: 48px;
    height: 28px;
    border-radius: 14px;
    background: var(--track);
    position: relative;
    cursor: pointer;
    transition: background 300ms cubic-bezier(0.4, 0, 0.2, 1);
}
.toggle.active {
    background: var(--accent);
    box-shadow: 0 0 8px rgba(251, 191, 36, 0.2);
}
.toggle::after {
    content: '';
    position: absolute;
    width: 22px;
    height: 22px;
    border-radius: 50%;
    background: var(--text-secondary);
    top: 3px;
    left: 3px;
    transition: all 300ms cubic-bezier(0.4, 0, 0.2, 1);
}
.toggle.active::after {
    transform: translateX(20px);
    background: var(--on-accent);
}
```

### Cards

```css
.card {
    background: var(--surface);
    border-radius: 16px;
    padding: 16px;
    border: 1px solid var(--border);
    transition: background 200ms ease;
    animation: fadeSlideIn 0.4s ease-out both;
}
.card:hover {
    background: var(--surface-elevated);
}
```

## 5. Layout Principles

- **Base unit**: 4px; common spacings: 4, 8, 12, 16, 20, 24
- **Content margins**: 16px outer padding
- **Card padding**: 16px internal
- **Card gap**: 12px between cards
- **Grid**: 2-column grid for small cards (icons, stats), single column for controls
- **Border radius**: 16px on cards, 12px on buttons, 14px on toggles
- **Circular elements**: Use for media controls, icon buttons (48px diameter)

## 6. Depth & Elevation

Warm shadows with no blue cast:

| Layer | Treatment |
|-------|-----------|
| Background | Flat warm dark |
| Cards | 1px warm border, no shadow by default |
| Cards (hover) | Background lightens to surface-elevated |
| Elevated | `0 4px 16px rgba(0, 0, 0, 0.3)` (neutral, not blue) |
| Active accent | `0 2px 12px rgba(251, 191, 36, 0.25)` (amber glow) |
| Floating | `0 8px 32px rgba(0, 0, 0, 0.4)` |

Key rule: shadows are always warm-neutral or accent-tinted — never cool/blue.

## 7. Motion & Interaction

**Timing curves:**
- Standard: `cubic-bezier(0.4, 0, 0.2, 1)` — 200ms
- Toggle/expand: `cubic-bezier(0.4, 0, 0.2, 1)` — 300ms
- Bounce: `cubic-bezier(0.34, 1.56, 0.64, 1)` — 250ms (circular buttons)

**Key interactions:**
- **Press (buttons)**: Scale 0.97
- **Press (circular)**: Scale 0.95 (more dramatic for round shapes)
- **Hover (primary)**: Darken amber, increase shadow
- **Hover (card)**: Background surface elevation shift
- **Hover (circular)**: Scale 1.05 (grow slightly)
- **Toggle**: Smooth 300ms slide + color transition
- **Appear**: Fade + translateY(6px → 0), stagger 0.06s per card

**Entry animation:**
```css
@keyframes fadeSlideIn {
    from { opacity: 0; transform: translateY(6px); }
    to { opacity: 1; transform: translateY(0); }
}
.card:nth-child(1) { animation-delay: 0s; }
.card:nth-child(2) { animation-delay: 0.06s; }
.card:nth-child(3) { animation-delay: 0.12s; }
```

## 8. Do's and Don'ts

### Do
- Use warm grays (#1a1a1a, #2a2a2a) — never blue-tinted darks
- Apply amber/yellow (#fbbf24) as THE accent — it should feel energetic
- Use amber-tinted shadows on accent elements (`rgba(251, 191, 36, ...)`)
- Include circular button variants for media/playback controls
- Use 16px card radius for friendly rounded feel
- Apply warm white (#fafaf9) for text, not pure #FFF
- Support 2-column grid layouts for stat cards

### Don't
- Use cool blues or purples as primary accents — warm palette only
- Apply blue-tinted shadows or backgrounds
- Use glass/blur effects — surfaces are opaque
- Mix more than two warm accent hues (amber + orange max)
- Use border-radius smaller than 12px (except on small elements)
- Apply heavy shadows by default — keep cards flat with border-only definition
- Use uppercase text except for section labels (10px level)

## 9. Agent Prompt Guide

When generating Warm Dark style uihtml components:

1. Start with CSS variables: warm neutrals (#1a1a1a series) + amber accent (#fbbf24)
2. Background: solid warm dark gray (no gradients, no tinting)
3. Cards: #2a2a2a, 16px radius, 1px warm border, no shadow
4. Buttons: 12px radius filled amber (dark text), or ghost with amber hover border
5. Include circular button variant (48px, amber, for media controls)
6. Sliders: 5px track, 18px amber thumb with warm glow shadow
7. Toggles: 48x28px, amber when active, warm shadow
8. Section labels: 10px uppercase, 2px letter-spacing
9. Entry animation: fade + 6px slide, stagger 0.06s
10. Light mode: warm white (#fafaf9) background, deeper amber (#d97706) for contrast
