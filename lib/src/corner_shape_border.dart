import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import 'dart:math' as math;

import 'corner_path_builder.dart';
import 'corner_shape_spec.dart';
import 'corner_shape_value.dart';
import 'smooth_corner_geometry.dart';

/// A [ShapeBorder] that applies CSS-style corner shapes to a rectangle.
///
/// This is the primary widget-facing API of the `corner_shape` package.
/// It works as a drop-in replacement for [RoundedRectangleBorder] with
/// additional control over corner geometry.
///
/// ```dart
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
///
/// // Mix corner types per-corner
/// CornerShapeBorder(
///   borderRadius: BorderRadius.circular(24),
///   cornerShape: CornerShapeSpec.only(
///     topLeft: CornerShapeValue.round,
///     topRight: CornerShapeValue.scoop,
///     bottomRight: CornerShapeValue.bevel,
///     bottomLeft: CornerShapeValue.notch,
///   ),
/// )
///
/// // Fine-tune with superellipse values
/// CornerShapeBorder(
///   borderRadius: BorderRadius.circular(24),
///   cornerShape: CornerShapeSpec.all(
///     CornerShapeValue.superellipse(-1.5),
///   ),
/// )
/// ```
class CornerShapeBorder extends OutlinedBorder {
  /// The radii of each corner, controlling the *size* of the corner effect.
  final BorderRadiusGeometry borderRadius;

  /// The shape of each corner, controlling the *geometry* of the corner curve.
  ///
  /// Defaults to [CornerShapeSpec.round], matching standard [RoundedRectangleBorder].
  final CornerShapeSpec cornerShape;

  /// Creates a border with CSS-style corner shapes.
  const CornerShapeBorder({
    super.side = BorderSide.none,
    this.borderRadius = BorderRadius.zero,
    this.cornerShape = CornerShapeSpec.round,
  });

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(side.width);

  @override
  ShapeBorder? lerpFrom(ShapeBorder? a, double t) {
    if (a is CornerShapeBorder) {
      return CornerShapeBorder(
        side: BorderSide.lerp(a.side, side, t),
        borderRadius:
            BorderRadiusGeometry.lerp(a.borderRadius, borderRadius, t)!,
        cornerShape: CornerShapeSpec.lerp(a.cornerShape, cornerShape, t),
      );
    }
    if (a is RoundedRectangleBorder) {
      return CornerShapeBorder(
        side: BorderSide.lerp(a.side, side, t),
        borderRadius:
            BorderRadiusGeometry.lerp(a.borderRadius, borderRadius, t)!,
        cornerShape:
            CornerShapeSpec.lerp(CornerShapeSpec.round, cornerShape, t),
      );
    }
    return super.lerpFrom(a, t);
  }

  @override
  ShapeBorder? lerpTo(ShapeBorder? b, double t) {
    if (b is CornerShapeBorder) {
      return CornerShapeBorder(
        side: BorderSide.lerp(side, b.side, t),
        borderRadius:
            BorderRadiusGeometry.lerp(borderRadius, b.borderRadius, t)!,
        cornerShape: CornerShapeSpec.lerp(cornerShape, b.cornerShape, t),
      );
    }
    if (b is RoundedRectangleBorder) {
      return CornerShapeBorder(
        side: BorderSide.lerp(side, b.side, t),
        borderRadius:
            BorderRadiusGeometry.lerp(borderRadius, b.borderRadius, t)!,
        cornerShape:
            CornerShapeSpec.lerp(cornerShape, CornerShapeSpec.round, t),
      );
    }
    return super.lerpTo(b, t);
  }

  @override
  CornerShapeBorder copyWith({
    BorderSide? side,
    BorderRadiusGeometry? borderRadius,
    CornerShapeSpec? cornerShape,
  }) {
    return CornerShapeBorder(
      side: side ?? this.side,
      borderRadius: borderRadius ?? this.borderRadius,
      cornerShape: cornerShape ?? this.cornerShape,
    );
  }

  @override
  ShapeBorder scale(double t) {
    return CornerShapeBorder(
      side: side.scale(t),
      borderRadius: borderRadius * t,
      cornerShape: cornerShape,
    );
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    final adjustedRect = rect.deflate(side.strokeInset);
    final br = borderRadius.resolve(textDirection);
    // Scale inner radii to account for border width, clamping to zero minimum
    final w = side.width;
    final inner = BorderRadius.only(
      topLeft: Radius.elliptical(
        (br.topLeft.x - w).clamp(0, double.infinity),
        (br.topLeft.y - w).clamp(0, double.infinity),
      ),
      topRight: Radius.elliptical(
        (br.topRight.x - w).clamp(0, double.infinity),
        (br.topRight.y - w).clamp(0, double.infinity),
      ),
      bottomRight: Radius.elliptical(
        (br.bottomRight.x - w).clamp(0, double.infinity),
        (br.bottomRight.y - w).clamp(0, double.infinity),
      ),
      bottomLeft: Radius.elliptical(
        (br.bottomLeft.x - w).clamp(0, double.infinity),
        (br.bottomLeft.y - w).clamp(0, double.infinity),
      ),
    );
    return _buildPath(adjustedRect, inner);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final br = borderRadius.resolve(textDirection);
    return _buildPath(rect, br);
  }

  @override
  bool get preferPaintInterior => true;

  @override
  void paintInterior(Canvas canvas, Rect rect, Paint paint,
      {TextDirection? textDirection}) {
    final br = borderRadius.resolve(textDirection);
    // For simple round corners, use the optimized RRect path
    if (_isAllRound) {
      canvas.drawRRect(br.toRRect(rect), paint);
      return;
    }
    canvas.drawPath(getOuterPath(rect, textDirection: textDirection), paint);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (side.style == BorderStyle.none || side.width == 0) return;

    final paint = side.toPaint();
    final br = borderRadius.resolve(textDirection);

    // For simple round corners, use the optimized drawRRect
    if (_isAllRound) {
      final outer = br.toRRect(rect);
      final inner = outer.deflate(side.width);
      canvas.drawDRRect(outer, inner, paint);
      return;
    }

    // For shaped corners, stroke the outer path
    final path = getOuterPath(rect, textDirection: textDirection);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = side.width;
    canvas.drawPath(path, paint);
  }

  /// Whether all corners use the standard round shape.
  bool get _isAllRound =>
      cornerShape.topLeft == CornerShapeValue.round &&
      cornerShape.topRight == CornerShapeValue.round &&
      cornerShape.bottomRight == CornerShapeValue.round &&
      cornerShape.bottomLeft == CornerShapeValue.round;

  /// Builds the actual corner-shaped path for the given [rect] and [br].
  Path _buildPath(Rect rect, BorderRadius br) {
    final path = Path();

    // Clamp radii to avoid overlap (CSS collision rules)
    final clampedBR = _clampRadii(rect, br);

    // Resolve each corner into a local frame with its two along-edge insets.
    // `e1` points from the corner toward the incoming edge, `e2` toward the
    // outgoing edge (following the path's clockwise winding).
    final tl = _Corner(
      corner: Offset(rect.left, rect.top),
      e1: const Offset(0, 1),
      e2: const Offset(1, 0),
      radius: clampedBR.topLeft,
      inset1: clampedBR.topLeft.y,
      inset2: clampedBR.topLeft.x,
      value: cornerShape.topLeft,
      rect: rect,
    );
    final tr = _Corner(
      corner: Offset(rect.right, rect.top),
      e1: const Offset(-1, 0),
      e2: const Offset(0, 1),
      radius: clampedBR.topRight,
      inset1: clampedBR.topRight.x,
      inset2: clampedBR.topRight.y,
      value: cornerShape.topRight,
      rect: rect,
    );
    final brc = _Corner(
      corner: Offset(rect.right, rect.bottom),
      e1: const Offset(0, -1),
      e2: const Offset(-1, 0),
      radius: clampedBR.bottomRight,
      inset1: clampedBR.bottomRight.y,
      inset2: clampedBR.bottomRight.x,
      value: cornerShape.bottomRight,
      rect: rect,
    );
    final bl = _Corner(
      corner: Offset(rect.left, rect.bottom),
      e1: const Offset(1, 0),
      e2: const Offset(0, -1),
      radius: clampedBR.bottomLeft,
      inset1: clampedBR.bottomLeft.x,
      inset2: clampedBR.bottomLeft.y,
      value: cornerShape.bottomLeft,
      rect: rect,
    );

    path.moveTo(tl.start.dx, tl.start.dy);
    tl.draw(path);
    path.lineTo(tr.start.dx, tr.start.dy);
    tr.draw(path);
    path.lineTo(brc.start.dx, brc.start.dy);
    brc.draw(path);
    path.lineTo(bl.start.dx, bl.start.dy);
    bl.draw(path);

    path.close();
    return path;
  }

  /// Clamps border radii to prevent overlap, matching CSS collision rules.
  ///
  /// If adjacent radii exceed the available space on an edge, they're scaled
  /// down proportionally.
  static BorderRadius _clampRadii(Rect rect, BorderRadius br) {
    final width = rect.width;
    final height = rect.height;

    if (width <= 0 || height <= 0) return BorderRadius.zero;

    // Compute the scaling factor for each edge
    double factor = 1.0;

    // Top edge
    final topSum = br.topLeft.x + br.topRight.x;
    if (topSum > width) factor = factor.clamp(0, width / topSum);

    // Bottom edge
    final bottomSum = br.bottomLeft.x + br.bottomRight.x;
    if (bottomSum > width) factor = factor.clamp(0, width / bottomSum);

    // Left edge
    final leftSum = br.topLeft.y + br.bottomLeft.y;
    if (leftSum > height) factor = factor.clamp(0, height / leftSum);

    // Right edge
    final rightSum = br.topRight.y + br.bottomRight.y;
    if (rightSum > height) factor = factor.clamp(0, height / rightSum);

    if (factor == 1.0) return br;

    return BorderRadius.only(
      topLeft: Radius.elliptical(
          br.topLeft.x * factor, br.topLeft.y * factor),
      topRight: Radius.elliptical(
          br.topRight.x * factor, br.topRight.y * factor),
      bottomRight: Radius.elliptical(
          br.bottomRight.x * factor, br.bottomRight.y * factor),
      bottomLeft: Radius.elliptical(
          br.bottomLeft.x * factor, br.bottomLeft.y * factor),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is CornerShapeBorder &&
        other.side == side &&
        other.borderRadius == borderRadius &&
        other.cornerShape == cornerShape;
  }

  @override
  int get hashCode => Object.hash(side, borderRadius, cornerShape);

  @override
  String toString() {
    return '${objectRuntimeType(this, 'CornerShapeBorder')}('
        'side: $side, '
        'borderRadius: $borderRadius, '
        'cornerShape: $cornerShape)';
  }
}

/// Internal helper describing one corner in a local frame, resolving its
/// start/end points and dispatching to the right [CornerPathBuilder] routine.
class _Corner {
  _Corner({
    required this.corner,
    required this.e1,
    required this.e2,
    required this.radius,
    required this.inset1,
    required this.inset2,
    required this.value,
    required this.rect,
  }) {
    if (value.isSmooth && radius.x > 0 && radius.y > 0) {
      // Figma smoothing operates on circular radii; use the smaller axis.
      final r = math.min(radius.x, radius.y);
      _geometry = SmoothCornerGeometry(
        cornerRadius: r,
        cornerSmoothing: value.cornerSmoothing,
        width: rect.width,
        height: rect.height,
      );
      // Straight edges end at distance `p` from the corner for smooth corners.
      start = corner + e1 * _geometry!.p;
      end = corner + e2 * _geometry!.p;
    } else {
      start = corner + e1 * inset1;
      end = corner + e2 * inset2;
    }
  }

  final Offset corner;
  final Offset e1;
  final Offset e2;
  final Radius radius;
  final double inset1;
  final double inset2;
  final CornerShapeValue value;
  final Rect rect;

  SmoothCornerGeometry? _geometry;
  late final Offset start;
  late final Offset end;

  void draw(Path path) {
    final geometry = _geometry;
    if (geometry != null) {
      CornerPathBuilder.addSmoothCorner(
        path,
        cornerPoint: corner,
        startPoint: start,
        endPoint: end,
        geometry: geometry,
      );
    } else {
      CornerPathBuilder.addCorner(
        path,
        cornerPoint: corner,
        startPoint: start,
        endPoint: end,
        value: value,
      );
    }
  }
}
