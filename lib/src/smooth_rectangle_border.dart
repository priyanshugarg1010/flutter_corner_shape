import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import 'smooth_border_radius.dart';
import 'smooth_radius.dart';

/// Where the stroke of a [SmoothRectangleBorder] is painted relative to the
/// shape's outline.
enum BorderAlign {
  /// The stroke is painted inside the outline.
  inside,

  /// The stroke straddles the outline.
  center,

  /// The stroke is painted outside the outline.
  outside,
}

/// An [OutlinedBorder] that paints a rectangle with Figma-style smooth
/// corners.
///
/// Drop-in equivalent of `figma_squircle`'s `SmoothRectangleBorder`. Use it
/// anywhere a [ShapeBorder] is accepted (e.g. [ShapeDecoration], [Material],
/// [Card]).
///
/// ```dart
/// Container(
///   decoration: ShapeDecoration(
///     color: Colors.blue,
///     shape: SmoothRectangleBorder(
///       borderRadius: SmoothBorderRadius(cornerRadius: 20, cornerSmoothing: 0.6),
///     ),
///   ),
/// )
/// ```
class SmoothRectangleBorder extends OutlinedBorder {
  /// Creates a smooth rectangle border.
  const SmoothRectangleBorder({
    super.side = BorderSide.none,
    this.borderRadius = SmoothBorderRadius.zero,
    this.borderAlign = BorderAlign.inside,
  });

  /// The radius (and smoothing) of each corner.
  final SmoothBorderRadius borderRadius;

  /// Where the [side] stroke is painted relative to the outline.
  final BorderAlign borderAlign;

  @override
  EdgeInsetsGeometry get dimensions {
    switch (borderAlign) {
      case BorderAlign.inside:
        return EdgeInsets.all(side.width);
      case BorderAlign.center:
        return EdgeInsets.all(side.width / 2);
      case BorderAlign.outside:
        return EdgeInsets.zero;
    }
  }

  @override
  ShapeBorder scale(double t) => SmoothRectangleBorder(
        side: side.scale(t),
        borderRadius: borderRadius * t,
        borderAlign: borderAlign,
      );

  @override
  ShapeBorder? lerpFrom(ShapeBorder? a, double t) {
    if (a is SmoothRectangleBorder) {
      return SmoothRectangleBorder(
        side: BorderSide.lerp(a.side, side, t),
        borderRadius: SmoothBorderRadius.lerp(a.borderRadius, borderRadius, t)!,
        borderAlign: t < 0.5 ? a.borderAlign : borderAlign,
      );
    }
    return super.lerpFrom(a, t);
  }

  @override
  ShapeBorder? lerpTo(ShapeBorder? b, double t) {
    if (b is SmoothRectangleBorder) {
      return SmoothRectangleBorder(
        side: BorderSide.lerp(side, b.side, t),
        borderRadius: SmoothBorderRadius.lerp(borderRadius, b.borderRadius, t)!,
        borderAlign: t < 0.5 ? borderAlign : b.borderAlign,
      );
    }
    return super.lerpTo(b, t);
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    final innerRect = switch (borderAlign) {
      BorderAlign.inside => rect.deflate(side.width),
      BorderAlign.center => rect.deflate(side.width / 2),
      BorderAlign.outside => rect,
    };
    final radius = switch (borderAlign) {
      BorderAlign.inside => borderRadius -
          SmoothBorderRadius.all(
            SmoothRadius(cornerRadius: side.width, cornerSmoothing: 1.0),
          ),
      BorderAlign.center => borderRadius -
          SmoothBorderRadius.all(
            SmoothRadius(cornerRadius: side.width / 2, cornerSmoothing: 1.0),
          ),
      BorderAlign.outside => borderRadius,
    };
    return _pathFor(innerRect, radius, textDirection);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) =>
      _pathFor(rect, borderRadius, textDirection);

  Path _pathFor(
    Rect rect,
    SmoothBorderRadius radius,
    TextDirection? textDirection,
  ) {
    final allCircular = [
      radius.topLeft,
      radius.topRight,
      radius.bottomLeft,
      radius.bottomRight,
    ].every((r) => r.cornerSmoothing == 0.0);
    if (allCircular) {
      return Path()..addRRect(radius.resolve(textDirection).toRRect(rect));
    }
    return radius.toPath(rect);
  }

  @override
  SmoothRectangleBorder copyWith({
    BorderSide? side,
    SmoothBorderRadius? borderRadius,
    BorderAlign? borderAlign,
  }) {
    return SmoothRectangleBorder(
      side: side ?? this.side,
      borderRadius: borderRadius ?? this.borderRadius,
      borderAlign: borderAlign ?? this.borderAlign,
    );
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (rect.isEmpty) return;
    switch (side.style) {
      case BorderStyle.none:
        break;
      case BorderStyle.solid:
        final adjustedRect = switch (borderAlign) {
          BorderAlign.inside => rect.deflate(side.width / 2),
          BorderAlign.center => rect,
          BorderAlign.outside => rect.inflate(side.width / 2),
        };
        final adjustedRadius = switch (borderAlign) {
          BorderAlign.inside => borderRadius -
              SmoothBorderRadius.all(
                SmoothRadius(cornerRadius: side.width / 2, cornerSmoothing: 1.0),
              ),
          BorderAlign.center => borderRadius,
          BorderAlign.outside => borderRadius +
              SmoothBorderRadius.all(
                SmoothRadius(cornerRadius: side.width / 2, cornerSmoothing: 1.0),
              ),
        };
        final paint = side.toPaint()..style = PaintingStyle.stroke;
        canvas.drawPath(
          _pathFor(adjustedRect, adjustedRadius, textDirection),
          paint,
        );
        break;
    }
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is SmoothRectangleBorder &&
        other.side == side &&
        other.borderRadius == borderRadius &&
        other.borderAlign == borderAlign;
  }

  @override
  int get hashCode => Object.hash(side, borderRadius, borderAlign);

  @override
  String toString() =>
      '${objectRuntimeType(this, 'SmoothRectangleBorder')}($side, '
      '$borderRadius, $borderAlign)';
}
