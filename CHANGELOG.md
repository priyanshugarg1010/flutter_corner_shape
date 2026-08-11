# Changelog

## 0.2.0

### Added

- **Figma corner smoothing**: convex corners now support a `cornerSmoothing`
  factor (0–1) using a faithful port of Figma's corner-smoothing ("squircle")
  algorithm.
  - `CornerShapeValue.smooth(cornerSmoothing:)` and `CornerShapeValue.superellipse(k, cornerSmoothing:)`
  - `CornerShapeSpec.smooth(cornerSmoothing:)` and `CornerShapeSpec.smoothSquircle`
  - `cornerSmoothing` animates via `CornerShapeSpec.lerp` / `CornerShapeSpecTween`
  - Smoothing can be mixed per-corner with scoop / bevel / notch corners
- **Drop-in `figma_squircle` replacement**: change only the import to migrate.
  - `SmoothRectangleBorder` (with `BorderAlign`)
  - `SmoothBorderRadius` (`.only`, `.all`, `.vertical`, `.horizontal`, operators, `lerp`, `copyWith`)
  - `SmoothRadius`
  - `ClipSmoothRect`
- `SmoothCornerGeometry`: low-level, cached Figma-smoothing math.

## 0.1.6

### Updated

- Added the raw=true query parameter to render the images in the readme file

## 0.1.5

### Updated

- Updated the images to use the div tag in the read me file to show the images properly on pub dev

## 0.1.4

### Updated

- Updated the images to use the p tag in the read me file to show the images properly on pub dev

## 0.1.3

### Added

- Added the examples images in the readme file for better understanding the package really do

## 0.1.2

### Updated

- Updated the correct url for the home page and repository

## 0.1.1

### Changed

- Added `.pubignore` to exclude example platform folders, IDE configs, build artifacts, and documentation scripts from the published package, reducing the published package size.

## 0.1.0

Initial release of `flutter_corner_shape` — CSS `corner-shape` for Flutter.

### Added

- **CornerShapeValue** — Single corner shape model with 6 keyword presets (`round`, `squircle`, `bevel`, `scoop`, `notch`, `square`) and continuous `superellipse(K)` control from K = −∞ to +∞.
- **CornerShapeType** — Enum of CSS corner-shape keyword values.
- **CornerShapeSpec** — Per-corner shape specification mirroring CSS shorthand with constructors: `.all()`, `.only()`, `.symmetric()`, `.vertical()`, `.horizontal()`.
- **CornerShapeBorder** — Drop-in `OutlinedBorder` that works with `ShapeDecoration`, `Material`, `Card`, `Chip`, `Dialog`, and any widget accepting `ShapeBorder`.
  - CSS-style radius collision clamping when adjacent radii exceed available edge length.
  - `lerpFrom` / `lerpTo` support for smooth transitions, including interop with `RoundedRectangleBorder`.
  - Performance fast-path: delegates to native `Canvas.drawRRect()` when all corners are `round`.
- **CornerPathBuilder** — Bézier math engine that generates `Path` segments for each K value using cubic `cubicTo()` approximation with control point factors derived from the superellipse exponent.
- **ClipCornerShape** — Clip widget (equivalent to `ClipRRect` for corner shapes) with `.all()` convenience constructor.
- **CornerShapeDecoration** — Convenience `ShapeDecoration` wrapper combining color, gradient, image, shadows, border side, border radius, and corner shape in one declaration.
- **CornerShapeSpecTween** — `Tween<CornerShapeSpec>` for animating between any two corner shape configurations.
