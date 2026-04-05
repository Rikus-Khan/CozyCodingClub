# Sunset Calculator

**Status:** In Progress  
**Author:** Cozy Coding Club  
**Date:** 2026-04-02

## Goals

- Build a beautiful, sunset-themed web calculator for basic arithmetic
- Provide rich customization: animations, fonts, button shapes, and size
- Support both mouse clicks and keyboard input
- Make it fun and visually delightful

## Non-Goals

- Scientific/graphing/programmer calculator features (future phases)
- Percentage button (not needed yet)
- History or memory functions (future phases)
- Mobile-specific optimizations (works because it's responsive, but not the focus)

## Design

### Layout

```
┌─────────────────────────────┐
│  [☀ animation] [Aa font] [◻ shape] │  ← customization bar
│                                      │
│  ┌──────────────────────────┐       │
│  │              12 + 3      │       │  ← expression line (small)
│  │                   15     │       │  ← result line (large)
│  └──────────────────────────┘       │
│                                      │
│  [ C ] [ ⌫ ] [ +/- ] [ ÷ ]        │
│  [ 7 ] [ 8 ] [  9  ] [ × ]        │
│  [ 4 ] [ 5 ] [  6  ] [ - ]        │
│  [ 1 ] [ 2 ] [  3  ] [ + ]        │
│  [   0   ]   [  .  ] [ = ]        │
│                                      │
│  ──── size slider ────              │
└─────────────────────────────┘
```

### Sunset Theme

- Background: animated gradient (deep blue → purple → coral → orange)
- Buttons: semi-transparent with warm tones, glass-like feel
- Display: dark with warm-toned text
- Overall vibe: painting of a sunset sky

### 5 Animations (cycle with button)

1. **Breathing background** — gradient slowly shifts/pulses
2. **Button ripple** — light ripple on click
3. **Display glow** — result text glows briefly on `=`
4. **Floating particles** — tiny embers/fireflies drift upward
5. **Hover warmth** — buttons warm up on hover

### 5 Fonts (cycle with button)

1. Poppins (clean rounded)
2. Nunito (soft friendly)
3. Pacifico (handwritten fun)
4. Orbitron (futuristic)
5. Quicksand (modern light)

### 3 Button Shapes (cycle with button)

1. Rounded rectangles
2. Circles
3. Squircles

### Size Slider

- Slider at bottom scales the entire calculator (CSS transform: scale)
- Calculator always stays centered on page

### Keyboard Support

| Key | Action |
|-----|--------|
| 0-9 | Input digit |
| + - * / | Operator |
| Enter/= | Evaluate |
| Backspace | Delete last digit |
| Delete | Delete last digit |
| Escape | Clear all |
| . | Decimal point |

### Calculator Logic

- Two-line display: expression on top, current number/result below
- Chained operations: `2 + 3 + 4 =` → shows `9`
- Divide by zero → shows "Error"
- +/- toggles sign of current number
- Max display length: ~12 digits (auto-shrink text if needed)

## Tech Stack

- Single `index.html` file with embedded CSS and JS
- Google Fonts for the 5 font options
- No dependencies, no build tools

## File Structure

```
calc/
├── index.html          ← everything lives here
└── specs/
    ├── README.md
    └── sunset-calculator.md
```

## Verification

1. Open `index.html` in a browser
2. Click buttons to do basic math — confirm correct results
3. Test keyboard input for all mapped keys
4. Cycle through all 5 animations — confirm each is visually distinct
5. Cycle through all 5 fonts — confirm each changes the look
6. Cycle through all 3 button shapes — confirm buttons change shape
7. Drag size slider — confirm everything scales and stays centered
8. Test `÷ 0` — confirm "Error" appears
9. Test +/- button — confirm sign toggles
10. Test chained operations like `2 + 3 + 4 =`
