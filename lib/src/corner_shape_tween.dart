import 'package:flutter/animation.dart';

import 'corner_shape_spec.dart';

/// A [Tween] that interpolates between two [CornerShapeSpec]s.
///
/// Used with [AnimatedContainer], [TweenAnimationBuilder], or any
/// animation controller to smoothly morph between corner shapes.
///
/// ```dart
/// TweenAnimationBuilder<CornerShapeSpec>(
///   tween: CornerShapeSpecTween(
///     begin: CornerShapeSpec.round,
///     end: CornerShapeSpec.scoop,
///   ),
///   duration: Duration(milliseconds: 500),
///   builder: (context, spec, child) {
///     return Container(
///       decoration: ShapeDecoration(
///         color: Colors.orange,
///         shape: CornerShapeBorder(
///           borderRadius: BorderRadius.circular(30),
///           cornerShape: spec,
///         ),
///       ),
///     );
///   },
/// )
/// ```
class CornerShapeSpecTween extends Tween<CornerShapeSpec> {
  CornerShapeSpecTween({
    super.begin,
    super.end,
  });

  @override
  CornerShapeSpec lerp(double t) {
    return CornerShapeSpec.lerp(begin!, end!, t);
  }
}
