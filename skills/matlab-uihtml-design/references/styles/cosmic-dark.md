# Cosmic Dark Design System

## 1. Visual Theme & Atmosphere

Deep space aesthetic with a premium, immersive feel. Inspired by spacecraft interfaces, planetarium software, and sci-fi control panels.

- **Depth**: Multiple layers of translucent glass floating over a void-like background
- **Luminance**: Neon-like accent glows that cast soft colored light
- **Mystery**: Deep purples and blues evoke infinite cosmic space

The overall feeling is dramatic, immersive, and high-tech. Controls feel like they're floating in space, with subtle glow effects that make interactions feel energetic. Best suited for data visualization apps, 3D viewers, media players, and creative tools.

## 2. Color Palette & Roles

### Dark Mode (Primary — this style is dark-first)
| Role | Value | Usage |
|------|-------|-------|
| Background Deep | `#0a0a18` | Page background base |
| Background Mid | `#10102a` | Gradient endpoint |
| Surface Glass | `rgba(255, 255, 255, 0.03)` | Card/panel background |
| Surface Glass Hover | `rgba(255, 255, 255, 0.05)` | Card hover state |
| Glass Border | `rgba(255, 255, 255, 0.07)` | Panel borders |
| Glass Highlight | `rgba(255, 255, 255, 0.06)` | Top-edge inner glow |
| Accent Primary | `#7c6cf0` | Primary actions, active states |
| Accent Secondary | `#a78bfa` | Hover states, highlights |
| Accent Glow | `rgba(124, 108, 240, 0.35)` | Soft glow shadows |
| Accent Glow Strong | `rgba(124, 108, 240, 0.55)` | Active/hover glow |
| Danger | `#f472b6` | Stop, destructive actions |
| Danger Glow | `rgba(244, 114, 182, 0.35)` | Danger glow effect |
| Text Primary | `#e8e8f0` | Headings, labels |
| Text Secondary | `#8b8fa8` | Descriptions |
| Text Muted | `#5a5e78` | Placeholders, disabled |

### Light Mode (Adapted)
| Role | Value | Usage |
|------|-------|-------|
| Background | `#f0f0f8` | Page background |
| Surface | `rgba(255, 255, 255, 0.8)` | Cards with blur |
| Accent Primary | `#5b4cc4` | Slightly darker for contrast |
| Accent Secondary | `#7c6cf0` | Hover |
| Text Primary | `#1a1a2e` | Headings |
| Text Secondary | `#4a4e68` | Secondary |
| Border | `rgba(0, 0, 0, 0.08)` | Subtle borders |

## 3. Typography Rules

**Font Stack**: `'Segoe UI', 'SF Pro Display', -apple-system, system-ui, sans-serif`

| Level | Size | Weight | Letter Spacing | Usage |
|-------|------|--------|---------------|-------|
| Panel Title | 10px | 700 | 3px | Uppercase panel headers |
| Section Label | 10px | 700 | 2px | Uppercase section dividers |
| Component Label | 11px | 500 | 0 | Slider/input labels |
| Value Display | 11px | 700 | 0 | Numeric readouts |
| Button Text | 13px | 600 | 0.5px | Button labels |
| Body | 13px | 400 | 0 | Descriptions |

Typography is deliberately compact — this design favors dense information displays where controls take minimal visual space but remain legible.

## 4. Component Stylings

### Buttons

**Primary (Glow)**
```css
.btn-primary {
    background: var(--accent-primary);
    color: white;
    border: none;
    border-radius: 8px;
    padding: 9px 18px;
    font-size: 13px;
    font-weight: 600;
    letter-spacing: 0.5px;
    box-shadow: 0 0 16px var(--accent-glow), 0 2px 8px rgba(0, 0, 0, 0.3);
    transition: all 280ms cubic-bezier(0.4, 0, 0.2, 1);
}
.btn-primary:hover {
    background: var(--accent-secondary);
    box-shadow: 0 0 24px var(--accent-glow-strong), 0 2px 12px rgba(0, 0, 0, 0.4);
    transform: scale(1.03);
}
.btn-primary:active { transform: scale(0.97); }
```

**Secondary (Ghost)**
```css
.btn-secondary {
    background: transparent;
    color: var(--text-secondary);
    border: 1px solid var(--glass-border);
    border-radius: 8px;
    padding: 9px 18px;
    font-size: 13px;
    font-weight: 600;
}
.btn-secondary:hover {
    background: rgba(255, 255, 255, 0.06);
    border-color: rgba(255, 255, 255, 0.15);
    color: var(--text-primary);
    transform: scale(1.03);
}
.btn-secondary:active { transform: scale(0.97); }
```

**Danger (Pulsing)**
```css
.btn-danger {
    background: var(--danger);
    color: white;
    box-shadow: 0 0 16px var(--danger-glow), 0 2px 8px rgba(0, 0, 0, 0.3);
    animation: subtlePulse 2s ease-in-out infinite;
}
@keyframes subtlePulse {
    0%, 100% { box-shadow: 0 0 12px var(--danger-glow); }
    50% { box-shadow: 0 0 22px rgba(244, 114, 182, 0.5); }
}
```

### Sliders

```css
input[type="range"] {
    -webkit-appearance: none;
    width: 100%;
    height: 4px;
    border-radius: 2px;
    background: var(--bg-deep);
    box-shadow: inset 0 1px 2px rgba(0, 0, 0, 0.5);
    outline: none;
}
input[type="range"]::-webkit-slider-thumb {
    -webkit-appearance: none;
    width: 14px;
    height: 14px;
    border-radius: 50%;
    background: radial-gradient(circle at 40% 40%, var(--accent-secondary) 0%, var(--accent-primary) 100%);
    box-shadow: 0 0 8px var(--accent-glow), 0 2px 4px rgba(0, 0, 0, 0.3);
    cursor: pointer;
    transition: all 150ms cubic-bezier(0.4, 0, 0.2, 1);
}
input[type="range"]::-webkit-slider-thumb:hover {
    transform: scale(1.2);
    box-shadow: 0 0 14px var(--accent-glow-strong);
}
input[type="range"]:active::-webkit-slider-thumb {
    transform: scale(1.3);
    box-shadow: 0 0 18px var(--accent-glow-strong);
}
```

### Toggles

```css
.toggle {
    width: 44px;
    height: 24px;
    border-radius: 12px;
    background: var(--bg-deep);
    border: 1px solid var(--glass-border);
    position: relative;
    cursor: pointer;
    transition: all 280ms cubic-bezier(0.4, 0, 0.2, 1);
}
.toggle.active {
    background: var(--accent-primary);
    border-color: var(--accent-primary);
    box-shadow: 0 0 12px var(--accent-glow);
}
.toggle::after {
    content: '';
    position: absolute;
    width: 18px;
    height: 18px;
    border-radius: 50%;
    background: var(--text-secondary);
    top: 2px;
    left: 2px;
    transition: all 280ms cubic-bezier(0.4, 0, 0.2, 1);
}
.toggle.active::after {
    transform: translateX(20px);
    background: white;
    box-shadow: 0 0 6px var(--accent-glow);
}
```

### Cards / Panels

```css
.panel {
    background: var(--glass-bg);
    -webkit-backdrop-filter: blur(12px);
    backdrop-filter: blur(12px);
    border-radius: 14px;
    padding: 16px 18px;
    border: 1px solid var(--glass-border);
    box-shadow:
        inset 0 1px 0 var(--glass-highlight),
        0 4px 24px rgba(0, 0, 0, 0.3),
        0 0 1px rgba(255, 255, 255, 0.05);
    animation: fadeSlideIn 0.4s ease-out both;
}
@keyframes fadeSlideIn {
    from { opacity: 0; transform: translateY(8px); }
    to { opacity: 1; transform: translateY(0); }
}
```

## 5. Layout Principles

- **Base unit**: 4px; common spacings: 4, 8, 12, 14, 16, 18, 24
- **Content padding**: 14px outer container, 16-18px inside panels
- **Component spacing**: 14-16px between controls within a section
- **Section spacing**: 16px gap between panels
- **Layout**: Flexbox column with gap; grid for multi-column slider arrangements
- **Compact density**: This style favors information density — small fonts, tight spacing
- **Background**: Multi-layer radial gradients for cosmic depth effect:
```css
background:
    radial-gradient(ellipse at 20% 0%, rgba(60, 40, 120, 0.15) 0%, transparent 60%),
    radial-gradient(ellipse at 80% 100%, rgba(30, 50, 100, 0.12) 0%, transparent 60%),
    linear-gradient(180deg, var(--bg-deep) 0%, var(--bg-mid) 100%);
```

## 6. Depth & Elevation

Uses glassmorphism layering:

| Layer | Treatment |
|-------|-----------|
| Background | Multi-gradient cosmic void |
| Panels | Glass: translucent fill + backdrop-blur(12px) + subtle border |
| Panel hover | Slightly brighter glass fill |
| Active elements | Colored glow halos (box-shadow with accent color) |
| Floating | Stronger glow + larger shadow spread |

Key depth technique — the **inset highlight**:
```css
box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.06); /* top-edge light catch */
```

## 7. Motion & Interaction

**Timing curves:**
- Fast interactions: `150ms cubic-bezier(0.4, 0, 0.2, 1)`
- Medium transitions: `280ms cubic-bezier(0.4, 0, 0.2, 1)`
- Entry animations: `400ms ease-out`

**Key interactions:**
- **Hover**: Scale up slightly (1.03), intensify glow
- **Press**: Scale down (0.97), brief compression
- **Appear**: Fade + slide up (8px), staggered with `animation-delay`
- **Active state (playing)**: Subtle pulsing glow animation (2s loop)
- **Glow intensification**: Box-shadow spread increases on hover

**Stagger pattern for multiple panels:**
```css
.panel:nth-child(1) { animation-delay: 0s; }
.panel:nth-child(2) { animation-delay: 0.1s; }
.panel:nth-child(3) { animation-delay: 0.2s; }
```

## 8. Do's and Don'ts

### Do
- Use radial gradients for background atmosphere
- Apply `backdrop-filter: blur(12px)` on all surface panels
- Use accent-colored `box-shadow` for glow effects on active elements
- Include inset top-edge highlight (`inset 0 1px 0`) on glass panels
- Use radial gradients on slider thumbs for a 3D-sphere look
- Apply scale(1.03) on hover, scale(0.97) on active
- Stagger entry animations for visual rhythm
- Use tabular-nums for numeric displays

### Don't
- Use flat, solid backgrounds — always layer gradients
- Apply borders thicker than 1px
- Use bright/saturated colors without an accompanying glow
- Make text larger than 13px for controls (this is a dense UI style)
- Use white backgrounds — even light mode should be slightly tinted
- Skip the backdrop-filter — it's essential to the glass effect
- Apply animations longer than 400ms for interactions (except ambient pulses)
- Use stock border-radius values (like 4px) — prefer 8px or 14px

## 9. Agent Prompt Guide

When generating Cosmic Dark style uihtml components:

1. Start with CSS variables block using the dark palette (deep blues/purples)
2. Background: multi-layer radial gradients creating depth
3. Panels: `rgba(255,255,255,0.03)` background + `backdrop-filter: blur(12px)` + 1px glass border
4. Slider thumbs: 14px with radial gradient + glow shadow
5. Buttons: 8px radius, accent glow on primary, ghost style for secondary
6. Toggles: compact (44x24px), glow on activation
7. All panels get `fadeSlideIn` animation with staggered delays
8. Active states use pulsing glow animations
9. Typography: compact (10-13px range), uppercase for section labels with wide letter-spacing
10. For light mode adaptation: swap to muted purples on light gray, reduce glow intensity
