# Changelog

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
