# flutter_corner_shape

CSS `corner-shape` for Flutter. Round, scoop, bevel, notch, squircle, and superellipse corners — with per-corner control, smooth animations, and drop-in `ShapeBorder` + `Clipper` widgets.

## Examples

<div> 
    <img src="https://github.com/priyanshugarg1010/flutter_corner_shape/blob/main/assets/keyword_values.png?raw=true" width="450">
</div>

<div> 
    <img src="https://github.com/priyanshugarg1010/flutter_corner_shape/blob/main/assets/morph.gif?raw=true" width="450">
</div>

<div> 
    <img src="https://github.com/priyanshugarg1010/flutter_corner_shape/blob/main/assets/corner_clip.png?raw=true" width="450">
</div>

<div> 
    <img src="https://github.com/priyanshugarg1010/flutter_corner_shape/blob/main/assets/per_corner.png?raw=true" width="450">
</div>

## Why?

Flutter gives you `RoundedRectangleBorder` (round), `BeveledRectangleBorder` (bevel), and the new `RoundedSuperellipseBorder` (squircle). But there's no **scoop** (concave), no **notch** (inward square cut), no `superellipse(K)` fine-tuning, and no way to mix different shapes per corner.

CSS solved this with the `corner-shape` property. This package brings that full API to Flutter.

## Features

- **6 keyword shapes**: `round`, `squircle`, `bevel`, `scoop`, `notch`, `square`
- **`superellipse(K)`** for continuous fine-tuning from K = -∞ to +∞
- **Per-corner control**: different shape on each corner
- **Smooth animation** between any two shapes via `CornerShapeSpecTween`
- **`CornerShapeBorder`**: drop-in `ShapeBorder` for `ShapeDecoration`, `Material`, `Card`, etc.
- **`ClipCornerShape`**: clip widget, like `ClipRRect` but with corner shapes
- **`CornerShapeDecoration`**: convenience `Decoration` with color, gradient, shadows
- **Lerp to/from `RoundedRectangleBorder`** for seamless transition with existing Flutter code

## Quick Start

```dart
import 'package:flutter_corner_shape/flutter_corner_shape.dart';
```

### Scoop (ticket/coupon shape)

```dart
Container(
  width: 300,
  height: 100,
  decoration: ShapeDecoration(
    color: Colors.orange,
    shape: CornerShapeBorder(
      borderRadius: BorderRadius.circular(50),
      cornerShape: CornerShapeSpec.scoop,
    ),
  ),
)
```

### Bevel (diagonal cut)

```dart
Container(
  decoration: ShapeDecoration(
    color: Colors.blue,
    shape: CornerShapeBorder(
      borderRadius: BorderRadius.circular(20),
      cornerShape: CornerShapeSpec.bevel,
    ),
  ),
)
```

### Notch (inward square cut)

```dart
CornerShapeBorder(
  borderRadius: BorderRadius.circular(20),
  cornerShape: CornerShapeSpec.notch,
)
```

### Fine-tuned superellipse

```dart
CornerShapeBorder(
  borderRadius: BorderRadius.circular(24),
  cornerShape: CornerShapeSpec.all(
    CornerShapeValue.superellipse(-1.5), // between scoop and notch
  ),
)
```

### Per-corner shapes

```dart
CornerShapeBorder(
  borderRadius: BorderRadius.circular(24),
  cornerShape: CornerShapeSpec.only(
    topLeft: CornerShapeValue.round,
    topRight: CornerShapeValue.scoop,
    bottomRight: CornerShapeValue.bevel,
    bottomLeft: CornerShapeValue.notch,
  ),
)
```

### Clip an image

```dart
ClipCornerShape(
  borderRadius: BorderRadius.circular(30),
  cornerShape: CornerShapeSpec.scoop,
  child: Image.network('https://example.com/photo.jpg'),
)
```

### Animated morph

```dart
TweenAnimationBuilder<CornerShapeSpec>(
  tween: CornerShapeSpecTween(
    begin: CornerShapeSpec.all(CornerShapeValue.superellipse(3)),
    end: CornerShapeSpec.all(CornerShapeValue.superellipse(-3)),
  ),
  duration: const Duration(seconds: 2),
  builder: (context, spec, child) {
    return Container(
      width: 120,
      height: 120,
      decoration: ShapeDecoration(
        color: Colors.orange,
        shape: CornerShapeBorder(
          borderRadius: BorderRadius.circular(60),
          cornerShape: spec,
        ),
      ),
    );
  },
)
```

### Decoration with shadows

```dart
Container(
  decoration: CornerShapeDecoration(
    color: Colors.deepPurple,
    borderRadius: BorderRadius.circular(24),
    cornerShape: CornerShapeSpec.scoop,
    side: BorderSide(color: Colors.white, width: 2),
    shadows: [
      BoxShadow(
        color: Colors.black26,
        blurRadius: 16,
        offset: Offset(0, 6),
      ),
    ],
  ),
)
```

## CSS ↔ Dart Mapping

| CSS                                     | Dart                                                           |
| --------------------------------------- | -------------------------------------------------------------- |
| `corner-shape: round`                   | `CornerShapeSpec.round`                                        |
| `corner-shape: squircle`                | `CornerShapeSpec.squircle`                                     |
| `corner-shape: bevel`                   | `CornerShapeSpec.bevel`                                        |
| `corner-shape: scoop`                   | `CornerShapeSpec.scoop`                                        |
| `corner-shape: notch`                   | `CornerShapeSpec.notch`                                        |
| `corner-shape: square`                  | `CornerShapeSpec.square`                                       |
| `corner-shape: superellipse(-1.5)`      | `CornerShapeSpec.all(CornerShapeValue.superellipse(-1.5))`     |
| `corner-shape: round scoop bevel notch` | `CornerShapeSpec.only(topLeft: .round, topRight: .scoop, ...)` |
| `border-radius: 30px`                   | `BorderRadius.circular(30)`                                    |

## Superellipse Value Spectrum

| K Value | Keyword    | Visual Effect          |
| ------- | ---------- | ---------------------- |
| +∞      | `square`   | Sharp 90° corner       |
| 3       | —          | Very subtle rounding   |
| 2       | `squircle` | iOS-style smooth curve |
| 1       | `round`    | Standard circular arc  |
| 0.5     | —          | Extra-rounded outward  |
| 0       | `bevel`    | Straight diagonal line |
| -0.5    | —          | Slight inward curve    |
| -1      | `scoop`    | Concave circular arc   |
| -∞      | `notch`    | 90° inward square cut  |

## API Overview

| Class                   | Purpose                                                |
| ----------------------- | ------------------------------------------------------ |
| `CornerShapeValue`      | Single corner's shape (keyword or `superellipse(K)`)   |
| `CornerShapeSpec`       | All 4 corners' shapes (like CSS shorthand)             |
| `CornerShapeBorder`     | `ShapeBorder` — use with `ShapeDecoration`, `Material` |
| `ClipCornerShape`       | Clip widget — like `ClipRRect` with corner shapes      |
| `CornerShapeDecoration` | Convenience `Decoration` (color + shape + shadows)     |
| `CornerShapeSpecTween`  | `Tween` for animating between shapes                   |
| `CornerShapeType`       | Enum of keyword values                                 |

## How It Works

The package uses cubic Bézier curves to approximate superellipse corners:

- **Convex (K > 0)**: Control points placed between edge start/end and corner, with handle length derived from K
- **Bevel (K = 0)**: Straight line between edges
- **Concave (K < 0)**: Control points pulled inward past the diagonal, creating the scoop effect
- **Square (K = +∞)**: Two straight lines through the corner point
- **Notch (K = -∞)**: Two straight lines to an inward-reflected point

For K = 1 (standard round), the Bézier handle factor is the classic `(4/3)(√2 - 1) ≈ 0.5523`, matching a perfect circular arc.

## License

MIT
