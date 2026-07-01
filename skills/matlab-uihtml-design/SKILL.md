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

   Then ask: "I've opened the style gallery in your browser. Which style would you like? You can also describe a custom aesthetic."

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

Execute the chosen direction with precision. Bold maximalism and refined minimalism both work, as long as the choice is intentional.

## Workflow

1. **Style selection**: Identify or create the aesthetic direction
2. **Component planning**: Determine which controls are needed (sliders, buttons, toggles, etc.)
3. **HTML generation**: Produce self-contained HTML with the chosen style applied
4. **MATLAB integration**: Include `setup(htmlComponent)` boilerplate; defer full MATLAB-side wiring to the `matlab-uihtml-app-builder` skill

## Component Library (v1)

### Sliders
- Range inputs with custom thumb and track styling
- Value display with formatted units
- Horizontal layout with label + value header

### Buttons
- **Primary/Filled**: Bold accent color, prominent shadow/glow
- **Secondary/Outlined**: Transparent with border, subtle hover
- **Destructive/Danger**: Warning color for stop/reset actions
- State: default, hover, focus-visible, active (scale 0.97), disabled (see the Interactive states table in **Design Guardrails**)

### Toggles
- Sliding toggle switches
- On/off states with color transition
- Keyboard-operable (focusable, toggle on Space/Enter) with accessible click/tap targets

## Theme System

All styles use CSS custom properties for theming. The base architecture:

```css
:root {
    /* Semantic colors, filled by chosen style */
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
- **Prioritize fitting all controls** over matching the style's ideal spacing. Reduce padding, gaps, and font sizes as needed; the neumorphic effect still works at 16px padding and 16px gaps
- **Use compact variants** when the container holds more than 2 panels: body padding 14px, panel padding 16px, inter-panel gap 16px, button padding 9px 18px
- **Padding has a floor.** Even when compacting, keep ~12px of padding inside a bordered or tinted panel (8px absolute minimum). Trim inter-panel gaps and font sizes before you starve the panel's own padding. Text or controls flush against a panel edge read as cramped and unfinished
- **Never let content overflow**: if `overflow: hidden` is set on the body, clipped controls are invisible and unusable
- **Test mentally**: count the vertical space budget (panels × padding + gaps + content height) and ensure it fits within a typical side-panel height (~400–500px)

### Scrollable Panels (When Content Exceeds the Container)

When the control set genuinely can't be compacted further (4+ panels, mixed sliders + toggles + buttons), make the panel container scroll instead of clipping. Keep `body` non-scrolling so the background gradient stays anchored, and let the inner `.app` (or whatever you named the flex column) scroll:

```css
html, body {
    overflow: hidden;   /* body never scrolls; background gradient stays put */
}

.app {
    height: 100%;
    overflow-y: auto;
    overflow-x: hidden;
    scrollbar-width: thin;                                    /* Firefox */
    scrollbar-color: rgba(255, 255, 255, 0.12) transparent;   /* Firefox */
}

/* Chromium (uihtml uses CEF/Chromium) */
.app::-webkit-scrollbar { width: 6px; }
.app::-webkit-scrollbar-track { background: transparent; }
.app::-webkit-scrollbar-thumb {
    background: rgba(255, 255, 255, 0.10);
    border-radius: 3px;
    transition: background var(--t-fast);
}
.app::-webkit-scrollbar-thumb:hover { background: var(--accent-glow); }
```

**Adapt the colors to the chosen palette:**

| Style | Thumb default | Thumb hover |
|---|---|---|
| Dark styles (Cosmic Dark, Midnight, Neumorphic, Warm Dark, Minimal Mono) | `rgba(255,255,255,0.10)` | `var(--accent-glow)` |
| Light styles (Clean, Dashboard Light, Material light mode) | `rgba(0,0,0,0.12)` | `rgba(0,0,0,0.22)` or `var(--accent)` |

Keep the scrollbar `6px` wide and the thumb under 20% alpha; anything heavier breaks the style. Don't show track borders or arrows.

## Design Guardrails

These are cross-cutting rules that apply on top of whatever style is chosen. They exist to keep generated control panels from reading as "AI made that." A named built-in style that deliberately uses one of these moves as its identity (Cosmic Dark's neon glow, Midnight Gradient's blue-to-purple, Clean's glass) is intentional *voice* and is fine. The guardrails target the unconscious reflex of reaching for these on every panel.

### Contrast (verify, don't eyeball)

- Body and label text must hit **≥4.5:1** against its background; large or bold text (≥18px, or ≥14px bold) needs **≥3:1**. UI component boundaries, slider tracks, toggle outlines, and icons also need **≥3:1**.
- **Value readouts and placeholder text need the full 4.5:1 too**: don't let a "tertiary" gray slip below it just because it's secondary information. The single most common failure is muted gray text on a tinted near-white (light styles) or a low-contrast gray on near-black (dark styles). If contrast is even close, push the text toward the ink end of the ramp.
- **Gray text on a colored surface looks washed out.** On an accent-colored button or panel, don't use neutral gray for the label: use white/near-white, a darker shade of the surface's *own* hue, or an alpha of the text color.

### Numeric readouts

- Slider value displays, counters, and any aligned numbers get `font-variant-numeric: tabular-nums` so the width doesn't jitter as digits change while dragging.

### Motion

- **Reduced motion is not optional.** Every non-trivial transition or entrance animation needs a `@media (prefers-reduced-motion: reduce)` fallback, typically a crossfade or an instant state change. Include this in the template's `<style>` block:

  ```css
  @media (prefers-reduced-motion: reduce) {
      *, *::before, *::after {
          animation-duration: 0.01ms !important;
          animation-iteration-count: 1 !important;
          transition-duration: 0.01ms !important;
      }
  }
  ```

- Reveal/entrance animations must enhance an **already-visible default**. Don't gate a control's visibility on a class-triggered transition. Inside `uihtml` (a headless Chromium/CEF render) a transition that never fires ships the panel blank.
- **Timing.** A control panel is a task UI: no page-load choreography; users are here to do something and won't wait for it. Durations: **100–150ms** for instant feedback (press, toggle, value change), **200–300ms** for state changes (menu open, panel expand). Keep interactive feedback under ~200ms so it feels instant. Run exit transitions at ~75% of their entrance duration.
- **Easing.** Ease *out* with an exponential curve; never bounce or elastic. Define one as a token and reuse it:

  ```css
  --ease-out-quart: cubic-bezier(0.25, 1, 0.5, 1);   /* smooth */
  --ease-out-quint: cubic-bezier(0.22, 1, 0.36, 1);  /* snappier */
  --ease-out-expo:  cubic-bezier(0.16, 1, 0.3, 1);   /* decisive */
  ```

  A subtle spring/compression on a control *press* is fine; a bouncy elastic entrance applied uniformly to every panel is a tell.
- Animate `transform` / `opacity` / `filter`, not layout properties (width, height, top, margin).

### Structure & interaction

- **Panels are this skill's "cards": never nest a panel inside a panel.** Group related controls in one panel; separate groups with spacing or a hairline, not a second layer of container.
- **Dropdowns and custom menus get clipped by the container.** Because `uihtml` panels frequently set `overflow: hidden` or `overflow: auto` (see Scrollable Panels above), a `position: absolute` menu inside them is cut off. The reliable fix across `uihtml`'s embedded Chromium is **`position: fixed`** with coordinates computed from the trigger's `getBoundingClientRect()` (flip above / left when near a viewport edge). Native `<dialog>` + `showModal()` (top layer) also escapes clipping. The Popover API and CSS anchor positioning are cleaner but need a recent Chromium. Only rely on them if you've confirmed the installed MATLAB's `uihtml` renderer supports them; otherwise fall back to `position: fixed`.
- Provide a visible `:focus-visible` state for keyboard users: ≥3:1 against adjacent colors, 2–3px, offset *outside* the element. A box-shadow ring or `outline` + `outline-offset` both work; never ship `outline: none` with no replacement.
- Build a small **semantic z-index scale** (e.g. dropdown → sticky → modal → tooltip) rather than arbitrary `999` / `9999`.

### Interactive states

Every control needs its states designed, not just the default. Keyboard users never see `:hover`, so **focus is separate from hover and is not optional**.

| State | Applies to | Treatment |
|---|---|---|
| Default / hover / active | all controls | base; subtle lift or color shift on hover; press feedback (e.g. `transform: scale(0.97)`) on active |
| Focus | all controls | visible `:focus-visible` ring per the rule above |
| Disabled | buttons, inputs | reduced opacity, `cursor: not-allowed`, no hover response |
| Loading / busy | actions that call MATLAB | spinner, pulse, or a busy-styled button; a long MATLAB op (>~1s) should show progress and stay cancellable |
| Error / success | status feedback | color **plus** an icon or text message, never color alone |

Loading / error / success are usually driven from the MATLAB backend; see `matlab-uihtml-app-builder` for the event wiring (e.g. `SimComplete` / `SimError`, busy-button state machine).

### Refuse-and-rewrite (AI-slop tells)

If you're about to write any of these, restructure instead:

- **Side-stripe accents**: a thick colored bar down one edge of a panel, list row, callout, or alert. This is never the right answer; it reads instantly as "AI made that." It shows up in several disguises, and the ban covers all of them:

  ```css
  /* ❌ all of these render the same orange side-stripe */
  .panel { border-left: 4px solid var(--accent); }          /* the obvious one */
  .panel { border-inline-start: 3px solid var(--accent); }  /* logical-property alias */
  .panel { box-shadow: inset 4px 0 0 var(--accent); }       /* inset shadow, no `border-left` in sight */
  .panel { border-width: 1px 1px 1px 4px; border-color: … var(--accent); }  /* asymmetric border widths */
  .panel::before { content: ''; position: absolute; left: 0; width: 4px; height: 100%; background: var(--accent); }

  /* ✅ mark state another way */
  .panel[data-state="active"] { border: 1px solid var(--accent); }               /* full hairline border */
  .panel[data-state="active"] { background: var(--accent-soft); }               /* an ~8% accent wash, defined as a token */
  .panel[data-state="active"] .title::before { content: '● '; color: var(--accent); }  /* leading glyph */
  ```

  Rule of thumb: any left/right border wider than 1px, or any accent-colored fill narrower than ~8px running the full height of one edge, is a side-stripe. Rewrite it.
- **Gradient text**: `background-clip: text` over a gradient. Emphasize with weight, size, or a single solid color.
- **Ghost-card**: a 1px border *and* a soft wide `box-shadow` (blur ≥16px) on the same element. Pick one: a defined border, or a shadow at ≤8px blur.
- **Over-rounding**: `border-radius` ≥32px on panels or inputs. Panels top out around 12–16px; full-pill radius is only for tags and buttons.
- **Cream/sand/beige body backgrounds by reflex** and **default purple-blue gradients or dark glows** as generic decoration. If the chosen style doesn't call for them, don't add them.

### Microcopy

Panel text is part of the design. Slop in a label or a status line reads as "AI made that" as loudly as a side-stripe does. These are engineer-facing MATLAB tools, so write like the product does: declarative, plain, and trusting the reader's competence.

- **Labels & section headers** are noun phrases, never questions or hype: "Initial Conditions", "Parameters", "Last Result", not "Ready to simulate?" or "Let's get started".
- **Buttons** are functional imperatives: "Run", "Reset", "Export PNG", "Stop". No exclamation points, no urgency, no emoji.
- **Status, empty, and error messages** state what happened, plainly: "Trajectory rendered (4449 pts)", "Nothing to export", "Invalid expression", not "Oops! Something went wrong 🎉" or "Success!".
- **No slop words** anywhere in UI text: leverage, unlock, seamless, powerful, streamline, supercharge, cutting-edge (and "robust" unless it means an actual engineering tolerance). **No em dashes** in microcopy: use a colon, comma, or period.
- Trust the engineer: don't gloss terms the audience already knows (σ, ρ, β, "attractor" need no explanation).

MATLAB-driven status text (wired in `matlab-uihtml-app-builder`) follows the same rules: the string that MATLAB sends to a status line is microcopy too.

## Conventions

- **Self-contained**: No external CDN links; all CSS and JS inline in a single HTML file
- **Responsive**: Must work within arbitrary `uihtml` container sizes; use flexbox/grid with relative units
- **MATLAB event boilerplate**: Always include the `setup(htmlComponent)` function pattern:

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

- **Theme sync with MATLAB desktop**: All templates listen for a `SetTheme` event. The MATLAB side can detect the desktop theme and push it to the HTML component. **The `settings` path is R2025a+**, so wrap it in try/catch with a sensible default so the app still works on older releases:

```matlab
% Detect MATLAB desktop theme (R2025a+); fall back to a default on older releases
themeStr = 'dark';   % or 'light', whichever the style is designed for
try
    s = settings;
    themeStr = lower(char(s.matlab.appearance.MATLABTheme.ActiveValue));
catch
    % settings.matlab.appearance not available on this release; keep the default
end

sendEventToHTMLSource(htmlComp, "SetTheme", struct("theme", themeStr));
```

The HTML `setup()` function already includes a `SetTheme` listener that sets `data-theme` on the root element, triggering the CSS variable swap.

- **Fonts**: For a dense app UI a native system stack (`-apple-system, 'Segoe UI', system-ui, sans-serif`) is a legitimate, fast, offline-safe default. The built-in templates use one, and it's the right call for control panels. What reads as "AI made that" is reaching for a *distinctive-but-overused* display face for personality: Inter, Roboto, Geist, Space Grotesk, Plus Jakarta Sans, Fraunces (and plain Arial). Avoid those. If you pair fonts, pair on a real contrast axis (serif + sans); don't pair two similar sans-serifs. Also avoid purple-on-white cliches and cookie-cutter layouts; see the refuse-and-rewrite list in **Design Guardrails** above
- **Accessible**: Meet the contrast, focus-visible, interactive-states, and reduced-motion requirements in **Design Guardrails** above. Keep targets comfortably clickable (~28px+ hit area for toggles/thumbs, larger for buttons; size up toward 44px if the app may run on a touch display)
- **Performance**: CSS-only animations preferred; minimize JavaScript for visual effects
- **External links**: `<a href="…" target="_blank" rel="noopener">` opens in the system default browser from `uihtml`, not inside the MATLAB figure. Useful for "view docs / view source" links in the app header. Style the link to fit the palette (accent color on hover, no underline by default):

  ```css
  .external-link {
      color: var(--text-secondary);
      text-decoration: none;
      transition: color var(--t-fast), text-shadow var(--t-fast);
  }
  .external-link:hover {
      color: var(--accent-secondary);
      text-shadow: 0 0 8px var(--accent-glow);  /* dark styles */
  }
  ```

## Related Skills

- **matlab-uihtml-app-builder**: architecture, communication patterns, event handling, and MATLAB backend integration for uihtml apps. Use it for the functional wiring behind your styled controls.
