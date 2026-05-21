# Clean Design System

## 1. Visual Theme & Atmosphere

Inspired by modern platform Human Interface Guidelines. The core principles are **depth**, **clarity**, and **deference**.

- **Depth**: Translucent layers, frosted glass (backdrop-filter: blur), subtle shadows that establish hierarchy
- **Clarity**: Clean typography, generous whitespace, legible text at every size
- **Deference**: The UI recedes to let content shine; controls feel light, not heavy

The overall feeling is calm, premium, and effortlessly functional. Surfaces float above backgrounds with luminous diffusion. Interactions feel physically grounded — controls respond with subtle compression and spring-back.

## 2. Color Palette & Roles

### Light Mode
| Role | Value | Usage |
|------|-------|-------|
| Background | `#F2F2F7` | Page background |
| Surface | `rgba(255, 255, 255, 0.72)` | Cards, panels (with blur) |
| Surface Solid | `#FFFFFF` | Non-blurred surfaces |
| Accent (Blue) | `#007AFF` | Primary actions, active states |
| Accent (Green) | `#34C759` | Toggle on-state, success |
| Accent (Red) | `#FF3B30` | Destructive actions, stop |
| Accent (Orange) | `#FF9500` | Warnings |
| Text Primary | `#000000` | Headings, labels |
| Text Secondary | `#3C3C43` opacity 60% | Descriptions, secondary info |
| Text Tertiary | `#3C3C43` opacity 30% | Placeholders |
| Separator | `#3C3C43` opacity 12% | Dividers, borders |
| Fill | `#787880` opacity 12% | Input backgrounds, inactive tracks |

### Dark Mode
| Role | Value | Usage |
|------|-------|-------|
| Background | `#000000` | Page background |
| Surface | `rgba(44, 44, 46, 0.72)` | Cards, panels (with blur) |
| Surface Solid | `#1C1C1E` | Non-blurred surfaces |
| Accent (Blue) | `#0A84FF` | Primary actions |
| Accent (Green) | `#30D158` | Toggle on-state |
| Accent (Red) | `#FF453A` | Destructive |
| Text Primary | `#FFFFFF` | Headings |
| Text Secondary | `#EBEBF5` opacity 60% | Secondary |
| Text Tertiary | `#EBEBF5` opacity 30% | Placeholders |
| Separator | `#545458` opacity 60% | Dividers |
| Fill | `#787880` opacity 24% | Input backgrounds |

## 3. Typography Rules

**Font Stack**: `-apple-system, BlinkMacSystemFont, 'SF Pro Display', 'SF Pro Text', system-ui, sans-serif`

| Level | Size | Weight | Letter Spacing | Usage |
|-------|------|--------|---------------|-------|
| Large Title | 34px | 700 | -0.4px | Panel headers |
| Title 1 | 28px | 700 | 0.35px | Section titles |
| Title 3 | 20px | 600 | 0.38px | Sub-sections |
| Headline | 17px | 600 | -0.4px | Component labels |
| Body | 17px | 400 | -0.4px | Descriptions |
| Callout | 16px | 400 | -0.3px | Secondary text |
| Subhead | 15px | 400 | -0.2px | Metadata |
| Footnote | 13px | 400 | -0.1px | Captions |
| Caption 1 | 12px | 400 | 0 | Timestamps, badges |
| Caption 2 | 11px | 600 | 0.5px | Uppercase labels |

## 4. Component Stylings

### Buttons

**Filled (Primary)**
```css
.btn-filled {
    background: var(--color-accent);
    color: #FFFFFF;
    border: none;
    border-radius: 12px;
    padding: 14px 20px;
    font-size: 17px;
    font-weight: 600;
    letter-spacing: -0.4px;
    transition: transform 200ms cubic-bezier(0.25, 0.46, 0.45, 0.94),
                opacity 200ms ease;
}
.btn-filled:hover { opacity: 0.85; }
.btn-filled:active { transform: scale(0.97); opacity: 0.7; }
```

**Tinted (Secondary)**
```css
.btn-tinted {
    background: rgba(0, 122, 255, 0.12);
    color: var(--color-accent);
    border: none;
    border-radius: 12px;
    padding: 14px 20px;
    font-size: 17px;
    font-weight: 600;
}
.btn-tinted:hover { background: rgba(0, 122, 255, 0.18); }
.btn-tinted:active { transform: scale(0.97); }
```

**Plain (Tertiary)**
```css
.btn-plain {
    background: transparent;
    color: var(--color-accent);
    border: none;
    padding: 14px 20px;
    font-size: 17px;
    font-weight: 400;
}
.btn-plain:hover { opacity: 0.7; }
```

### Sliders

```css
input[type="range"] {
    -webkit-appearance: none;
    width: 100%;
    height: 4px;
    border-radius: 2px;
    background: var(--color-fill);
    outline: none;
}
input[type="range"]::-webkit-slider-thumb {
    -webkit-appearance: none;
    width: 28px;
    height: 28px;
    border-radius: 50%;
    background: #FFFFFF;
    box-shadow: 0 0.5px 4px rgba(0, 0, 0, 0.12),
                0 6px 13px rgba(0, 0, 0, 0.12);
    cursor: pointer;
    transition: transform 150ms cubic-bezier(0.25, 0.46, 0.45, 0.94);
}
input[type="range"]:active::-webkit-slider-thumb {
    transform: scale(1.1);
}
```

Track fill (colored portion) achieved via linear-gradient on the track background, calculated in JS.

### Toggles

```css
.toggle {
    width: 51px;
    height: 31px;
    border-radius: 15.5px;
    background: var(--color-fill);
    position: relative;
    cursor: pointer;
    transition: background 300ms cubic-bezier(0.4, 0, 0.2, 1);
}
.toggle.active {
    background: var(--color-green);
}
.toggle::after {
    content: '';
    position: absolute;
    width: 27px;
    height: 27px;
    border-radius: 50%;
    background: #FFFFFF;
    top: 2px;
    left: 2px;
    box-shadow: 0 3px 8px rgba(0, 0, 0, 0.15),
                0 1px 1px rgba(0, 0, 0, 0.06);
    transition: transform 300ms cubic-bezier(0.4, 0, 0.2, 1);
}
.toggle.active::after {
    transform: translateX(20px);
}
```

### Cards / Panels

```css
.card {
    background: var(--color-surface);
    -webkit-backdrop-filter: blur(20px) saturate(180%);
    backdrop-filter: blur(20px) saturate(180%);
    border-radius: 16px;
    padding: 16px;
    border: 0.5px solid var(--color-separator);
}
```

## 5. Layout Principles

- **Base unit**: 8px grid; common spacings are 8, 12, 16, 20, 24, 32
- **Content margins**: 16px on compact widths, 20px on regular
- **Component spacing**: 12px between related controls, 24px between sections
- **Section structure**: Section label (Caption 2, uppercase, secondary color) → content group
- **Alignment**: Left-aligned labels; right-aligned values/accessories
- **Grouping**: Related controls in a single card; visual separation via subtle borders, not whitespace alone

## 6. Depth & Elevation

This style uses **materials** (translucent layers) rather than traditional elevation:

| Layer | Treatment |
|-------|-----------|
| Background | Solid color, no blur |
| Grouped content | Slightly elevated, subtle shadow |
| Cards/Panels | `backdrop-filter: blur(20px) saturate(180%)`, translucent fill |
| Overlays/Modals | Heavier blur (40px), darker scrim beneath |
| Floating elements | Strong shadow: `0 10px 40px rgba(0,0,0,0.15)` |

Shadow philosophy: Shadows are soft, diffused, and never harsh. Multiple shadow layers create realism:
```css
box-shadow: 0 0.5px 1px rgba(0,0,0,0.04),
            0 4px 16px rgba(0,0,0,0.08);
```

## 7. Motion & Interaction

**Timing curves:**
- Interactive elements: `cubic-bezier(0.25, 0.46, 0.45, 0.94)` (ease-out with bounce-feel)
- State transitions: `cubic-bezier(0.4, 0, 0.2, 1)` (Material-style ease)
- Spring feel: `cubic-bezier(0.34, 1.56, 0.64, 1)` (slight overshoot)

**Durations:**
- Micro-interactions (press): 150ms
- State changes (toggle, expand): 300ms
- Page transitions / reveals: 400-500ms

**Key interactions:**
- **Press**: Scale to 0.97, slight opacity reduction
- **Release**: Spring back with slight overshoot
- **Hover**: Subtle opacity shift (0.85), no color change
- **Appear**: Fade + translateY(8px → 0) with staggered delays
- **Toggle**: Smooth background color transition + thumb slide

## 8. Do's and Don'ts

### Do
- Use `backdrop-filter: blur()` for surface materials
- Apply `-apple-system` font stack for native feel
- Use CSS custom properties for all colors (easy light/dark switch)
- Keep interactions subtle — compression, not explosion
- Use `border-radius: 12-16px` for cards, `50%` for circular elements
- Apply `transition` to transforms and opacity, not layout properties
- Use semantic color naming (accent, surface, fill) not literal (blue, gray)

### Don't
- Use hard drop shadows (`0 4px 0 black`)
- Apply borders thicker than 1px (prefer 0.5px or box-shadow)
- Use uppercase text except for section labels (Caption 2 level)
- Add heavy text shadows or glow effects
- Use jarring colors — clean palettes are vibrant but balanced
- Apply animations longer than 500ms for interactive elements
- Use `outline` for focus — prefer subtle box-shadow or background change

## 9. Agent Prompt Guide

When generating Clean-style uihtml components:

1. Start with the CSS variable block (light mode defaults, dark mode override)
2. Apply `-apple-system` font stack
3. Use 12-16px border radius on containers
4. Slider thumbs: 28px white circles with soft multi-layer shadow
5. Buttons: 12px radius, 14px vertical padding, 600 weight
6. Toggles: 51x31px with 27px circular thumb
7. Cards: translucent background + backdrop-filter + 0.5px border
8. All interactive elements: `transform: scale(0.97)` on `:active`
9. Stagger entrance animations with `animation-delay` increments of 0.05-0.1s
10. Test both light and dark modes — ensure contrast ratios meet WCAG AA
