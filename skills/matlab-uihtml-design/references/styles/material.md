# Material Design 3 System

## 1. Visual Theme & Atmosphere

Google's Material Design 3 (Material You). The core principles are **adaptive**, **expressive**, and **personal**.

- **Adaptive**: Tonal surfaces that shift with context; dynamic color from content
- **Expressive**: Rounded shapes, bold color accents, playful motion
- **Personal**: Customizable color schemes derived from a single seed color

The overall feeling is warm, modern, and approachable. Surfaces use tonal elevation (color shifts, not just shadows) to create depth. Interactions feature ripple effects and smooth state transitions.

## 2. Color Palette & Roles

### Light Mode (Baseline — Purple seed)
| Role | Value | Usage |
|------|-------|-------|
| Background | `#FEF7FF` | Page background |
| Surface | `#FEF7FF` | Cards at elevation 0 |
| Surface Container | `#F3EDF7` | Elevated containers |
| Surface Container High | `#ECE6F0` | Higher elevation |
| Primary | `#6750A4` | Key actions, FABs |
| Primary Container | `#EADDFF` | Filled cards, chips |
| On Primary | `#FFFFFF` | Text on primary |
| On Primary Container | `#21005D` | Text on primary container |
| Secondary | `#625B71` | Secondary actions |
| Secondary Container | `#E8DEF8` | Secondary chips, selections |
| Tertiary | `#7D5260` | Contrast accents |
| Error | `#B3261E` | Error states |
| Outline | `#79747E` | Borders, dividers |
| Outline Variant | `#CAC4D0` | Subtle borders |
| On Surface | `#1D1B20` | Primary text |
| On Surface Variant | `#49454F` | Secondary text |

### Dark Mode
| Role | Value | Usage |
|------|-------|-------|
| Background | `#141218` | Page background |
| Surface | `#141218` | Base surface |
| Surface Container | `#211F26` | Elevated containers |
| Surface Container High | `#2B2930` | Higher elevation |
| Primary | `#D0BCFF` | Key actions |
| Primary Container | `#4F378B` | Filled cards |
| On Primary | `#381E72` | Text on primary |
| On Primary Container | `#EADDFF` | Text on primary container |
| Secondary | `#CCC2DC` | Secondary actions |
| Error | `#F2B8B5` | Error states |
| Outline | `#938F99` | Borders |
| Outline Variant | `#49454F` | Subtle borders |
| On Surface | `#E6E0E9` | Primary text |
| On Surface Variant | `#CAC4D0` | Secondary text |

## 3. Typography Rules

**Font Stack**: `'Roboto Flex', 'Google Sans', Roboto, system-ui, sans-serif`

Material 3 uses a type scale with specific roles:

| Role | Size | Weight | Line Height | Tracking | Usage |
|------|------|--------|-------------|----------|-------|
| Display Large | 57px | 400 | 64px | -0.25px | Hero text |
| Display Medium | 45px | 400 | 52px | 0 | Large headers |
| Headline Large | 32px | 400 | 40px | 0 | Page titles |
| Headline Medium | 28px | 400 | 36px | 0 | Section titles |
| Title Large | 22px | 400 | 28px | 0 | Card titles |
| Title Medium | 16px | 500 | 24px | 0.15px | Component labels |
| Title Small | 14px | 500 | 20px | 0.1px | Sub-labels |
| Body Large | 16px | 400 | 24px | 0.5px | Body text |
| Body Medium | 14px | 400 | 20px | 0.25px | Descriptions |
| Body Small | 12px | 400 | 16px | 0.4px | Captions |
| Label Large | 14px | 500 | 20px | 0.1px | Button text |
| Label Medium | 12px | 500 | 16px | 0.5px | Chips, badges |
| Label Small | 11px | 500 | 16px | 0.5px | Micro labels |

## 4. Component Stylings

### Buttons

**Filled**
```css
.btn-filled {
    background: var(--md-primary);
    color: var(--md-on-primary);
    border: none;
    border-radius: 20px;
    padding: 10px 24px;
    font-size: 14px;
    font-weight: 500;
    letter-spacing: 0.1px;
    height: 40px;
    position: relative;
    overflow: hidden;
    transition: box-shadow 200ms ease, background 200ms ease;
    box-shadow: 0 1px 3px rgba(0,0,0,0.12), 0 1px 2px rgba(0,0,0,0.24);
}
.btn-filled:hover {
    box-shadow: 0 3px 6px rgba(0,0,0,0.16), 0 3px 6px rgba(0,0,0,0.23);
}
.btn-filled:active { transform: scale(0.98); }
```

**Outlined**
```css
.btn-outlined {
    background: transparent;
    color: var(--md-primary);
    border: 1px solid var(--md-outline);
    border-radius: 20px;
    padding: 10px 24px;
    font-size: 14px;
    font-weight: 500;
    height: 40px;
}
.btn-outlined:hover { background: rgba(103, 80, 164, 0.08); }
```

**Tonal**
```css
.btn-tonal {
    background: var(--md-secondary-container);
    color: var(--md-on-secondary-container);
    border: none;
    border-radius: 20px;
    padding: 10px 24px;
    height: 40px;
}
```

### Sliders

```css
input[type="range"] {
    -webkit-appearance: none;
    width: 100%;
    height: 4px;
    border-radius: 2px;
    background: var(--md-surface-container-high);
    outline: none;
}
input[type="range"]::-webkit-slider-thumb {
    -webkit-appearance: none;
    width: 20px;
    height: 20px;
    border-radius: 50%;
    background: var(--md-primary);
    cursor: pointer;
    box-shadow: 0 1px 3px rgba(0,0,0,0.2);
    transition: transform 150ms ease, box-shadow 150ms ease;
}
input[type="range"]:hover::-webkit-slider-thumb {
    box-shadow: 0 0 0 8px rgba(103, 80, 164, 0.12);
}
input[type="range"]:active::-webkit-slider-thumb {
    transform: scale(1.2);
    box-shadow: 0 0 0 12px rgba(103, 80, 164, 0.12);
}
```

### Toggles (Switch)

```css
.switch {
    width: 52px;
    height: 32px;
    border-radius: 16px;
    background: var(--md-surface-container-high);
    border: 2px solid var(--md-outline);
    position: relative;
    cursor: pointer;
    transition: background 300ms ease, border-color 300ms ease;
}
.switch.active {
    background: var(--md-primary);
    border-color: var(--md-primary);
}
.switch::after {
    content: '';
    position: absolute;
    width: 16px;
    height: 16px;
    border-radius: 50%;
    background: var(--md-outline);
    top: 6px;
    left: 6px;
    transition: transform 300ms cubic-bezier(0.175, 0.885, 0.32, 1.275),
                width 300ms ease, height 300ms ease, background 300ms ease;
}
.switch.active::after {
    transform: translateX(20px);
    width: 24px;
    height: 24px;
    top: 2px;
    left: 2px;
    background: var(--md-on-primary);
}
```

### Cards

```css
.card {
    background: var(--md-surface-container);
    border-radius: 12px;
    padding: 16px;
    border: none;
    transition: box-shadow 200ms ease, background 200ms ease;
}
.card:hover {
    background: var(--md-surface-container-high);
    box-shadow: 0 2px 8px rgba(0,0,0,0.08);
}
```

## 5. Layout Principles

- **Base unit**: 4px grid; common spacings: 4, 8, 12, 16, 24, 32, 48
- **Content margins**: 16px compact, 24px medium
- **Component height**: Buttons 40px, Text fields 56px, Chips 32px
- **Card padding**: 16px internal, 12px gap between cards
- **Corner radius scale**: Small (8px), Medium (12px), Large (16px), Extra Large (28px), Full (9999px for pills)
- **Alignment**: Start-aligned labels; components fill available width

## 6. Depth & Elevation

Material 3 uses **tonal elevation** — surfaces get lighter (in light mode) or lighter (in dark mode) as they rise:

| Level | Shadow | Surface Tint | Usage |
|-------|--------|-------------|-------|
| 0 | None | None | Background |
| 1 | `0 1px 2px rgba(0,0,0,0.3)` | 5% primary | Cards |
| 2 | `0 2px 6px rgba(0,0,0,0.15)` | 8% primary | Raised buttons |
| 3 | `0 4px 8px rgba(0,0,0,0.12)` | 11% primary | Navigation |
| 4 | `0 6px 12px rgba(0,0,0,0.1)` | 12% primary | Modals |
| 5 | `0 8px 16px rgba(0,0,0,0.08)` | 14% primary | FAB |

## 7. Motion & Interaction

**Timing curves:**
- Emphasized: `cubic-bezier(0.2, 0, 0, 1)` (800ms) — large transitions
- Emphasized Decelerate: `cubic-bezier(0.05, 0.7, 0.1, 1)` (400ms) — entering
- Emphasized Accelerate: `cubic-bezier(0.3, 0, 0.8, 0.15)` (200ms) — exiting
- Standard: `cubic-bezier(0.2, 0, 0, 1)` (300ms) — general

**Key interactions:**
- **Ripple**: Circular expansion from touch point, opacity 0.12 of on-surface color
- **Press**: Scale 0.98, state layer opacity increase
- **Hover**: State layer at 8% opacity
- **Focus**: State layer at 12% opacity
- **Appear**: Fade in + scale from 0.92 → 1.0

**State layers** (overlay on interactive elements):
```css
.interactive::before {
    content: '';
    position: absolute;
    inset: 0;
    border-radius: inherit;
    background: currentColor;
    opacity: 0;
    transition: opacity 200ms ease;
}
.interactive:hover::before { opacity: 0.08; }
.interactive:active::before { opacity: 0.12; }
```

## 8. Do's and Don'ts

### Do
- Use tonal elevation (surface color shifts) rather than heavy shadows
- Apply 20px border-radius on buttons (full pill shape)
- Use state layers (semi-transparent overlays) for hover/focus/press
- Keep shadows soft and minimal — Material 3 prefers color over shadow
- Use the `outline` and `outline-variant` tokens for borders
- Apply font-weight 500 for interactive labels
- Respect the 40px minimum touch target

### Don't
- Use hard/dark shadows — Material 3 is flat-first
- Apply border-radius less than 8px (feels dated)
- Use pure black (`#000`) or pure white (`#FFF`) for text — use on-surface tokens
- Skip the ripple/state-layer on interactive elements
- Use outline borders on filled buttons
- Mix rounded and sharp corners in the same view
- Apply letter-spacing above 0.5px (except Label Small)

## 9. Agent Prompt Guide

When generating Material 3 style uihtml components:

1. Start with the tonal color system (primary, secondary, surface containers)
2. Apply Roboto / system-ui font stack with Material 3 type scale
3. Buttons: 20px full border-radius, 40px height, 500 weight labels
4. Sliders: 20px round thumb, primary color, hover ring effect
5. Toggles: 52x32px switch with expanding thumb on activation
6. Cards: 12px radius, tonal surface backgrounds, minimal shadow
7. All interactive elements need state layers (::before pseudo-element)
8. Use 4px spacing grid; 16-24px content margins
9. Motion: 300ms standard curve for most transitions
10. Test both light and dark — tonal elevation should be visible in both
