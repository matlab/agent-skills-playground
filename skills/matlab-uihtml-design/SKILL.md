---
name: matlab-uihtml-design
description: Generate beautiful, distinctive HTML/CSS/JS control panels for MATLAB uihtml components. 8 built-in styles (Clean, Material, Cosmic Dark, Neumorphic, Dashboard Light, Midnight Gradient, Minimal Mono, Warm Dark) plus custom aesthetics. Produces production-grade UI with sliders, buttons, toggles, and panels. Use when building visually polished MATLAB app UIs with uihtml.
license: MathWorks BSD-3-Clause (see LICENSE)
metadata:
  author: MathWorks
  version: "1.0"
---

# MATLAB uihtml Design Skill

Generate production-grade HTML/CSS/JS control panels for MATLAB `uihtml` components with distinctive, configurable visual styles.

## When to Use

- User wants beautiful custom controls in a MATLAB app via `uihtml`
- User asks for a specific design style (Clean, Material, dark theme, etc.)
- User wants to redesign or restyle existing `uihtml` controls
- User describes a custom aesthetic for their MATLAB app controls

## Style Selection

Built-in styles are documented in `references/design-styles.md`. To apply a style:

1. If the user names a built-in style, read the corresponding file from `references/styles/<name>.md`
2. If the user describes a custom aesthetic, apply creative design thinking (see below) without loading a reference style
3. If no style is specified, **open the visual style gallery** in the user's browser so they can see all 8 styles side-by-side:

   ```bash
   start "" "<skill-directory>/assets/style-gallery.html"   # Windows
   open "<skill-directory>/assets/style-gallery.html"       # macOS
   ```

   Then ask: "I've opened the style gallery in your browser — which style would you like? You can also describe a custom aesthetic."

   The gallery shows interactive previews of all 8 built-in styles with a Dark/Light toggle. The available styles are:

   | Style | Vibe |
   |-------|------|
   | Clean | Frosted glass, depth layers, spring animations |
   | Material | Tonal surfaces, elevation, rounded shapes |
   | Cosmic Dark | Deep space, neon glow, glassmorphism |
   | Neumorphic Dark | Embossed/debossed, soft shadow pairs |
   | Dashboard Light | White cards, indigo accent, data-dense |
   | Midnight Gradient | Blue-to-purple gradients, luxury glow |
   | Minimal Mono | Ultra-flat, pill buttons, single accent |
   | Warm Dark | Amber/yellow accent, friendly, smart home |

   If the user says "just pick one" or wants to move fast, default to Clean.

Each style reference follows the 9-section DESIGN.md format and provides complete specifications for colors, typography, components, motion, and guardrails.

## Design Thinking

Before generating code, commit to a clear aesthetic direction:

- **Purpose**: What does this control panel do? Who uses it?
- **Tone**: What feeling should the interface evoke?
- **Constraints**: Container size, MATLAB integration requirements, offline (no CDN)
- **Differentiation**: What makes this memorable and cohesive?

Execute the chosen direction with precision. Bold maximalism and refined minimalism both work — the key is intentionality, not intensity.

## Workflow

1. **Style selection** — Identify or create the aesthetic direction
2. **Component planning** — Determine which controls are needed (sliders, buttons, toggles, etc.)
3. **HTML generation** — Produce self-contained HTML with the chosen style applied
4. **MATLAB integration** — Include `setup(htmlComponent)` boilerplate; defer full MATLAB-side wiring to the `matlab-uihtml-app-builder` skill

## Component Library (v1)

### Sliders
- Range inputs with custom thumb and track styling
- Value display with formatted units
- Horizontal layout with label + value header

### Buttons
- **Primary/Filled** — Bold accent color, prominent shadow/glow
- **Secondary/Outlined** — Transparent with border, subtle hover
- **Destructive/Danger** — Warning color for stop/reset actions
- State: default, hover, active (scale 0.97), disabled

### Toggles
- Sliding toggle switches
- On/off states with color transition
- Accessible click/tap targets

## Theme System

All styles use CSS custom properties for theming. The base architecture:

```css
:root {
    /* Semantic colors — filled by chosen style */
    --color-bg-primary: ...;
    --color-bg-secondary: ...;
    --color-bg-surface: ...;
    --color-accent: ...;
    --color-accent-hover: ...;
    --color-text-primary: ...;
    --color-text-secondary: ...;
    --color-border: ...;

    /* Spacing */
    --space-xs: 4px;
    --space-sm: 8px;
    --space-md: 16px;
    --space-lg: 24px;

    /* Typography */
    --font-family: ...;
    --font-size-sm: ...;
    --font-size-md: ...;
    --font-size-lg: ...;

    /* Radii & Shadows */
    --radius-sm: ...;
    --radius-md: ...;
    --shadow-sm: ...;
    --shadow-md: ...;

    /* Motion */
    --transition-fast: ...;
    --transition-med: ...;
}
```

Support both light and dark modes via `prefers-color-scheme` media query or a `data-theme` attribute on `<html>`:

```css
@media (prefers-color-scheme: dark) { ... }
/* or */
[data-theme="dark"] { ... }
```

## Container-Aware Spacing

`uihtml` containers in MATLAB apps are often height-constrained (e.g., a narrow side panel). When applying any style:

- **Read the existing HTML first** to understand how many controls need to fit
- **Prioritize fitting all controls** over matching the style's ideal spacing. Reduce padding, gaps, and font sizes as needed — the neumorphic effect still works at 16px padding and 16px gaps
- **Use compact variants** when the container holds more than 2 panels: body padding 14px, panel padding 16px, inter-panel gap 16px, button padding 9px 18px
- **Never let content overflow** — if `overflow: hidden` is set on the body, clipped controls are invisible and unusable
- **Test mentally**: count the vertical space budget (panels × padding + gaps + content height) and ensure it fits within a typical side-panel height (~400–500px)

## Conventions

- **Self-contained** — No external CDN links; all CSS and JS inline in a single HTML file
- **Responsive** — Must work within arbitrary `uihtml` container sizes; use flexbox/grid with relative units
- **MATLAB event boilerplate** — Always include the `setup(htmlComponent)` function pattern:

```javascript
function setup(htmlComponent) {
    window.htmlComponent = htmlComponent;

    // Listen for events from MATLAB
    htmlComponent.addEventListener("EventName", function(event) {
        // Handle event.Data
    });

    // Send events to MATLAB
    htmlComponent.sendEventToMATLAB("EventName", { key: value });
}
```

- **Theme sync with MATLAB desktop** — All templates listen for a `SetTheme` event. The MATLAB side can detect the desktop theme and push it to the HTML component:

```matlab
% Detect MATLAB desktop theme (R2025a+)
s = settings;
currentTheme = s.matlab.appearance.MATLABTheme.ActiveValue; % "Light" or "Dark"

% Push to uihtml component
sendEventToHTMLSource(htmlComp, "SetTheme", struct("theme", lower(currentTheme)));
```

The HTML `setup()` function already includes a `SetTheme` listener that sets `data-theme` on the root element, triggering the CSS variable swap.

- **No generic aesthetics** — Avoid Inter/Roboto/Arial, avoid purple-on-white cliches, avoid cookie-cutter layouts
- **Accessible** — Sufficient color contrast, clear focus states, reasonable touch targets
- **Performance** — CSS-only animations preferred; minimize JavaScript for visual effects

## Related Skills

- **matlab-uihtml-app-builder** — Core architecture, communication patterns, event handling, and MATLAB backend integration for uihtml apps. Use it for the functional wiring behind your styled controls.
