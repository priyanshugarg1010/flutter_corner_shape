import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import 'corner_path_builder.dart';
import 'corner_shape_spec.dart';
import 'corner_shape_value.dart';

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

    final tlR = clampedBR.topLeft;
    final trR = clampedBR.topRight;
    final brR = clampedBR.bottomRight;
    final blR = clampedBR.bottomLeft;

    // ── Top-left corner ─────────────────────────────────────────────
    final tlStart = Offset(rect.left, rect.top + tlR.y);
    final tlCorner = Offset(rect.left, rect.top);
    final tlEnd = Offset(rect.left + tlR.x, rect.top);

    path.moveTo(tlStart.dx, tlStart.dy);
    CornerPathBuilder.addCorner(
      path,
      cornerPoint: tlCorner,
      startPoint: tlStart,
      endPoint: tlEnd,
      value: cornerShape.topLeft,
    );

    // ── Top-right corner ────────────────────────────────────────────
    final trStart = Offset(rect.right - trR.x, rect.top);
    final trCorner = Offset(rect.right, rect.top);
    final trEnd = Offset(rect.right, rect.top + trR.y);

    path.lineTo(trStart.dx, trStart.dy);
    CornerPathBuilder.addCorner(
      path,
      cornerPoint: trCorner,
      startPoint: trStart,
      endPoint: trEnd,
      value: cornerShape.topRight,
    );

    // ── Bottom-right corner ─────────────────────────────────────────
    final brStart = Offset(rect.right, rect.bottom - brR.y);
    final brCorner = Offset(rect.right, rect.bottom);
    final brEnd = Offset(rect.right - brR.x, rect.bottom);

    path.lineTo(brStart.dx, brStart.dy);
    CornerPathBuilder.addCorner(
      path,
      cornerPoint: brCorner,
      startPoint: brStart,
      endPoint: brEnd,
      value: cornerShape.bottomRight,
    );

    // ── Bottom-left corner ──────────────────────────────────────────
    final blStart = Offset(rect.left + blR.x, rect.bottom);
    final blCorner = Offset(rect.left, rect.bottom);
    final blEnd = Offset(rect.left, rect.bottom - blR.y);

    path.lineTo(blStart.dx, blStart.dy);
    CornerPathBuilder.addCorner(
      path,
      cornerPoint: blCorner,
      startPoint: blStart,
      endPoint: blEnd,
      value: cornerShape.bottomLeft,
    );

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
