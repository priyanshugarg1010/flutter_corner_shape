import 'package:flutter/widgets.dart';

import 'corner_shape_border.dart';
import 'corner_shape_spec.dart';
import 'corner_shape_value.dart';

/// A widget that clips its child using a corner-shaped rectangle.
///
/// This is the `ClipRRect` equivalent for corner shapes. Wrapping a child
/// in [ClipCornerShape] will clip it to the specified corner geometry.
///
/// ```dart
/// ClipCornerShape(
///   borderRadius: BorderRadius.circular(30),
///   cornerShape: CornerShapeSpec.scoop,
///   child: Image.network('https://example.com/photo.jpg'),
/// )
/// ```
///
/// For a simpler API when all corners share the same shape:
///
/// ```dart
/// ClipCornerShape.all(
///   borderRadius: BorderRadius.circular(24),
///   cornerShapeValue: CornerShapeValue.bevel,
///   child: myWidget,
/// )
/// ```
class ClipCornerShape extends StatelessWidget {
  /// The border radius controlling the size of each corner effect.
  final BorderRadius borderRadius;

  /// The corner shape specification for each corner.
  final CornerShapeSpec cornerShape;

  /// The clip behavior.
  final Clip clipBehavior;

  /// The widget below this widget in the tree.
  final Widget child;

  /// Creates a clip widget with CSS-style corner shapes.
  const ClipCornerShape({
    super.key,
    required this.borderRadius,
    required this.cornerShape,
    this.clipBehavior = Clip.antiAlias,
    required this.child,
  });

  /// Convenience constructor for uniform corner shape on all corners.
  ClipCornerShape.all({
    super.key,
    required this.borderRadius,
    required CornerShapeValue cornerShapeValue,
    this.clipBehavior = Clip.antiAlias,
    required this.child,
  }) : cornerShape = CornerShapeSpec.all(cornerShapeValue);

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipBehavior: clipBehavior,
      clipper: _CornerShapeClipper(
        borderRadius: borderRadius,
        cornerShape: cornerShape,
      ),
      child: child,
    );
  }
}

class _CornerShapeClipper extends CustomClipper<Path> {
  final BorderRadius borderRadius;
  final CornerShapeSpec cornerShape;

  _CornerShapeClipper({
    required this.borderRadius,
    required this.cornerShape,
  });

  @override
  Path getClip(Size size) {
    final rect = Offset.zero & size;
    final border = CornerShapeBorder(
      borderRadius: borderRadius,
      cornerShape: cornerShape,
    );
    return border.getOuterPath(rect);
  }

  @override
  bool shouldReclip(_CornerShapeClipper oldClipper) {
    return oldClipper.borderRadius != borderRadius ||
        oldClipper.cornerShape != cornerShape;
  }
}
