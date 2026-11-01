---
name: High-Contrast & Large-Text Accessibility
colors:
  surface: '#131316'
  surface-dim: '#131316'
  surface-bright: '#39393c'
  surface-container-lowest: '#0e0e11'
  surface-container-low: '#1b1b1e'
  surface-container: '#1f1f22'
  surface-container-high: '#2a2a2d'
  surface-container-highest: '#353438'
  on-surface: '#e4e1e6'
  on-surface-variant: '#d0c6ab'
  inverse-surface: '#e4e1e6'
  inverse-on-surface: '#303033'
  outline: '#999077'
  outline-variant: '#4d4632'
  surface-tint: '#e9c400'
  primary: '#fff5dc'
  on-primary: '#3a3000'
  primary-container: '#ffd600'
  on-primary-container: '#705d00'
  inverse-primary: '#705d00'
  secondary: '#e2c62d'
  on-secondary: '#393000'
  secondary-container: '#c1a800'
  on-secondary-container: '#483d00'
  tertiary: '#dcffdb'
  on-tertiary: '#003915'
  tertiary-container: '#60f587'
  on-tertiary-container: '#006e2f'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#ffe170'
  primary-fixed-dim: '#e9c400'
  on-primary-fixed: '#221b00'
  on-primary-fixed-variant: '#544600'
  secondary-fixed: '#ffe24c'
  secondary-fixed-dim: '#e2c62d'
  on-secondary-fixed: '#211b00'
  on-secondary-fixed-variant: '#524600'
  tertiary-fixed: '#6bff8f'
  tertiary-fixed-dim: '#4ae176'
  on-tertiary-fixed: '#002109'
  on-tertiary-fixed-variant: '#005321'
  background: '#131316'
  on-background: '#e4e1e6'
  surface-variant: '#353438'
typography:
  display-hero:
    fontFamily: Space Grotesk
    fontSize: 56px
    fontWeight: '800'
    lineHeight: 64px
    letterSpacing: -0.02em
  display-hero-mobile:
    fontFamily: Space Grotesk
    fontSize: 40px
    fontWeight: '800'
    lineHeight: 48px
    letterSpacing: -0.02em
  price-huge:
    fontFamily: Space Grotesk
    fontSize: 48px
    fontWeight: '700'
    lineHeight: 52px
    letterSpacing: -0.01em
  price-huge-mobile:
    fontFamily: Space Grotesk
    fontSize: 36px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.01em
  headline-lg:
    fontFamily: Atkinson Hyperlegible Next
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: 0em
  headline-md:
    fontFamily: Atkinson Hyperlegible Next
    fontSize: 26px
    fontWeight: '700'
    lineHeight: 34px
    letterSpacing: 0em
  body-xl:
    fontFamily: Atkinson Hyperlegible Next
    fontSize: 22px
    fontWeight: '500'
    lineHeight: 32px
    letterSpacing: 0.01em
  body-lg:
    fontFamily: Atkinson Hyperlegible Next
    fontSize: 20px
    fontWeight: '400'
    lineHeight: 30px
    letterSpacing: 0.01em
  body-base:
    fontFamily: Atkinson Hyperlegible Next
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
    letterSpacing: 0.01em
  label-lg:
    fontFamily: Space Grotesk
    fontSize: 22px
    fontWeight: '700'
    lineHeight: 28px
    letterSpacing: 0.02em
  label-md:
    fontFamily: Space Grotesk
    fontSize: 18px
    fontWeight: '700'
    lineHeight: 24px
    letterSpacing: 0.02em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  gutter: 1.5rem
  gutter-mobile: 1rem
  margin: 2rem
  margin-mobile: 1rem
  space-xs: 0.5rem
  space-sm: 0.75rem
  space-md: 1.25rem
  space-lg: 2rem
  space-xl: 3rem
---

## Brand & Style

This design system is engineered specifically for hyper-accessible, high-legibility mobile and web applications. It serves seniors, individuals with visual impairments, motor control conditions (such as tremors), and users operating devices in extreme direct sunlight.

The design movement combines **High-Contrast Utilitarianism** and **Tactile Chunking**. The aesthetic strips away decorative ambiguity in favor of maximum legibility, assertive boundaries, and immediate cognitive clarity. Surfaces are solid, tactile, and distinct, eliminating low-contrast blends, subtle drop-shadows, and micro-interactions. The emotional tone is reassuring, empowering, crystal-clear, and uncompromisingly functional.

## Colors

The palette is built strictly to exceed WCAG AAA requirements with extreme luminance differential across all interactive states.

- **Base Canvas:** Pure deep black (`#000000`) provides maximum absorption and contrast against light elements.
- **Surfaces & Cards:** Heavy charcoal containers (`#18181B` for baseline card containers, `#222225` for elevated or nested modules). These provide distinct visible boundaries without softening into the black canvas.
- **Primary Accent:** Ultra-vivid safety yellow (`#FFD600`), commanding immediate focal hierarchy for active states, key buttons, and active indicators. Contrast against black is approximately 16.5:1.
- **Secondary Accent:** Muted soft amber (`#FDE047`), designated for subheadings, category tags, and secondary metadata, maintaining over 14:1 contrast while preserving hierarchy under primary yellow.
- **Functional Semantics:**
  - Positive/Success: Clear emerald green (`#22C55E`).
  - Critical/Error: Vivid safety red-orange (`#EF4444`).
- **Foreground Text:** Solid pure white (`#FFFFFF`) for primary headings, essential labels, and critical numbers. Never use thin gray text; all supporting text sits at or above `#E4E4E7` or `#FDE047`.

## Typography

The type system prioritizes character distinction, open counters, unambiguous numerals, and elevated sizes:

- **Atkinson Hyperlegible Next** provides maximum legibility for body, subheadings, and textual narratives. It explicitly differentiates glyphs that frequently cause confusion (e.g., uppercase `I`, lowercase `l`, and digit `1`).
- **Space Grotesk** is deployed across critical numbers, monetary values, metric summaries, and button labels for its wide structural footprints and commanding presence.
- **Scale Guardrails:**
  - Absolute minimum body copy size is **18px**. Secondary explanations never drop below this threshold.
  - Primary headline and numeric pricing tokens scale up to **48px–56px** to ensure scanning distance from over a meter away.
  - Line-height rules enforce generous vertical breathing rooms (1.4x to 1.5x) to eliminate line crowding for low-vision reading aids.

## Layout & Spacing

The layout is built upon an anti-fatigue, single-column or dual-column fluid block model:

- **Touch & Tremor Architecture:** Spacing is generous to prevent accidental multi-taps. A minimum gap of `space-md` (20px) is maintained between all independent clickable elements.
- **Adaptive Grid:**
  - **Mobile:** Single-column stacked stream. Fluid 100% width with 16px lateral safety margins. Avoid complex split views.
  - **Tablet & Desktop:** Centered fixed-width containers capped at `768px` for readability lists, or an 8-column wide container maxing at `1080px`. Never spread critical reading pairs across vast ultrawide displays.
- **Rhythm & Structure:** Dense clusters are prohibited. Every card container isolates a single concept or action item, using standard structural margins to group related contextual data clearly.

## Elevation & Depth

This system intentionally eliminates blur-based drop shadows, gradients, and subtle translucent layers. Blur effects impair edge recognition for visually impaired users and wash out under sunlight.

Depth is achieved through **High-Contrast Structural Borders and Flat Layering**:
- **Layer 0 (Canvas):** Pure `#000000`.
- **Layer 1 (Cards & Groups):** Flat solid `#18181B` enclosed with a crisp 2px solid `#3F3F46` border.
- **Layer 2 (Elevated & Active Containers):** Solid `#222225` with an assertive 3px solid `#FFD600` perimeter border.
- **Focus & Selection Indication:** A solid 4px outline ring in `#FFD600` separated by a 2px pure black gap (`box-shadow: 0 0 0 2px #000000, 0 0 0 6px #FFD600`).

## Shapes

The design uses distinct, tactile rounded surfaces (`roundedness: 2`). Sharp corners create visual harshness, while pill shapes can diminish the perception of stable touch surface area.

- Standard buttons and cards use `16px` to `20px` border radius (`rounded-lg` to `rounded-xl`).
- Inputs and touch tiles use `16px` curvature.
- Radii are preserved proportionally when containers are nested, ensuring visual boundaries remain consistent and identifiable.

## Components

### Buttons
- **Touch Bounds:** Absolute minimum height of **72px** and full-width or half-width footprints. Minimum touch width is 72px for square action buttons.
- **Primary Buttons:** High-contrast `#FFD600` background with pure `#000000` extra-bold text (`label-lg`). Border is 2px solid `#FFD600`.
- **Secondary Buttons:** Solid `#18181B` surface, 3px solid `#FFFFFF` border, pure `#FFFFFF` bold text.
- **Active / Pressed State:** Inverts cleanly or reveals an immediate 4px solid outline. No slow transitions or animated scale shrinks.

### Inputs & Form Controls
- **Height & Frame:** Minimum 72px field height with a baseline 3px solid `#71717A` border on `#18181B` background.
- **Focus State:** Border shifts to 4px solid `#FFD600` with high-contrast text and a persistent label that never shrinks below 18px.
- **Icons:** Input icons (e.g., search magnifier, clear icon) must measure at least 32x32px with dedicated 48x48px hit areas.

### Cards & Price Tiles
- **Hierarchy:** Primary container surface is `#18181B` outlined with a distinct 2px border in `#3F3F46`.
- **Price Displays:** Figures are rendered using `price-huge` (36px–48px) in pure `#FFFFFF`, paired with clear currency descriptors.
- **Comparative Badges:** Solid `#FFD600` fills with bold black text indicating discounts, savings, or alert conditions.

### Checkboxes & Radio Controls
- **Hit Area:** Minimum 72px total row target.
- **Indicator Size:** Physical box/circle size is 36x36px with a 3px border.
- **Selected State:** Complete high-contrast `#FFD600` interior fill featuring a heavy black checkmark or dot, accompanied by immediate bolding of the label.

### Lists & Navigation
- **Dividers:** Thick 2px solid horizontal dividers (`#27272A`) between list tiles.
- **Row Architecture:** Each list item functions as an independent chunked row with a minimum vertical height of 80px, containing high-visibility trailing chevron icons (minimum 28px).