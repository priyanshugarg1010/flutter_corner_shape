import 'package:flutter/painting.dart';

import 'corner_shape_border.dart';
import 'corner_shape_spec.dart';
import 'corner_shape_value.dart';

/// A convenience [Decoration] that combines color, gradient, image,
/// shadows, and corner shapes into one declaration.
///
/// This is a thin wrapper around [ShapeDecoration] with [CornerShapeBorder].
///
/// ```dart
/// Container(
///   decoration: CornerShapeDecoration(
///     color: Colors.orange,
///     borderRadius: BorderRadius.circular(30),
///     cornerShape: CornerShapeSpec.scoop,
///     shadows: [
///       BoxShadow(color: Colors.black26, blurRadius: 12, offset: Offset(0, 4)),
///     ],
///   ),
/// )
/// ```
class CornerShapeDecoration extends ShapeDecoration {
  /// Creates a decoration with corner-shaped borders.
  CornerShapeDecoration({
    super.color,
    super.gradient,
    super.image,
    super.shadows,
    BorderSide side = BorderSide.none,
    BorderRadiusGeometry borderRadius = BorderRadius.zero,
    CornerShapeSpec cornerShape = CornerShapeSpec.round,
  }) : super(
          shape: CornerShapeBorder(
            side: side,
            borderRadius: borderRadius,
            cornerShape: cornerShape,
          ),
        );

  /// Convenience constructor for when all corners share the same shape.
  CornerShapeDecoration.all({
    super.color,
    super.gradient,
    super.image,
    super.shadows,
    BorderSide side = BorderSide.none,
    BorderRadiusGeometry borderRadius = BorderRadius.zero,
    CornerShapeValue cornerShapeValue = CornerShapeValue.round,
  }) : super(
          shape: CornerShapeBorder(
            side: side,
            borderRadius: borderRadius,
            cornerShape: CornerShapeSpec.all(cornerShapeValue),
          ),
        );
}
