---
name: Premium Arabic Commerce
colors:
  surface: '#f9f9fb'
  surface-dim: '#d9dadc'
  surface-bright: '#f9f9fb'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f3f3f5'
  surface-container: '#eeeef0'
  surface-container-high: '#e8e8ea'
  surface-container-highest: '#e2e2e4'
  on-surface: '#1a1c1d'
  on-surface-variant: '#434652'
  inverse-surface: '#2f3132'
  inverse-on-surface: '#f0f0f2'
  outline: '#737783'
  outline-variant: '#c3c6d4'
  surface-tint: '#2b5bb5'
  primary: '#003178'
  on-primary: '#ffffff'
  primary-container: '#0d47a1'
  on-primary-container: '#a1bbff'
  inverse-primary: '#b0c6ff'
  secondary: '#006a62'
  on-secondary: '#ffffff'
  secondary-container: '#81f3e5'
  on-secondary-container: '#006f66'
  tertiary: '#602100'
  on-tertiary: '#ffffff'
  tertiary-container: '#853100'
  on-tertiary-container: '#ffa781'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#d9e2ff'
  primary-fixed-dim: '#b0c6ff'
  on-primary-fixed: '#001945'
  on-primary-fixed-variant: '#00429c'
  secondary-fixed: '#84f5e8'
  secondary-fixed-dim: '#66d9cc'
  on-secondary-fixed: '#00201d'
  on-secondary-fixed-variant: '#005049'
  tertiary-fixed: '#ffdbcd'
  tertiary-fixed-dim: '#ffb596'
  on-tertiary-fixed: '#360f00'
  on-tertiary-fixed-variant: '#7d2d00'
  background: '#f9f9fb'
  on-background: '#1a1c1d'
  surface-variant: '#e2e2e4'
typography:
  display-lg:
    fontFamily: IBM Plex Sans Arabic
    fontSize: 30px
    fontWeight: '700'
    lineHeight: 42px
  headline-md:
    fontFamily: IBM Plex Sans Arabic
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 34px
  headline-sm:
    fontFamily: IBM Plex Sans Arabic
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  body-lg:
    fontFamily: IBM Plex Sans Arabic
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: IBM Plex Sans Arabic
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-md:
    fontFamily: IBM Plex Sans Arabic
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 20px
  label-sm:
    fontFamily: IBM Plex Sans Arabic
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  margin-mobile: 16px
  margin-tablet: 24px
  gutter: 16px
  stack-sm: 8px
  stack-md: 16px
  stack-lg: 24px
---

## Brand & Style

This design system is built for a high-end, modern e-commerce experience tailored specifically for Arabic-speaking markets. The brand personality is **sophisticated, efficient, and deeply trustworthy**, moving away from cluttered traditional marketplaces toward a curated, editorial feel.

The aesthetic follows a **Minimalist-Corporate** hybrid. It utilizes expansive whitespace to let product imagery breathe, combined with precise, systematic layouts. The emotional response should be one of "effortless luxury"—where the interface recedes to highlight the quality of the goods and the ease of the transaction. All interactions are grounded in a Right-to-Left (RTL) mental model, ensuring that the flow of visual information matches the natural reading direction of the script.

## Colors

The palette is anchored by **Deep Indigo (#0D47A1)**, chosen for its historical association with reliability and prestige in professional sectors. This is complemented by a secondary **Teal (#26A69A)** used sparingly for accentuation or call-to-action highlights.

The neutral system is critical for the "Premium" feel; instead of pure blacks, it uses a range of cool grays. Backgrounds should primarily use a soft off-white to reduce eye strain and provide a canvas for card-based components. Functional colors (Success, Warning, Danger) are calibrated for high legibility against the primary neutral background while maintaining a professional saturation level that doesn't feel "neon" or "playful."

## Typography

The design system utilizes **IBM Plex Sans Arabic** for its exceptional clarity and modern structural integrity. Unlike traditional calligraphic fonts, this typeface offers a neutral, systematic look that excels in digital UI.

**RTL Logic:**
- Text alignment is predominantly **Right**.
- Character spacing (letter-spacing) is set to `0` as Arabic script is cursive and should not be tracked out.
- Line heights are slightly more generous than Latin counterparts (typically 1.4x to 1.5x the font size) to accommodate the ascenders and descenders unique to Arabic characters.
- Use **Bold (700)** sparingly for titles and **Medium (500)** for primary labels to ensure a clear information hierarchy without visual noise.

## Layout & Spacing

This system follows a **Mobile-First RTL Fluid Grid**. The primary layout container uses 16px side margins on mobile, expanding to 24px on larger devices.

**Layout Principles:**
- **RTL Flow:** The eye should travel from the top-right to the bottom-left. Navigation icons, "Back" buttons (pointing right `→`), and progress bars must be mirrored.
- **Vertical Rhythm:** A base-8 spacing scale is used. Components are separated by 16px or 24px depending on their semantic relationship.
- **Horizontal Alignment:** In a card-based layout, ensure product prices and titles are right-aligned. Price currencies (e.g., ر.س) should follow the numerical value in the standard localized format.

## Elevation & Depth

To maintain a premium feel, the system uses **Tonal Layers** combined with **Ambient Shadows**. We avoid heavy borders in favor of soft depth to define structure.

- **Level 0 (Background):** Soft neutral gray (#F5F5F7).
- **Level 1 (Cards/Surface):** Pure white (#FFFFFF). Features a subtle 1px border (#E0E0E0) and a soft, diffused shadow: `0px 4px 12px rgba(0, 0, 0, 0.05)`.
- **Level 2 (Floating/Modals):** Pure white with a more pronounced shadow: `0px 8px 24px rgba(0, 0, 0, 0.1)`.

Interactive elements like buttons should feel "pressed" (lower elevation) when active, rather than using high-contrast color shifts.

## Shapes

The shape language is defined as **Rounded (Level 2)**. This strikes a balance between the precision of a professional tool and the approachability of a consumer app.

- **Standard Elements (Buttons, Inputs):** 8px (0.5rem) radius.
- **Container Elements (Product Cards, Modals):** 16px (1rem) radius.
- **Small Accents (Chips, Badges):** 32px (Pill-shaped) to distinguish them from structural elements.

All corners must remain consistent; do not mix sharp and rounded corners within the same component hierarchy.

## Components

### Buttons
- **Primary:** Solid Deep Indigo with White text. 8px rounded corners. Height: 48px or 56px for main CTAs.
- **Secondary:** Transparent background with Deep Indigo border (1px) and text.
- **Loading State:** Replace text with a centered spinner; do not change button width.

### Input Fields
- **Default:** White background, 1px Gray-300 border. Label is right-aligned above the field.
- **Active/Focus:** Border changes to Primary Deep Indigo (2px).
- **Error:** Border changes to Danger Red with a supporting error message right-aligned below.

### Cards
- **Product Card:** Image at top, 16px padding for content below. Title (Bold), Category (Light Gray), and Price (Primary Color) stacked vertically.
- **Shadow:** Level 1 elevation applied.

### Bottom Navigation
- **Structure:** 4 or 5 icons with labels.
- **Active State:** Icon and Label color shift to Primary Deep Indigo. Use a 2px top-border indicator on the active tab.

### Category Chips
- **Inactive:** Light Gray background, Dark Gray text.
- **Active:** Deep Indigo background, White text.
- **Shape:** Pill-shaped (32px radius).

### Status Badges
- Used for "New," "Discount," or "Out of Stock." Small, uppercase (or equivalent bold weight in Arabic), with high contrast against the badge background. Located on the top-right corner of product images.