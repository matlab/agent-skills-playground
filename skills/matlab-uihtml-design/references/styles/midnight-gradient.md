# Midnight Gradient Design System

## 1. Visual Theme & Atmosphere

A premium, luxury aesthetic built on near-black backgrounds with rich blue-to-purple gradient accents. Inspired by automotive configurators, luxury product showcases, and high-end media apps.

- **Richness**: Gradient accents (blue → purple) used on interactive elements create visual depth
- **Contrast**: Near-white text on near-black surfaces for maximum readability with dramatic presence
- **Float**: Cards appear to hover above the void with subtle bottom glow and generous rounded corners

The overall feeling is exclusive, high-tech, and cinematic. Every interactive element has a gradient fill that catches the eye. Large rounded corners and generous spacing give a modern, spacious feel.

## 2. Color Palette & Roles

### Dark Mode (Primary)
| Role | Value | Usage |
|------|-------|-------|
| Background | `#0c0c14` | Page background |
| Background Mid | `#0f0f1a` | Gradient endpoint |
| Surface | `#1a1a2e` | Card backgrounds |
| Surface Elevated | `#222240` | Hover/active cards |
| Gradient Start | `#3b82f6` | Blue end of accent gradient |
| Gradient End | `#8b5cf6` | Purple end of accent gradient |
| Accent Solid | `#6366f1` | Fallback when gradient not applicable |
| Accent Glow | `rgba(99, 102, 241, 0.3)` | Glow shadows |
| Danger | `#f43f5e` | Destructive actions |
| Success | `#10b981` | Positive states |
| Text Primary | `#f1f5f9` | Headings, labels |
| Text Secondary | `#94a3b8` | Descriptions |
| Text Muted | `#475569` | Placeholders, disabled |
| Border | `rgba(99, 102, 241, 0.2)` | Card borders (gradient-tinted) |
| Border Subtle | `rgba(255, 255, 255, 0.06)` | Dividers |

### Light Mode (Adapted)
| Role | Value | Usage |
|------|-------|-------|
| Background | `#f8fafc` | Page background |
| Surface | `#FFFFFF` | Cards |
| Gradient Start | `#2563eb` | Slightly deeper blue |
| Gradient End | `#7c3aed` | Slightly deeper purple |
| Accent Solid | `#4f46e5` | Solid accent |
| Text Primary | `#0f172a` | Headings |
| Text Secondary | `#475569` | Descriptions |
| Border | `rgba(79, 70, 229, 0.15)` | Card borders |

## 3. Typography Rules

**Font Stack**: `'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', system-ui, sans-serif`

| Level | Size | Weight | Letter Spacing | Usage |
|-------|------|--------|---------------|-------|
| Display | 32px | 700 | -0.5px | Hero values |
| Title | 20px | 600 | -0.3px | Card titles |
| Subtitle | 16px | 500 | 0 | Sub-headings |
| Body | 14px | 400 | 0.1px | Descriptions |
| Label | 11px | 600 | 1.5px | Uppercase section labels |
| Value | 14px | 600 | 0 | Data readouts |
| Caption | 12px | 400 | 0.2px | Secondary info |

## 4. Component Stylings

### Buttons

**Primary (Gradient)**
```css
.btn-primary {
    background: linear-gradient(135deg, var(--gradient-start) 0%, var(--gradient-end) 100%);
    color: #FFFFFF;
    border: none;
    border-radius: 12px;
    padding: 12px 24px;
    font-size: 14px;
    font-weight: 600;
    box-shadow: 0 4px 16px var(--accent-glow);
    transition: all 280ms cubic-bezier(0.4, 0, 0.2, 1);
}
.btn-primary:hover {
    box-shadow: 0 6px 24px rgba(99, 102, 241, 0.45);
    transform: translateY(-1px);
}
.btn-primary:active {
    transform: translateY(0) scale(0.98);
    box-shadow: 0 2px 8px var(--accent-glow);
}
```

**Secondary (Glass border)**
```css
.btn-secondary {
    background: rgba(255, 255, 255, 0.03);
    color: var(--text-primary);
    border: 1px solid var(--border);
    border-radius: 12px;
    padding: 12px 24px;
    font-size: 14px;
    font-weight: 500;
    transition: all 250ms ease;
}
.btn-secondary:hover {
    background: rgba(255, 255, 255, 0.06);
    border-color: rgba(99, 102, 241, 0.4);
}
.btn-secondary:active { transform: scale(0.98); }
```

**Danger**
```css
.btn-danger {
    background: linear-gradient(135deg, #f43f5e 0%, #e11d48 100%);
    color: #FFFFFF;
    border: none;
    border-radius: 12px;
    padding: 12px 24px;
    box-shadow: 0 4px 16px rgba(244, 63, 94, 0.3);
}
```

### Sliders

```css
input[type="range"] {
    -webkit-appearance: none;
    width: 100%;
    height: 4px;
    border-radius: 2px;
    background: var(--border-subtle);
    outline: none;
}
input[type="range"]::-webkit-slider-thumb {
    -webkit-appearance: none;
    width: 18px;
    height: 18px;
    border-radius: 50%;
    background: linear-gradient(135deg, var(--gradient-start), var(--gradient-end));
    box-shadow: 0 0 12px var(--accent-glow);
    cursor: pointer;
    transition: all 150ms ease;
}
input[type="range"]:hover::-webkit-slider-thumb {
    transform: scale(1.15);
    box-shadow: 0 0 18px rgba(99, 102, 241, 0.5);
}
input[type="range"]:active::-webkit-slider-thumb {
    transform: scale(1.25);
}
```

### Toggles

```css
.toggle {
    width: 48px;
    height: 26px;
    border-radius: 13px;
    background: rgba(255, 255, 255, 0.06);
    border: 1px solid var(--border-subtle);
    position: relative;
    cursor: pointer;
    transition: all 300ms cubic-bezier(0.4, 0, 0.2, 1);
}
.toggle.active {
    background: linear-gradient(135deg, var(--gradient-start), var(--gradient-end));
    border-color: transparent;
    box-shadow: 0 0 12px var(--accent-glow);
}
.toggle::after {
    content: '';
    position: absolute;
    width: 20px;
    height: 20px;
    border-radius: 50%;
    background: var(--text-secondary);
    top: 2px;
    left: 2px;
    transition: all 300ms cubic-bezier(0.4, 0, 0.2, 1);
}
.toggle.active::after {
    transform: translateX(22px);
    background: #FFFFFF;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.3);
}
```

### Cards

```css
.card {
    background: var(--surface);
    border-radius: 20px;
    padding: 20px;
    border: 1px solid var(--border);
    box-shadow: 0 4px 24px rgba(0, 0, 0, 0.3),
                0 0 1px rgba(99, 102, 241, 0.1);
    animation: fadeFloatIn 0.5s ease-out both;
}
.card:hover {
    border-color: rgba(99, 102, 241, 0.35);
    box-shadow: 0 8px 32px rgba(0, 0, 0, 0.4),
                0 0 16px rgba(99, 102, 241, 0.1);
}
```

## 5. Layout Principles

- **Base unit**: 8px; common spacings: 8, 12, 16, 20, 24, 32
- **Content margins**: 20px outer padding
- **Card padding**: 20-24px internal
- **Card gap**: 16px between panels
- **Border radius**: 20px on cards, 12px on buttons, 50% on thumbs
- **Max width**: 420px for single-column control panels
- **Alignment**: Left-aligned labels; right-aligned numeric values

## 6. Depth & Elevation

Depth via dark-on-darker with accent glow halos:

| Layer | Treatment |
|-------|-----------|
| Background | Solid near-black, optionally with very subtle radial gradient |
| Cards | 1px gradient-tinted border + large diffused shadow |
| Cards (hover) | Brighter border + intensified shadow + subtle glow |
| Active elements | Gradient fill + colored glow (box-shadow) |
| Floating/Modal | `0 16px 48px rgba(0,0,0,0.5), 0 0 24px var(--accent-glow)` |

Gradient border technique (for special cards):
```css
.card-gradient-border {
    position: relative;
    background: var(--surface);
    border-radius: 20px;
}
.card-gradient-border::before {
    content: '';
    position: absolute;
    inset: -1px;
    border-radius: 21px;
    background: linear-gradient(135deg, var(--gradient-start), var(--gradient-end));
    z-index: -1;
    opacity: 0.5;
}
```

## 7. Motion & Interaction

**Timing curves:**
- Standard: `cubic-bezier(0.4, 0, 0.2, 1)` — 280ms
- Decelerate: `cubic-bezier(0, 0, 0.2, 1)` — 400ms (entering)
- Spring: `cubic-bezier(0.34, 1.56, 0.64, 1)` — 350ms (bounce)

**Key interactions:**
- **Hover (buttons)**: Lift up 1px (`translateY(-1px)`), intensify glow
- **Press**: Scale 0.98 + reduce shadow
- **Hover (cards)**: Border brightens, shadow expands
- **Appear**: Fade + float up (12px → 0) with staggered delays
- **Toggle**: Gradient fill sweeps in from left

**Entry animation:**
```css
@keyframes fadeFloatIn {
    from { opacity: 0; transform: translateY(12px); }
    to { opacity: 1; transform: translateY(0); }
}
.card:nth-child(1) { animation-delay: 0s; }
.card:nth-child(2) { animation-delay: 0.08s; }
.card:nth-child(3) { animation-delay: 0.16s; }
```

## 8. Do's and Don'ts

### Do
- Use `linear-gradient(135deg, ...)` on primary buttons and active toggles
- Apply accent-colored `box-shadow` for glow on interactive elements
- Use 20px border-radius on cards for the premium rounded feel
- Keep backgrounds near-black (#0c0c14) — never plain #000
- Include gradient-tinted borders on cards (`rgba` of accent color)
- Use `translateY(-1px)` hover lift for buttons
- Apply generous spacing (20-24px padding)

### Don't
- Use flat solid accent colors on primary buttons — always gradient
- Apply borders thicker than 1px
- Use small border-radius (< 12px) — this style is smooth and rounded
- Skip the glow shadow on active/gradient elements
- Use warm colors for backgrounds — keep it cool (blue/purple undertones)
- Apply blur/glass effects — this style is about gradients and glow, not transparency
- Use animations longer than 500ms for user-triggered interactions

## 9. Agent Prompt Guide

When generating Midnight Gradient style uihtml components:

1. Start with CSS variables for the dual-tone gradient system (blue → purple)
2. Background: solid near-black with cool undertone (#0c0c14)
3. Cards: #1a1a2e background, 20px radius, 1px gradient-tinted border, large shadow
4. Buttons: `linear-gradient(135deg)` fill + glow shadow, 12px radius
5. Sliders: 18px thumb with gradient fill + glow
6. Toggles: 48x26px, gradient active state with glow
7. All interactive elements get accent glow box-shadow on hover/active
8. Entry animation: fade + float up 12px, stagger 0.08s
9. Typography: Inter, -0.5px tracking on titles, 1.5px tracking on uppercase labels
10. For light mode: swap to white surface, deeper gradient colors, reduce glow intensity
