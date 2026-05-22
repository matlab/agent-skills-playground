# Dashboard Light Design System

## 1. Visual Theme & Atmosphere

A clean, professional, data-first aesthetic optimized for information density and readability. Inspired by modern fintech and analytics dashboards.

- **Clarity**: White card surfaces on soft lavender-gray backgrounds ensure maximum content legibility
- **Structure**: Clear visual hierarchy through card grouping, consistent spacing, and typographic scale
- **Precision**: Tabular numbers, aligned data columns, and purposeful color coding for positive/negative values

The overall feeling is trustworthy, professional, and efficient. Surfaces are crisp and clean: no blur, no glass, no gradients. Depth comes from subtle shadows and card stacking. The indigo accent provides a distinct, non-generic identity.

## 2. Color Palette & Roles

### Light Mode
| Role | Value | Usage |
|------|-------|-------|
| Background | `#f0f0f8` | Page background |
| Background Alt | `#e8e8f4` | Section separators |
| Surface | `#FFFFFF` | Cards, panels |
| Primary | `#4338ca` | Key actions, active tabs |
| Primary Light | `#e0e7ff` | Active chips, selected states |
| On Primary | `#FFFFFF` | Text on primary buttons |
| Secondary | `#6366f1` | Secondary actions, links |
| Success | `#16a34a` | Positive values, gains |
| Danger | `#dc2626` | Negative values, losses |
| Warning | `#d97706` | Alerts |
| Text Primary | `#1e1b4b` | Headings, primary data |
| Text Secondary | `#64748b` | Labels, descriptions |
| Text Muted | `#94a3b8` | Placeholders, disabled |
| Border | `#e2e8f0` | Card borders, dividers |
| Border Subtle | `#f1f5f9` | Inner dividers |

### Dark Mode
| Role | Value | Usage |
|------|-------|-------|
| Background | `#0f172a` | Page background |
| Background Alt | `#1e293b` | Section separators |
| Surface | `#1e293b` | Cards, panels |
| Primary | `#818cf8` | Key actions |
| Primary Light | `rgba(129, 140, 248, 0.15)` | Selected states |
| On Primary | `#FFFFFF` | Text on primary |
| Text Primary | `#f1f5f9` | Headings |
| Text Secondary | `#94a3b8` | Labels |
| Text Muted | `#475569` | Placeholders |
| Border | `#334155` | Card borders |

## 3. Typography Rules

**Font Stack**: `'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', system-ui, sans-serif`

| Level | Size | Weight | Letter Spacing | Usage |
|-------|------|--------|---------------|-------|
| Page Title | 24px | 700 | -0.5px | Dashboard headers |
| Card Title | 18px | 600 | -0.3px | Card headers |
| Section Label | 12px | 600 | 0.5px | Uppercase section dividers |
| Body | 14px | 400 | 0 | Descriptions, text |
| Data Large | 28px | 700 | -0.5px | Hero metrics |
| Data Medium | 16px | 600 | 0 | Table values |
| Data Small | 13px | 500 | 0 | Secondary metrics |
| Label | 12px | 500 | 0.1px | Input labels, chips |
| Caption | 11px | 400 | 0.2px | Timestamps, footnotes |

All numeric displays use `font-variant-numeric: tabular-nums` for alignment.

## 4. Component Stylings

### Buttons

**Filled (Primary)**
```css
.btn-filled {
    background: var(--color-primary);
    color: var(--color-on-primary);
    border: none;
    border-radius: 8px;
    padding: 10px 20px;
    font-size: 14px;
    font-weight: 500;
    letter-spacing: 0.1px;
    transition: background 200ms ease, box-shadow 200ms ease;
    box-shadow: 0 1px 3px rgba(67, 56, 202, 0.2);
}
.btn-filled:hover {
    background: #3730a3;
    box-shadow: 0 2px 8px rgba(67, 56, 202, 0.3);
}
.btn-filled:active { transform: scale(0.98); }
```

**Outlined**
```css
.btn-outlined {
    background: transparent;
    color: var(--color-primary);
    border: 1.5px solid var(--color-primary);
    border-radius: 8px;
    padding: 10px 20px;
    font-size: 14px;
    font-weight: 500;
}
.btn-outlined:hover { background: rgba(67, 56, 202, 0.05); }
.btn-outlined:active { transform: scale(0.98); }
```

**Chip/Selector (Segmented)**
```css
.chip {
    background: transparent;
    color: var(--color-text-secondary);
    border: 1.5px solid var(--color-border);
    border-radius: 9999px;
    padding: 6px 16px;
    font-size: 12px;
    font-weight: 500;
    transition: all 200ms ease;
}
.chip.active {
    background: var(--color-primary);
    color: var(--color-on-primary);
    border-color: var(--color-primary);
}
.chip:hover:not(.active) { border-color: var(--color-primary); }
```

### Sliders

```css
input[type="range"] {
    -webkit-appearance: none;
    width: 100%;
    height: 6px;
    border-radius: 3px;
    background: var(--color-border);
    outline: none;
}
input[type="range"]::-webkit-slider-thumb {
    -webkit-appearance: none;
    width: 18px;
    height: 18px;
    border-radius: 50%;
    background: var(--color-primary);
    cursor: pointer;
    box-shadow: 0 2px 6px rgba(67, 56, 202, 0.3);
    transition: transform 150ms ease;
}
input[type="range"]:active::-webkit-slider-thumb {
    transform: scale(1.15);
}
```

### Toggles

```css
.toggle {
    width: 44px;
    height: 24px;
    border-radius: 12px;
    background: var(--color-border);
    position: relative;
    cursor: pointer;
    transition: background 250ms ease;
}
.toggle.active {
    background: var(--color-primary);
}
.toggle::after {
    content: '';
    position: absolute;
    width: 20px;
    height: 20px;
    border-radius: 50%;
    background: #FFFFFF;
    top: 2px;
    left: 2px;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
    transition: transform 250ms cubic-bezier(0.4, 0, 0.2, 1);
}
.toggle.active::after {
    transform: translateX(20px);
}
```

### Cards

```css
.card {
    background: var(--color-surface);
    border-radius: 12px;
    padding: 20px;
    border: 1px solid var(--color-border);
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.04), 0 1px 2px rgba(0, 0, 0, 0.02);
}
```

## 5. Layout Principles

- **Base unit**: 4px; common spacings: 4, 8, 12, 16, 20, 24, 32
- **Content margins**: 20px on compact widths, 24px on regular
- **Card padding**: 16-20px internal
- **Card gap**: 12px between sibling cards
- **Data alignment**: Right-align numeric values; left-align labels
- **Segmented controls**: Horizontal flex with equal-width chips
- **Progress bars**: 6px height, rounded ends, within card context

## 6. Depth & Elevation

Depth via subtle shadows. No blur effects, no transparency:

| Layer | Treatment |
|-------|-----------|
| Background | Flat solid color |
| Cards | `0 1px 3px rgba(0,0,0,0.04), 0 1px 2px rgba(0,0,0,0.02)` |
| Raised cards | `0 4px 12px rgba(0,0,0,0.06), 0 1px 3px rgba(0,0,0,0.04)` |
| Popovers | `0 8px 24px rgba(0,0,0,0.1), 0 2px 8px rgba(0,0,0,0.05)` |
| Active tabs | Colored bottom border (2px) rather than shadow |

## 7. Motion & Interaction

**Timing curves:**
- Standard: `cubic-bezier(0.4, 0, 0.2, 1)`, 200ms
- Decelerate: `cubic-bezier(0, 0, 0.2, 1)`, 250ms for entering
- Spring: `cubic-bezier(0.34, 1.56, 0.64, 1)`, 300ms for chip selection

**Key interactions:**
- **Press**: Scale 0.98, no other visual change
- **Hover (button)**: Darken background slightly, increase shadow
- **Hover (card)**: Slight shadow increase (elevation bump)
- **Tab selection**: Colored underline slides with 250ms transition
- **Chip selection**: Background fill + color change, smooth 200ms
- **Data update**: Fade-in for new values (200ms)
- **Appear**: Fade in with no translation; stagger 0.03s per card

## 8. Do's and Don'ts

### Do
- Use `font-variant-numeric: tabular-nums` for all data columns
- Apply consistent 12px border-radius on cards
- Right-align numeric data, left-align labels
- Use green (#16a34a) for positive, red (#dc2626) for negative values
- Keep shadows minimal; this style is flat-first
- Use pill-shaped chips (9999px radius) for segmented selectors
- Apply 1px borders on cards for crisp definition

### Don't
- Use blur/glass effects; this style is about crisp clarity
- Apply gradients on backgrounds or buttons
- Use rounded corners larger than 12px on cards
- Add glow effects or colored shadows
- Use more than 2 accent colors in one panel
- Make text smaller than 11px; readability is priority
- Use uppercase except for section labels

## 9. Agent Prompt Guide

When generating Dashboard Light style uihtml components:

1. Start with CSS variables for the indigo color system + semantic data colors
2. Apply Inter / system-ui font stack with tabular-nums on data
3. Cards: white background, 12px radius, 1px border, minimal shadow
4. Buttons: 8px radius filled, or 9999px pill for chips/selectors
5. Sliders: 6px track, 18px indigo thumb
6. Toggles: compact 44x24px with indigo active state
7. Data values: large bold numbers with success/danger color coding
8. Layout: 4px grid, 20px card padding, 12px card gaps
9. No glass, no gradients, no glow; crisp and professional
10. Test both light and dark; ensure data remains highly readable in both
