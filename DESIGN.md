# Söngr visual system

## Direction

**True-black listening room**, dealt by `design-taste-frontend` as
`true-black-flat`, seed `1811764648`.

The app is a quiet black room with a record in it. Surfaces are separated by
lightness and a one-pixel rule, never glass, gradients or resting shadows.
Artwork supplies the colour. A warm VU-meter amber marks live playback and
nothing in the navigation chrome.

The idea sentence:

> A real record becomes the lead object on every surface, while the current
> listening session remains the one persistent thread through the app.

The signature element is the **listening rail**: the mini player and progress
line sit directly above the tab destinations in a slightly translucent,
dark full-width rail, forming one continuous control for the session.

## Tokens

| Role | Value | Use |
| --- | --- | --- |
| Canvas | `#000000` | App ground and bar ground |
| Surface | `#111111` | Rows, grouped settings, dock |
| Raised | `#2A2A2A` | Selected segment and nested surface |
| Rule | `#1A1A1A` | One-pixel separators |
| Primary text | `#FFFFFF` | Titles and active labels |
| Secondary text | `#B4B4B4` | Metadata and descriptions |
| Tertiary text | `#949494` | Disabled and quiet meta |
| Playback accent | `#E9A23B` | Live title, progress and playing glyph only |
| Destructive | `#E5484D` | Destructive action and error |

Radii are 8 for rows, 16 for artwork and cards, and fully round only for
compact controls. Primary controls invert to white with black labels.

## Type

The app uses the platform UI face. It is iOS-first, and the native platform
face preserves Dynamic Type, Swedish shaping and system accessibility.

- Page title: 30 pt, weight 600
- Object title: 24 pt, weight 600
- Section title: 20 pt, weight 600
- Body: 14-16 pt
- Meta: 12 pt, never below 11 pt

Weights stay at 600 or below. No tracked capitals and no monospace outside
technical values.

## Composition

- **Home:** the first enabled shelf opens with one full-width record and its
  real metadata; additional shelves follow as horizontal artwork rows. The
  header can use the wordmark or the app icon, selected in Home settings.
- **New:** one large recent release leads, followed by date-grouped song rows.
- **Library:** one grouped collection index leads to recently added records.
- **Favourites:** title, search and one segmented control; content begins
  immediately below.
- **Search:** the search field is the first content element, not a floating
  bottom panel.
- **Radio:** station and genre actions are flat surfaces with one waveform
  mark; hue never substitutes for a label.
- **Player:** cover, metadata, scrubber and transport own the screen; secondary
  actions share one ruled surface.
- **Settings:** related controls sit in inset groups on the black ground.

## Motion

Only state changes move. Press feedback is a 0.985 compression over 120 ms;
surface changes use 180 ms and route/content changes use 240 ms. Artwork flip
uses the existing 320 ms crossfade. Reduce Motion removes travel and keeps the
state change.

## Accessibility

- Every control has a 44 pt minimum target.
- Text and essential metadata meet 4.5:1 contrast.
- Active navigation is communicated by icon fill and text brightness, not hue
  alone.
- The persistent player exposes playback state and controls to semantics.
- The left-edge back gesture and native navigation transitions remain intact.

## Deliberate translation from the dealt sheet

The sheet names Inter; this iOS-first app keeps the native platform face
instead, because HIG typography and Dynamic Type take priority on the shipped
device. The sheet's type scale and weights are otherwise unchanged.
