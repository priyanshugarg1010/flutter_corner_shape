/// CSS `corner-shape` for Flutter.
///
/// Provides `round`, `scoop`, `bevel`, `notch`, `squircle`, and `superellipse`
/// corner shapes — with per-corner control, smooth animations, and drop-in
/// [ShapeBorder] + [Clipper] widgets.
///
/// Convex corners also support Figma-style corner smoothing via
/// `CornerShapeValue.smooth(cornerSmoothing:)`, and the package ships drop-in
/// replacements for the `figma_squircle` API ([SmoothRectangleBorder],
/// [SmoothBorderRadius], [SmoothRadius], [ClipSmoothRect]).
///
/// ## Quick Start
///
/// ```dart
/// import 'package:flutter_corner_shape/flutter_corner_shape.dart';
///
/// // Scoop all corners (ticket/coupon shape)
/// Container(
///   decoration: ShapeDecoration(
///     color: Colors.orange,
///     shape: CornerShapeBorder(
///       borderRadius: BorderRadius.circular(30),
///       cornerShape: CornerShapeSpec.scoop,
///     ),
///   ),
/// )
/// ```
///
/// ## CSS ↔ Dart Mapping
///
/// | CSS                                       | Dart                                               |
/// |-------------------------------------------|-----------------------------------------------------|
/// | `corner-shape: round`                     | `CornerShapeSpec.round`                             |
/// | `corner-shape: scoop`                     | `CornerShapeSpec.scoop`                             |
/// | `corner-shape: bevel`                     | `CornerShapeSpec.bevel`                             |
/// | `corner-shape: notch`                     | `CornerShapeSpec.notch`                             |
/// | `corner-shape: squircle`                  | `CornerShapeSpec.squircle`                          |
/// | `corner-shape: square`                    | `CornerShapeSpec.square`                            |
/// | `corner-shape: superellipse(-1.5)`        | `CornerShapeSpec.all(CornerShapeValue.superellipse(-1.5))` |
/// | `corner-shape: round scoop bevel notch`   | `CornerShapeSpec.only(topLeft: ..., ...)`           |
library;

export 'src/clip_corner_shape.dart';
export 'src/clip_smooth_rect.dart';
export 'src/corner_shape_border.dart';
export 'src/corner_shape_decoration.dart';
export 'src/corner_shape_spec.dart';
export 'src/corner_shape_tween.dart';
export 'src/corner_shape_value.dart';
export 'src/smooth_border_radius.dart';
export 'src/smooth_corner_geometry.dart';
export 'src/smooth_radius.dart';
export 'src/smooth_rectangle_border.dart';
