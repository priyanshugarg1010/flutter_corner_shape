import 'package:flutter/widgets.dart';

import 'smooth_border_radius.dart';
import 'smooth_rectangle_border.dart';

/// Clips its [child] to a rectangle with Figma-style smooth corners.
///
/// Drop-in equivalent of `figma_squircle`'s `ClipSmoothRect`.
///
/// ```dart
/// ClipSmoothRect(
///   radius: SmoothBorderRadius(cornerRadius: 24, cornerSmoothing: 0.6),
///   child: Image.network('https://example.com/photo.jpg'),
/// )
/// ```
class ClipSmoothRect extends StatelessWidget {
  /// Creates a smooth-corner clip.
  const ClipSmoothRect({
    super.key,
    required this.child,
    this.radius = SmoothBorderRadius.zero,
    this.clipBehavior = Clip.antiAlias,
  });

  /// The corner radii (and smoothing) to clip to.
  final SmoothBorderRadius radius;

  /// How to clip.
  final Clip clipBehavior;

  /// The widget below this widget in the tree.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipPath.shape(
      clipBehavior: clipBehavior,
      shape: SmoothRectangleBorder(borderRadius: radius),
      child: child,
    );
  }
}
