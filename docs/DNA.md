Project Codename: Obsidian & Steel

Aesthetic: Industrial Luxury / Dense Smoke
Core Philosophy: "Log Fast. Train Smart."

1. Core Identity

A premium, minimalist fitness tracker designed for high-performance individuals. It rejects the "gamified" and "cluttered" look of competitors in favor of a precision instrument aesthetic.

Visual Metaphor: High-end audio equipment, milled steel, tinted privacy glass.

Emotional Vibe: Quiet, confident, expensive, precise.

2. The Physics (Material System)

The app is built on a strict set of physical rules to ensure consistency.

A. The Canvas (Background)

Color: Deep Onyx (#050505).

Properties: Not pitch black (to avoid OLED smearing), but deep enough to feel infinite. It provides high contrast for the steel accents.

B. The Glass (Cards & Surfaces)

Material: "Dense Smoke" / "Tinted Privacy Glass".

Fill: High-opacity Dark Grey (#151517 at ~80% opacity).

Blur: Heavy background blur (Sigma 20).

Feel: Substantial and solid. It does NOT look like thin plastic or white frost. It absorbs light rather than reflecting it.

C. The Edges (Borders)

Style: Milled Steel.

Properties: Razor-thin (0.5px), crisp, non-glowing.

Color: Deep Steel Grey (#3A3A3C).

Intent: To define the hierarchy with precision, mimicking a machined edge.

D. The Light (Accents & Typography)

Primary Accent: Brushed Steel / Silver.

Active State: "Silver sheen". A subtle gradient from Silver to Transparent.

Typography:

Headlines: SF Pro Rounded (or similar geometric sans). Bold, tight tracking.

Body: Argent Grey (#E5E5EA). We avoid pure white (#FFFFFF) to reduce eye strain and maintain the "stealth" look.

3. Structural Archetypes

A. Dashboard Structure: "Hybrid Vertical Stack"

Top Layer (Pinned): The Hero Ring. A massive, glanceable circular progress indicator (Calorie Budget) in Brushed Steel.

Bottom Layer (Scrollable): The Context Stack. A vertical list of wide, full-width "Platter" cards (Macros, Workout, Trends).

Navigation: Floating Glass Island. A translucent pill-shaped tab bar at the bottom, detached from the edges.

B. Input Mechanics ("Log Fast")

Weight Input: Tactile Ruler. A horizontal scrolling ruler that mimics a physical scale. Precise and satisfying.

Food Input: Custom Industrial Numpad. A large, borderless numeric keypad for rapid entry. No system keyboards.

4. Design Tokens (Source of Truth)

Colors (AppColors)

Token

Hex Value

Description

bg

#050505

Deepest Onyx Background

surface

#121212

Matte Dark Grey (Non-glass)

glassFill

#CC151517

Dense Smoke (80% Opacity)

glassBorder

#3A3A3C

Crisp Steel Edge

ink

#E5E5EA

Argent (Primary Text)

inkSubtle

#8E8E93

Cool Grey (Secondary Text)

accent

#D1D1D6

Brushed Steel (Active Elements)

ringTrack

#1C1C1E

Dark Steel Track

ringActiveStart

#E5E5EA

Bright Silver Gradient Start

ringActiveEnd

#636366

Faded Steel Gradient End

Typography (AppTypography)

Hero: 48pt+, Bold, Tight Letter Spacing (-1.0).

Display: 32pt, Semi-Bold.

Body: 16pt, Regular, Relaxed Spacing.

Font Family: SF Pro Rounded (Primary), JetBrains Mono (Data/Tables - Optional).

5. Future Implementation Notes

Charts: Use Area Gradients (Silver fading to transparent) for weight trends.

Icons: SF Symbols (Filled). Solid forms match the "Industrial" aesthetic better than thin outlines.

Motion: Fast, snappy transitions