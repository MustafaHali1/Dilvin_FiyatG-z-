---
name: Universal Vision
colors:
  surface: '#faf8ff'
  surface-dim: '#d2d9f4'
  surface-bright: '#faf8ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f2f3ff'
  surface-container: '#eaedff'
  surface-container-high: '#e2e7ff'
  surface-container-highest: '#dae2fd'
  on-surface: '#131b2e'
  on-surface-variant: '#404750'
  inverse-surface: '#283044'
  inverse-on-surface: '#eef0ff'
  outline: '#707881'
  outline-variant: '#c0c7d2'
  surface-tint: '#00639b'
  primary: '#00598c'
  on-primary: '#ffffff'
  primary-container: '#0072b2'
  on-primary-container: '#e7f1ff'
  inverse-primary: '#97cbff'
  secondary: '#7f5600'
  on-secondary: '#ffffff'
  secondary-container: '#fdb323'
  on-secondary-container: '#6b4800'
  tertiary: '#005b80'
  on-tertiary: '#ffffff'
  tertiary-container: '#0075a3'
  on-tertiary-container: '#e4f2ff'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#cee5ff'
  primary-fixed-dim: '#97cbff'
  on-primary-fixed: '#001d33'
  on-primary-fixed-variant: '#004a76'
  secondary-fixed: '#ffddae'
  secondary-fixed-dim: '#ffba40'
  on-secondary-fixed: '#281800'
  on-secondary-fixed-variant: '#614000'
  tertiary-fixed: '#c6e7ff'
  tertiary-fixed-dim: '#83cfff'
  on-tertiary-fixed: '#001e2d'
  on-tertiary-fixed-variant: '#004c6b'
  background: '#faf8ff'
  on-background: '#131b2e'
  surface-variant: '#dae2fd'
typography:
  headline-xl:
    fontFamily: Atkinson Hyperlegible Next
    fontSize: 40px
    fontWeight: '700'
    lineHeight: 48px
    letterSpacing: -0.02em
  headline-xl-mobile:
    fontFamily: Atkinson Hyperlegible Next
    fontSize: 30px
    fontWeight: '700'
    lineHeight: 38px
    letterSpacing: -0.01em
  headline-lg:
    fontFamily: Atkinson Hyperlegible Next
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.01em
  headline-lg-mobile:
    fontFamily: Atkinson Hyperlegible Next
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
    letterSpacing: 0em
  headline-md:
    fontFamily: Atkinson Hyperlegible Next
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
    letterSpacing: 0em
  headline-sm:
    fontFamily: Atkinson Hyperlegible Next
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
    letterSpacing: 0em
  body-lg:
    fontFamily: Atkinson Hyperlegible Next
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
    letterSpacing: 0.01em
  body-md:
    fontFamily: Atkinson Hyperlegible Next
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
    letterSpacing: 0.01em
  body-sm:
    fontFamily: Atkinson Hyperlegible Next
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
    letterSpacing: 0.015em
  label-lg:
    fontFamily: JetBrains Mono
    fontSize: 15px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.02em
  label-md:
    fontFamily: JetBrains Mono
    fontSize: 13px
    fontWeight: '500'
    lineHeight: 18px
    letterSpacing: 0.03em
  label-sm:
    fontFamily: JetBrains Mono
    fontSize: 11px
    fontWeight: '500'
    lineHeight: 14px
    letterSpacing: 0.04em
rounded:
  sm: 0.125rem
  DEFAULT: 0.25rem
  md: 0.375rem
  lg: 0.5rem
  xl: 0.75rem
  full: 9999px
spacing:
  gutter: 1.5rem
  gutter-mobile: 1rem
  margin: 2rem
  margin-mobile: 1rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 1rem
  space-lg: 1.5rem
  space-xl: 2.5rem
---

## Brand & Style

This design system is engineered for uncompromising clarity, surgical precision, and universal accessibility. Tailored specifically for users with red-green color vision deficiencies (Deuteranopia and Protanopia), it rejects decorative ambiguity in favor of clinical-grade utility. 

The aesthetic is High-Contrast Functionalist with tactile, structured visual affordances. It pairs the mathematical rigor of the Okabe-Ito barrier-free palette with deliberate iconography, bold boundary definitions, and textural distinctions (such as diagonal hatchings and stippling). 

The emotional signature is empowering, utterly dependable, and fatigue-free. It conveys certainty: users must never guess whether an element is selected, destructive, or successful. Every data point, price shift, and interactive boundary carries triple-redundant feedback (color, iconography/pattern, and explicit typography).

## Colors

The palette is derived directly from the Okabe-Ito universal chromatic scale, fully vetted for red-green blindness, monochromacy, and extreme low-contrast conditions. Red/green semantic pairs are strictly forbidden across all states.

- **Primary (`#0072B2` - Cobalt Blue):** Used for primary interactive triggers, active navigation tabs, focal points, and definitive confirmations. Achieves >7:1 contrast against pure light surfaces.
- **Secondary / Cautionary (`#E69F00` - Amber Orange):** Represents alerts, market volatility, warnings, and urgent interactive cues. It retains chromatic vibrancy and high luminance separation from the Cobalt Blue for both protanopes and deuteranopes.
- **Tertiary (`#56B4E9` - Sky/Ice Accent):** Used for supporting infographics, selection rings, secondary chart plots, and informational tags.
- **Neutral Dark (`#0F172A` - Slate Navy):** The structural backbone. Applied to body typography, bold element contours, glyphs, and high-contrast frames. Replaces pure black to reduce harsh chromatic vibration while sustaining WCAG AAA contrast ratios (>14:1 on white).
- **Backgrounds & Surfaces:**
  - Base Canvas: `#F0F4F8` (Light Ice Slate).
  - Component Container: `#FFFFFF` (Stark White).
  - Muted Inset / Disabled: `#E2E8F0` (Muted Steel).
  - Destructive / Critical Alternative: `#CC79A7` (Reddish Purple) or rich `#0F172A` with strikethrough/warning iconography. Never use standard crimson without pattern hatching.

## Typography

Typography prioritizes legibility under visual duress. **Atkinson Hyperlegible Next** is selected for headlines and body content due to its hyper-distinct letterforms, wide apertures, unambiguous differentiation between `I`, `l`, and `1`, and enhanced distinction between `0` and `O`. 

For numeric displays, technical data, currency shifts, and micro-labels, **JetBrains Mono** provides fixed-width alignment and zero-character ambiguity.

### Execution Rules
- Never set copy below 14px for critical transactional details or comparison figures.
- Use explicit font weight jumps (Regular 400 to Bold 700) rather than subtle steps to establish hierarchy.
- Text must consistently present a contrast ratio of at least 7:1 against its background. Do not apply secondary colors to small running text.

## Layout & Spacing

The layout model is built on an accessible, structured fluid grid with rigid structural containers. 

### Grid Rules
- **Desktop (1024px+):** 12-column layout with 24px (`1.5rem`) gutters and 32px (`2rem`) canvas margins.
- **Tablet (768px - 1023px):** 8-column layout with 20px gutters and 24px canvas margins.
- **Mobile (<768px):** 4-column layout with 16px (`1rem`) gutters and 16px (`1rem`) margins.

### Spacing Philosophy
Spacing operates on an 8pt base grid (with a 4pt micro-step for tags and icon alignments). Touch targets must strictly adhere to a minimum size of 48×48px. White space is paired with explicit perimeter lines to ensure spatial isolation between juxtaposed comparison cards, ensuring that low-vision users do not confuse adjacent data columns.

## Elevation & Depth

This system avoids soft, ambiguous blurred shadows which bleed into low-contrast surfaces and disorient users with color deficiencies. Depth is conveyed strictly via **Tonal Stacking and High-Contrast Outlines**.

### Structural Principles
- **Base Level (Canvas):** Tone `#F0F4F8`.
- **Level 1 (Card / Container):** Tone `#FFFFFF` framed by a 1.5px solid border in `#CBD5E1` (Standard) or `#0F172A` (Prominent).
- **Level 2 (Interactive Floating / Dropdowns):** Offset hard shadow (tactile brutalist inspired, high-definition): `4px 4px 0px 0px #0F172A`, overlaying a solid `#FFFFFF` surface with a 2px `#0F172A` border.
- **Level 3 (Modals / Overlays):** Full `#0F172A` backdrop scrim at 70% opacity, supporting a stark `#FFFFFF` container with a 3px border in `#0072B2`.

## Shapes

The system implements subtle, controlled curvature (`roundedness: 1`, 4px standard radius). 

Sharp geometry reinforces structural precision and keeps bounding boxes crisply delineated across all screen angles. Fully circular pills and heavy corner radii are prohibited for functional containers to avoid soft, washed-out silhouettes. Tags and status markers maintain crisp 4px corners to house inner patterns and hatched borders neatly.

## Components

Every interactive component and status state follows the **Dual-Affordance Mandate**: no state change may rely solely on color.

### 1. Buttons
- **Primary:** Solid Cobalt Blue (`#0072B2`) background, crisp white bold text, accompanied by a trailing action icon (e.g., arrow, plus). Focused state reveals a 3px outer ring in Amber Orange (`#E69F00`) separated by a 2px white offset gap.
- **Secondary:** White background, 2px solid `#0F172A` border, `#0F172A` text, hard offset shadow on hover.
- **Destructive:** Bordered with 2px dashed `#0F172A`, `#0F172A` text, preceded by a distinctive octagonal stop/cross icon.

### 2. Status Chips & Badges
- **Price Decreased / Positive Shift:** `#0072B2` fill or 2px outline, accompanied by an upward solid triangle icon `▲` and explicit `+X%` prefix.
- **Price Increased / Attention Shift:** `#E69F00` fill, accompanied by a downward solid triangle `▼` or warning diamond `◆` and explicit `-X%` prefix.
- **Hatched Variant:** For static printed or exportable chips, background uses a 45-degree diagonal pattern to ensure contrast even in monochrome print.

### 3. Checkboxes & Radio Buttons
- **Checkboxes:** Unchecked is a 20×20px box with a 2px `#0F172A` border. Checked state fills with `#0072B2` and displays a bold, heavy white checkmark (`✓`) with a 2px check stroke thickness.
- **Radio Buttons:** Outer circle with 2px `#0F172A` border. Active state features a thick inner dot and a secondary outer focus boundary.

### 4. Input Fields
- Outer boundary: 1.5px solid `#0F172A` on `#FFFFFF`.
- Input label set in Atkinson Hyperlegible Next Bold with mandatory field marked with an explicit `[Zorunlu]` text tag rather than an unlabelled asterisk.
- Focus state activates a 2px `#0072B2` stroke accompanied by a solid blue left-edge anchor bar (4px thick).

### 5. Cards & Comparison Blocks
- White tile on `#F0F4F8` canvas with a persistent 1.5px outline.
- Comparison cards feature distinct header bands: standard items use a neutral Slate Navy bar, while targeted or recommended items feature an Okabe-Ito Cobalt Blue bar with an integrated checkmark badge.

### 6. Progress Bars & Metric Trackers
- Progress tracks must utilize graphical hatch patterns:
  - Base Track: Solid `#E2E8F0`.
  - Progress Fill: Alternating 45° stripe pattern (CSS repeating linear gradient) utilizing `#0072B2` and `#56B4E9`.
  - Critical/Threshold Markers: 3px thick vertical tick marks in `#E69F00` with top-aligned diamond anchors.