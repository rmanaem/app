Project Codename: Obsidian & Steel

Aesthetic: Industrial Luxury / Matte Monolith
Core Philosophy: "Log Fast. Train Smart."

1. Core Identity

A premium, minimalist fitness tracker designed for high-performance individuals. It rejects the "gamified" and "cluttered" look of competitors in favor of a precision instrument aesthetic.

Visual Metaphor: High-end audio equipment (solid state), Leica Monochrom cameras, milled steel, matte ceramic.

Emotional Vibe: Quiet, confident, solid, heavy, precise.

2. The Physics (Material System)

The app is built on a strict set of physical rules. We DO NOT use blur or glassmorphism. We use solid materials and light interaction.

A. The Canvas (Background)
   - Color: Deep Onyx (#050505).
   - Properties: Infinite depth. It absorbs light. It is the void on which the machine sits.

B. The Surface (Cards & Containers)
   - Material: "Matte Ceramic" / "Stealth Coating".
   - Fill: Solid Dark Grey (#1C1C1E). 100% Opacity.
   - Blur: None. Zero.
   - Feel: Dense and substantial. It sits *on top* of the onyx background. It blocks what is behind it.

C. The Edges (Borders & Separation)
   - Style: "Milled Steel" / "Light Catcher".
   - Properties: Razor-thin (1px).
   - Idle State: Dark Steel (#3A3A3C). A subtle groove defining the shape.
   - Active State: "Polished Silver". A sharp, bright border (#E5E5EA) that mimics light catching a machined edge.
   - Intent: We use borders, not shadows or blurs, to define hierarchy.

D. The Light (Accents & Typography)
   - Primary Accent: Stark White / Brushed Silver.
   - Logic: "OLED Pop". Elements glow because they are the light source, or they reflect light because they are polished metal.
   - Typography:
     - Headlines: SF Pro Rounded. Bold, tight tracking. Pure White (#FFFFFF).
     - Body: Argent Grey (#E5E5EA). High contrast for readability.
     - Subtext: Cool Grey (#8E8E93).

3. Structural Archetypes

A. Dashboard Structure: "The Stack"
   - Top Layer: The Hero Ring (Silver/White).
   - Bottom Layer: The Context Stack (Vertical list of Ceramic Platters).
   - Navigation: Floating Ceramic Island. Solid pill shape, detached from edges.

B. Input Mechanics ("Tactile Precision")
   - Selectors: "Mode Dials". Horizontal carousels with haptic "thuds" for major state changes.
   - Weight Input: "The Ruler". Continuous scrolling with light "clicks".
   - Focus Mode: When interacting with an input, non-active elements fade to 20% opacity (Cinematic Focus).

4. Design Tokens (Source of Truth)

Colors (AppColors)
| Token           | Hex Value | Description                                  |
|-----------------|-----------|----------------------------------------------|
| bg              | #050505   | Deepest Onyx Background                      |
| surface         | #1C1C1E   | Matte Ceramic (Solid Card Background)        |
| surfaceHighlight| #2C2C2E   | Lighter Ceramic (For nested elements)        |
| borderIdle      | #3A3A3C   | Dark Steel Edge (Inactive)                   |
| borderActive    | #E5E5EA   | Polished Silver Edge (Active/Selected)       |
| ink             | #FFFFFF   | Pure White (Primary Headings/Data)           |
| inkSecondary    | #E5E5EA   | Argent (Body Text)                           |
| inkTertiary     | #8E8E93   | Cool Grey (Labels/Subtext)                   |
| accent          | #E5E5EA   | Brushed Steel (Active Elements/Icons)        |

Typography (AppTypography)
- Hero: 48pt+, Bold, Tight Spacing (-1.0).
- Display: 32pt, Semi-Bold.
- Body: 16pt, Regular.
- Font Family: SF Pro Rounded.

5. Future Implementation Notes

- Motion: Fast, snappy, non-linear. Elements snap into place like magnets.
- Haptics: Distinct "textures" for different inputs (Heavy Thud vs. Light Click).
- Charts: High contrast lines on solid backgrounds. No gradients under the line unless subtle.