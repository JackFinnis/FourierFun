# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Fourier is an iOS app (SwiftUI) that transforms SVG files or freehand drawings into epicycle animations using the complex Fourier series. Users draw or import an SVG, the app computes DFT coefficients, and animates rotating epicycles that reconstruct the original path.

## Build & Run

Open `Fourier.xcodeproj` in Xcode. Single target "Fourier" — build and run on iOS simulator or device.

- **Swift 6.0**, deployment target **iOS 26.0**
- No tests configured
- No CI/CD, Fastlane, or Makefile

## Dependencies (Swift Package Manager)

- **swift-numerics** (`ComplexModule`) — complex number math for Fourier transform
- **VectorPlus** / **SwiftSVG** — SVG parsing and path extraction

## Architecture

MVVM with a single-screen app. All UI lives in `ContentView` (inside [App.swift](Fourier/App.swift)).

### Key files

| File | Role |
|------|------|
| [App.swift](Fourier/App.swift) | App entry point + `ContentView` (full UI, gestures, toolbar, navigation) |
| [Model.swift](Fourier/Models/Model.swift) | `@Observable` view model — drawing state, SVG import, path scaling, triggers Fourier transform |
| [Fourier.swift](Fourier/Models/Fourier.swift) | Pure math — DFT computation (`getCs`), path reconstruction (`getApprox`), epicycle arrow positions (`arrowPositions`) |
| [EpicycleView.swift](Fourier/EpicycleView.swift) | `TimelineView` + `Canvas` animation rendering epicycles, arrows, and traced path |
| [PathRenderer.swift](Fourier/PathRenderer.swift) | Static path rendering for non-animated display and PNG export |
| [Speed.swift](Fourier/Models/Speed.swift) | Animation speed enum (0.5x, 1x, 2x) |
| [ExampleFile.swift](Fourier/Models/ExampleFile.swift) | Bundled example SVGs (Joseph Fourier portrait, Pi symbol) |

### Data flow

1. User draws (DragGesture) or imports SVG → raw `CGPath` points extracted
2. `Model.transform()` scales points to fit screen, calls `Model.update()`
3. `Fourier.getCs()` computes complex coefficients c_n via DFT
4. `Fourier.getApprox()` reconstructs the approximated path
5. `Fourier.sortedTerms()` orders coefficients by magnitude for epicycle rendering
6. `EpicycleView` animates using `TimelineView(.animation)` + `Canvas`, calling `Fourier.arrowPositions()` each frame
7. Epicycle count adjustable via Slider/Stepper in bottom toolbar → re-triggers `update()`
