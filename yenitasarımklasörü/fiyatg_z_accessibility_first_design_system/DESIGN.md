---
name: FiyatGöz Accessibility-First Design System
colors:
  surface: '#f8f9ff'
  surface-dim: '#cbdbf5'
  surface-bright: '#f8f9ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#eff4ff'
  surface-container: '#e5eeff'
  surface-container-high: '#dce9ff'
  surface-container-highest: '#d3e4fe'
  on-surface: '#0b1c30'
  on-surface-variant: '#3c4a42'
  inverse-surface: '#213145'
  inverse-on-surface: '#eaf1ff'
  outline: '#6c7a71'
  outline-variant: '#bbcabf'
  surface-tint: '#006c49'
  primary: '#006c49'
  on-primary: '#ffffff'
  primary-container: '#10b981'
  on-primary-container: '#00422b'
  inverse-primary: '#4edea3'
  secondary: '#565e74'
  on-secondary: '#ffffff'
  secondary-container: '#dae2fd'
  on-secondary-container: '#5c647a'
  tertiary: '#006398'
  on-tertiary: '#ffffff'
  tertiary-container: '#4aaaef'
  on-tertiary-container: '#003c5e'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#6ffbbe'
  primary-fixed-dim: '#4edea3'
  on-primary-fixed: '#002113'
  on-primary-fixed-variant: '#005236'
  secondary-fixed: '#dae2fd'
  secondary-fixed-dim: '#bec6e0'
  on-secondary-fixed: '#131b2e'
  on-secondary-fixed-variant: '#3f465c'
  tertiary-fixed: '#cce5ff'
  tertiary-fixed-dim: '#93ccff'
  on-tertiary-fixed: '#001d31'
  on-tertiary-fixed-variant: '#004b73'
  background: '#f8f9ff'
  on-background: '#0b1c30'
  surface-variant: '#d3e4fe'
typography:
  display-lg:
    fontFamily: Space Grotesk
    fontSize: 44px
    fontWeight: '700'
    lineHeight: 52px
    letterSpacing: -0.02em
  display-lg-mobile:
    fontFamily: Space Grotesk
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.01em
  headline-lg:
    fontFamily: Space Grotesk
    fontSize: 28px
    fontWeight: '600'
    lineHeight: 36px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Space Grotesk
    fontSize: 22px
    fontWeight: '600'
    lineHeight: 28px
  body-lg:
    fontFamily: Atkinson Hyperlegible Next
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 26px
  body-md:
    fontFamily: Atkinson Hyperlegible Next
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-sm:
    fontFamily: Atkinson Hyperlegible Next
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-receipt:
    fontFamily: JetBrains Mono
    fontSize: 15px
    fontWeight: '500'
    lineHeight: 20px
    letterSpacing: 0.02em
  label-currency-lg:
    fontFamily: JetBrains Mono
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 28px
    letterSpacing: -0.03em
  kolay-headline:
    fontFamily: Atkinson Hyperlegible Next
    fontSize: 30px
    fontWeight: '700'
    lineHeight: 38px
    letterSpacing: 0.01em
  kolay-body:
    fontFamily: Atkinson Hyperlegible Next
    fontSize: 20px
    fontWeight: '700'
    lineHeight: 30px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  gutter: 1rem
  gutter-tablet: 1.5rem
  margin: 1rem
  margin-tablet: 2rem
  margin-desktop: 3rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 1rem
  space-lg: 1.5rem
  space-xl: 2rem
  target-min-standard: 3rem
  target-min-kolay: 4.5rem
---

## Brand & Style

This design system powers an ultra-accessible Turkish fintech retail tool designed for smart price scanning, live basket tallying, unit-rate comparisons, and financial clarity. The aesthetic merges Material 3 structured surfaces with tactile physical metaphors—notably the clean typography, micro-perforations, and stark data hierarchy of thermal supermarket receipts.

### Brand Personality & Emotional Impact
- **Radical Inclusivity:** Zero cognitive friction across visual, motor, and neurodivergent spectrums. The UI guarantees confidence at checkout lanes.
- **Fiscal Clarity & Precision:** Utilitarian, reliable numbers displayed without marketing fluff. Financial information feels mathematically sound and trustworthy.
- **Tactile Utility:** Micro-interactions mimic durable physical instruments: mechanical clicks, thermal paper tears, stamped price tags, and audible radar pings.

### Modality Profiles
1. **Standart Mod:** Contemporary fintech styling. Emerald green signals savings and affordability, deep navy structures financial data, set against crisp cool-gray backgrounds.
2. **Kolay Mod (Ultra High Contrast):** Maximum readability for low-vision and elderly demographics. Hard-contrast palette (`#000000`, `#FFD600`, `#FFFFFF`), bold strokes, zero ambient blurs, and magnified tap areas.
3. **Renk Körlüğü Güvenli Mod (Colorblind-Safe):** Adheres to Okabe-Ito chromatic standards (`#0072B2` Cobalt, `#E69F00` Amber). Never communicates state by hue alone—utilizes distinct physical hatch marks, diagonal zebra striping, and semantic geometric iconography.
4. **Sesli Radar Mod (Blind / Audio-Haptic):** Complete screen-reader optimization with non-visual spatial positioning. Focus outlines feature high-visibility rings paired with multi-frequency haptic tick cues and pitch-scaled audio sonar for scanning barcodes within the camera frame.

## Colors

The system uses dedicated palette sets mapped to active accessibility profiles while preserving consistent CSS token keys across all views.

### 1. Standart Mod Palette
- **Primary (`#10B981` Emerald Green):** Success, confirmed savings, scanner reticle lock, discount tags.
- **Secondary (`#0F172A` Deep Navy):** Dominant text, structural frames, dark toolbars, numeric totals.
- **Tertiary (`#0284C7` Azure):** Informational callouts, unit conversion switches, category badges.
- **Neutral Base:** Background canvas (`#F8FAFC`), Surface container (`#FFFFFF`), Border stroke (`#E2E8F0`), Subtle text (`#64748B`).

### 2. Kolay Mod (High-Contrast Mode)
- **Background Canvas:** `#000000` (Pure Black).
- **Primary Accent / Interactive:** `#FFD600` (Safety Canary Yellow, WCAG AAA against `#000000`).
- **Foreground / Data:** `#FFFFFF` (Pure White).
- **Divider & Border Tokens:** Minimum 2px solid `#FFD600` or `#FFFFFF`. Ambient shadows are removed.

### 3. Renk Körlüğü Güvenli Mod (Colorblind-Safe Okabe-Ito)
- **Positive / Accept / Cheaper:** `#0072B2` (Cobalt Blue) paired with upward chevron `▲` and 45° diagonal hatching.
- **Alert / Costlier / Action:** `#E69F00` (Amber Orange) paired with exclamation shield `!` and horizontal dot stippling.
- **Neutral Surface / Inactive:** `#D55E00` (Vermillion) and `#F0E442` (Yellow-tint base).

### 4. Sesli Radar Mod (Audio-Haptic High Visibility)
- **Focus Rings:** 4px outer stroke `#FFD600` with 2px interior gap `#000000` for universal contrast on light and dark surfaces.
- **Reticle Feedback:** In-target lock `#00FF66`, hunting/seeking state `#FFFFFF`.

## Typography

The typographic hierarchy uses three distinct typefaces to separate visual branding, prolonged readability, and numerical precision:

1. **Space Grotesk (Display & Headings):** Geometric, precise, modern. Provides immediate character to app bars, banner sums, and modal titles.
2. **Atkinson Hyperlegible Next (Body & UI Copy):** Built deliberately for low-vision legibility with distinct letterforms (unambiguous `I`, `l`, `1`, and open counter spaces). Powers all instructions, Turkish product descriptions, and basket items.
3. **JetBrains Mono (Numeric Data & Receipt Tally):** Fixed-pitch tabular figures. Guarantees that decimal points, Turkish Lira (`₺`) symbols, and unit measurements (`kg`, `lt`, `adet`) align vertically without jitter during camera-based OCR reading.

### Turkish Character Support
All chosen fonts feature verified full unicode support for extended Turkish glyphs: `ğ, Ğ, ı, İ, ö, Ö, ü, Ü, ş, Ş, ç, Ç`. Turkish dotless `ı` and dotted `i` retain clear optical distinction at all scaling sizes.

## Layout & Spacing

The layout model is anchored by a mobile-first fluid grid with strict physical tap target constraints:
- **Mobile Handheld (up to 599px):** Single-column stack, 4-column sub-grid for numpads and quick filters. Margins are fixed at `1rem` (16px), gutters at `1rem`.
- **Tablet / In-Store Cart Mounted (600px - 1023px):** 8-column layout. Camera scanner viewport is fixed in a left split-pane (5 columns) with the running basket total locked to the right (3 columns).
- **Desktop / Backoffice (1024px+):** 12-column layout max-width 1200px centered.

### Touch Target Floor Values
- **Standart Mod:** Hard minimum target size of `48px` (3rem) height and width for any tappable element, complete with an 8px visual exclusion boundary.
- **Kolay Mod:** Hard minimum target size of `72px` (4.5rem) height and width. Spacing between interactive components expands to a minimum of `1rem` (16px) to eliminate accidental adjacent button presses.

## Elevation & Depth

This design system avoids deep, decorative shadows in favor of functional structural layers that preserve contrast ratios:

### 1. Standart Mod Tonal Layering
- **Surface 0 (Canvas):** `#F8FAFC` — Base background for app views.
- **Surface 1 (Cards, List Elements):** `#FFFFFF` with a crisp 1px perimeter border in `#E2E8F0` and an ambient floor shadow: `box-shadow: 0 2px 4px rgba(15, 23, 42, 0.04), 0 1px 2px rgba(15, 23, 42, 0.02)`.
- **Surface 2 (Floating Action Bars, Bottom Sheets):** `#FFFFFF` with `box-shadow: 0 10px 25px -5px rgba(15, 23, 42, 0.08), 0 8px 10px -6px rgba(15, 23, 42, 0.04)`.
- **Surface 3 (Scanner Overlays & Modals):** `#0F172A` with 90% opacity (no blur filter to keep GPU rendering snappy during camera OCR operations).

### 2. Receipt Aesthetic Depth
- Physical receipt containers use a top/bottom CSS zigzag mask or micro-perforated dashed divider line (`2px dashed #CBD5E1`) separating store header, line items, and final total.
- Scanned items animate into the basket with an extrusion motion (`translateY(-2px)` with an instantaneous tactile snapback).

### 3. Kolay Mod Elevation
Shadows are entirely disabled. Elevation is conveyed strictly through high-contrast structural borders:
- Rest: `2px solid #FFFFFF` on `#000000` background.
- Active/Focused: `4px solid #FFD600` with an inverted background fill (`#FFD600` surface with `#000000` text).

## Shapes

The design system uses a rounded geometry level of **2 (Rounded)** for standard modes to produce approachable, ergonomic components that feel friendly in hand.

- **Standard Cards & Modules:** `rounded-lg` (16px) corners.
- **Scanner Viewfinder:** `rounded-xl` (24px) corners with distinct 4px corner reticles.
- **Interactive Buttons:** `rounded-lg` (16px) in standard mode.
- **Kolay Mod Override:** Buttons and cards reduce curvature to `8px` (`0.5rem`) with 3px to 4px crisp borders to maximize visible content area and preserve optical alignment for users with macular degeneration.
- **Thermal Receipt Cutouts:** Crisp non-rounded saw-tooth edges on bottom cards (generated via repeating linear gradients).

## Components

### Buttons & Action Triggers
- **Primary Action (Standard):** Height 56px, background `#10B981`, foreground `#FFFFFF`, border-radius 16px. Font: `Space Grotesk` Medium 18px. Active press scales to `0.98` with high-frequency 20ms haptic tap.
- **Primary Action (Kolay Mod):** Height 72px, background `#FFD600`, foreground `#000000`, 4px solid `#FFFFFF` focus ring, border-radius 8px. Font: `Atkinson Hyperlegible Next` Bold 22px.
- **Secondary Action:** Outlined style with 2px stroke in `#0F172A`, transparent surface, filled on hover/press.

### Input Fields & Price Adjustment
- **Numeric Keypad & Scanner Inputs:** Large form factors with tabular figures (`JetBrains Mono`). Input heights minimum 64px.
- Floating currency affix (`₺`) anchored left; unit denominator (`/ kg`, `/ adet`) anchored right in high-contrast gray.
- Clear error states: 2px solid `#E11D48` accompanied by an inline warning triangle icon and dynamic screen-reader announcement (`aria-live="assertive"`).

### Price Tag & Comparison Cards (Thermal Receipt Inspired)
- **Container:** Pure `#FFFFFF` background with `2px dashed #E2E8F0` segmenting item pricing from unit math.
- **Unit Comparison Pill:** Displays "Birim Fiyat" (Unit Price) in bold, showing exact calculations (e.g., `42,50 ₺ / 100g` vs `49,90 ₺ / 100g`) with percentage differences marked by bold directional badges.
- **Colorblind-Safe Badges:** Cheaper items receive `#0072B2` background + diagonal line texture + text "DAHA UCUZ ▲". Costlier items receive `#E69F00` + dot texture + text "DAHA PAHALI !".

### Lists & Running Basket Items
- Full-width list elements with swipe gestures for rapid deletion or quantity adjustments.
- Minimum row height 64px (Standart Mod) and 80px (Kolay Mod).
- High visual separation: 1px divider lines with 8px whitespace padding between adjacent records.

### Scanner Reticle & Audio Radar
- Viewfinder box in central screen with dynamic color cues: Searching (Neutral white crosshairs), Item Detected (Pulsing `#0284C7`), Lock & Read (Crisp solid `#10B981`).
- **Audio Radar Feed:** Emits audio beeps whose frequency rises as the barcode centers in the camera bounding box, ending with a cash register "tink" upon successful OCR capture.