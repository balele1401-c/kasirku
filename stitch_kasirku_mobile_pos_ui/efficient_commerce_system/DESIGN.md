---
name: Efficient Commerce System
colors:
  surface: '#f8f9fa'
  surface-dim: '#d9dadb'
  surface-bright: '#f8f9fa'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f3f4f5'
  surface-container: '#edeeef'
  surface-container-high: '#e7e8e9'
  surface-container-highest: '#e1e3e4'
  on-surface: '#191c1d'
  on-surface-variant: '#3d4947'
  inverse-surface: '#2e3132'
  inverse-on-surface: '#f0f1f2'
  outline: '#6d7a77'
  outline-variant: '#bcc9c6'
  surface-tint: '#006a61'
  primary: '#00685f'
  on-primary: '#ffffff'
  primary-container: '#008378'
  on-primary-container: '#f4fffc'
  inverse-primary: '#6bd8cb'
  secondary: '#006b5e'
  on-secondary: '#ffffff'
  secondary-container: '#96f3e1'
  on-secondary-container: '#007164'
  tertiary: '#00685c'
  on-tertiary: '#ffffff'
  tertiary-container: '#008375'
  on-tertiary-container: '#f4fffb'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#89f5e7'
  primary-fixed-dim: '#6bd8cb'
  on-primary-fixed: '#00201d'
  on-primary-fixed-variant: '#005049'
  secondary-fixed: '#96f3e1'
  secondary-fixed-dim: '#7ad7c6'
  on-secondary-fixed: '#00201b'
  on-secondary-fixed-variant: '#005046'
  tertiary-fixed: '#62fae3'
  tertiary-fixed-dim: '#3cddc7'
  on-tertiary-fixed: '#00201c'
  on-tertiary-fixed-variant: '#005047'
  background: '#f8f9fa'
  on-background: '#191c1d'
  surface-variant: '#e1e3e4'
typography:
  display-lg:
    fontFamily: Inter
    fontSize: 48px
    fontWeight: '700'
    lineHeight: 56px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '600'
    lineHeight: 40px
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  title-lg:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  body-lg:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 26px
  body-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-lg:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.1px
  label-md:
    fontFamily: Inter
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
  base: 8px
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
  gutter: 16px
  margin-mobile: 16px
  margin-tablet: 24px
---

## Brand & Style

This design system is built for the high-speed, high-stakes environment of micro, small, and medium enterprises (UMKM). The brand personality is grounded in **reliability** and **operational efficiency**, stripping away visual clutter to focus on transaction speed.

The aesthetic follows a **Modern Corporate** approach, heavily influenced by Material Design 3 principles but optimized for the Indonesian retail landscape. It utilizes a **Minimalist** foundation with **Tactile** affordances—specifically large touch targets and clear state changes—to ensure that merchants can operate the interface confidently even in low-light shops or high-traffic cafes. The emotional response should be one of "effortless control."

## Colors

The palette is anchored by **Emerald Teal**, a color that signals growth and stability. 

- **Primary (#0D9488):** Used for the most critical actions, such as "Charge" or "Print Receipt." It provides the necessary contrast for quick ocular recognition.
- **Secondary (#99F6E4):** A soft sage/teal used for container backgrounds and subtle accents that group related information without competing for attention.
- **Neutral (#F9FAFB):** The canvas color. It is a very light gray rather than pure white to reduce screen glare during long shifts.
- **Semantic Accents:** Success Green is reserved for completed payments, while Danger Red is strictly for voiding transactions or deleting items.

## Typography

The design system utilizes **Inter** for its exceptional legibility and neutral character. Given the "on-the-go" nature of POS usage, font sizes are scaled up by approximately 15% compared to standard web apps.

**Display and Headline** roles are used for order totals and numerical values—the most important data points in a transaction. **Body Large** is the default for product names to ensure they are readable at arm's length. **Label** styles are used for secondary metadata like SKU numbers or timestamps. For mobile views, headlines scale down to prevent awkward word wrapping in narrow product lists.

## Layout & Spacing

The layout operates on a strict **8px grid system** to maintain rhythmic consistency. 

- **Tablet (Primary Device):** Uses a split-screen fixed grid. The left 60% is a fluid container for the product catalog (using a responsive grid of cards), and the right 40% is a fixed-width sidebar for the "Current Basket."
- **Mobile:** A single-column fluid layout where the "Basket" is an expandable bottom sheet, keeping the product selection front and center.
- **Touch Targets:** All interactive elements maintain a minimum height of 48px to accommodate fast, potentially imprecise thumb or finger taps in a busy shop environment.

## Elevation & Depth

This system uses **Tonal Layers** as the primary method of showing depth, minimizing the use of shadows to keep the UI feeling "flat" and modern.

1.  **Level 0 (Base):** Neutral (#F9FAFB) for the main background.
2.  **Level 1 (Surface):** White (#FFFFFF) for cards and main navigation containers. No shadow, but a 1px border of Surface Variant (#E5E7EB) defines the edge.
3.  **Level 2 (Active):** When a product is selected or a modal is opened, a soft ambient shadow (Blur 12px, 4% Opacity, Black) is applied to lift the element.
4.  **Interactive States:** Pressed states utilize a tonal shift (darkening the primary color by 10%) rather than a change in elevation, providing immediate tactile feedback.

## Shapes

The shape language is friendly and approachable, utilizing a **Rounded** philosophy. Standard components (buttons, input fields) use a 0.5rem (8px) radius. Larger layout containers, such as product cards and modal sheets, utilize `rounded-xl` (24px) to create a distinct, modern "app-like" feel that differentiates the software from legacy, sharp-edged POS systems. This softness makes the interface feel less intimidating to new business owners.

## Components

- **Buttons:** 
    - *Primary:* Solid Teal (#0D9488) with white text. High-emphasis for "Pay" or "Confirm."
    - *Secondary:* Sage background with Teal text. Used for "Add Discount" or "Edit Item."
    - *Action Icons:* Circular buttons for "Plus/Minus" quantity adjustments to prevent errors.
- **Cards:** 
    - Product cards must feature high-quality imagery or clear initial-based avatars. 
    - Use a 1px stroke (#E5E7EB) instead of a shadow for the default state.
- **Input Fields:** 
    - Outlined style with the label nested in the border (MD3 style). 
    - Focused state uses a 2px Teal border for high visibility.
- **Numpad:** 
    - A custom, large-scale grid of buttons for manual price entry or quantity adjustments. Buttons are separated by 8px gutters to prevent fat-fingering.
- **Chips:** 
    - Used for product categories (e.g., "Food", "Drinks", "Snacks"). Selected chips use the Primary color; unselected chips use the Surface Variant.
- **Bottom Sheet:** 
    - On mobile, the summary of the transaction resides in a persistent bottom sheet that can be swiped up to view the full itemized list.