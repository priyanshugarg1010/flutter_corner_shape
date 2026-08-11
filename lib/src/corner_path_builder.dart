import 'dart:math' as math;
import 'dart:ui';

import 'corner_shape_value.dart';
import 'smooth_corner_geometry.dart';

/// Generates [Path] segments for a single corner based on its [CornerShapeValue].
///
/// This is the core math engine. Given a corner's two edge endpoints and the
/// corner point itself, it produces the appropriate curve:
///
/// - **K > 0** (convex): Outward cubic Bézier approximation of a superellipse.
/// - **K == 0** (bevel): Straight line between edges.
/// - **K < 0** (concave): Inward cubic Bézier (scoop).
/// - **K == +∞** (square): No curve; sharp corner.
/// - **K == -∞** (notch): Two straight lines forming a 90° inward cut.
class CornerPathBuilder {
  const CornerPathBuilder._();

  /// Adds a corner curve to [path] given:
  ///
  /// - [cornerPoint]: The actual corner of the rectangle.
  /// - [startPoint]: Where the curve starts on one edge (offset by border-radius).
  /// - [endPoint]: Where the curve ends on the adjacent edge (offset by border-radius).
  /// - [value]: The [CornerShapeValue] controlling the shape.
  ///
  /// The path's current position should be at [startPoint] before calling this.
  static void addCorner(
    Path path, {
    required Offset cornerPoint,
    required Offset startPoint,
    required Offset endPoint,
    required CornerShapeValue value,
  }) {
    final k = value.k;

    // ── Square: sharp 90° corner, no curve ──────────────────────────
    if (k == double.infinity) {
      path.lineTo(cornerPoint.dx, cornerPoint.dy);
      path.lineTo(endPoint.dx, endPoint.dy);
      return;
    }

    // ── Notch: 90° inward square cut ────────────────────────────────
    if (k == double.negativeInfinity) {
      // Compute the "inner" point that creates the notch.
      // It's the corner point reflected inward by the radius amount.
      final inward = _notchInnerPoint(cornerPoint, startPoint, endPoint);
      path.lineTo(inward.dx, inward.dy);
      path.lineTo(endPoint.dx, endPoint.dy);
      return;
    }

    // ── Bevel: straight diagonal line ───────────────────────────────
    if (k == 0) {
      path.lineTo(endPoint.dx, endPoint.dy);
      return;
    }

    // ── Superellipse curve (convex or concave) ──────────────────────
    // We approximate the superellipse corner with a cubic Bézier.
    // The control point factor determines how far the handles extend.
    //
    // For a standard circular arc (k=1), the magic number is ~0.5523.
    // For squircle (k=2), we push handles further out (~0.7).
    // For concave (k<0), we pull handles inward past the corner.

    final controlFactor = _controlPointFactor(k);

    if (k > 0) {
      // Convex: control points between start/end and the corner
      final cp1 = Offset(
        lerpDouble(startPoint.dx, cornerPoint.dx, controlFactor)!,
        lerpDouble(startPoint.dy, cornerPoint.dy, controlFactor)!,
      );
      final cp2 = Offset(
        lerpDouble(endPoint.dx, cornerPoint.dx, controlFactor)!,
        lerpDouble(endPoint.dy, cornerPoint.dy, controlFactor)!,
      );
      path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, endPoint.dx, endPoint.dy);
    } else {
      // Concave (scoop): control points pulled inward past the center
      final inward = _notchInnerPoint(cornerPoint, startPoint, endPoint);
      final concaveFactor = _concaveControlFactor(k);

      final cp1 = Offset(
        lerpDouble(startPoint.dx, inward.dx, concaveFactor)!,
        lerpDouble(startPoint.dy, inward.dy, concaveFactor)!,
      );
      final cp2 = Offset(
        lerpDouble(endPoint.dx, inward.dx, concaveFactor)!,
        lerpDouble(endPoint.dy, inward.dy, concaveFactor)!,
      );
      path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, endPoint.dx, endPoint.dy);
    }
  }

  /// Adds a Figma-style *smooth* corner to [path].
  ///
  /// Unlike [addCorner], a smooth corner's straight edges end at distance
  /// [SmoothCornerGeometry.p] from [cornerPoint] (which is `>=` the corner
  /// radius), so [startPoint] and [endPoint] here must already be positioned
  /// at that distance along each edge. The path's current position should be
  /// at [startPoint] before calling.
  ///
  /// The curve is drawn as: cubic Bézier → central circular arc → cubic
  /// Bézier, matching the geometry described by [SmoothCornerGeometry].
  static void addSmoothCorner(
    Path path, {
    required Offset cornerPoint,
    required Offset startPoint,
    required Offset endPoint,
    required SmoothCornerGeometry geometry,
  }) {
    final p = geometry.p;
    if (p <= 0) {
      // Degenerate (zero radius): behave like a sharp corner.
      path.lineTo(cornerPoint.dx, cornerPoint.dy);
      path.lineTo(endPoint.dx, endPoint.dy);
      return;
    }

    // Orthonormal local frame: e1 points from the corner toward startPoint,
    // e2 toward endPoint. `point(s1, s2)` maps local distances back to global
    // coordinates: corner + e1*s1 + e2*s2.
    final e1 = _unit(startPoint - cornerPoint);
    final e2 = _unit(endPoint - cornerPoint);
    Offset point(double s1, double s2) =>
        cornerPoint + e1 * s1 + e2 * s2;

    final a = geometry.a;
    final b = geometry.b;
    final c = geometry.c;
    final d = geometry.d;
    final r = geometry.cornerRadius;

    // Determine arc sweep direction from the handedness of (e1, e2).
    final clockwise = (e1.dx * e2.dy - e1.dy * e2.dx) < 0;

    final arcStart = point(p - a - b - c, d);
    final arcEnd = point(d, p - a - b - c);

    path.cubicTo(
      point(p - a, 0).dx, point(p - a, 0).dy,
      point(p - a - b, 0).dx, point(p - a - b, 0).dy,
      arcStart.dx, arcStart.dy,
    );
    path.arcToPoint(
      arcEnd,
      radius: Radius.circular(r),
      clockwise: clockwise,
    );
    path.cubicTo(
      point(0, p - a - b).dx, point(0, p - a - b).dy,
      point(0, p - a).dx, point(0, p - a).dy,
      endPoint.dx, endPoint.dy,
    );
  }

  static Offset _unit(Offset v) {
    final len = v.distance;
    if (len == 0) return Offset.zero;
    return v / len;
  }

  /// Compute the control point factor for convex superellipse curves.
  ///
  /// Maps K values to Bézier handle length:
  /// - K = 1 (round): ~0.5523 (standard circle approximation)
  /// - K = 2 (squircle): ~0.7
  /// - K → ∞ (square): → 1.0
  /// - K → 0+ (bevel): → 0.0
  static double _controlPointFactor(double k) {
    if (k <= 0) return 0;
    if (k >= 100) return 1.0;

    // For k=1 (circular arc), the optimal Bézier approximation factor
    // is (4/3) * (sqrt(2) - 1) ≈ 0.5523
    const circularFactor = 0.5522847498;

    if (k == 1.0) return circularFactor;

    // For other values, we interpolate:
    // k < 1: between 0 (bevel) and circular
    // k > 1: between circular and 1.0 (square)
    if (k < 1) {
      return circularFactor * k;
    } else {
      // Asymptotically approach 1.0
      // Using a power curve that goes through (1, 0.5523) and approaches (∞, 1.0)
      return 1.0 - (1.0 - circularFactor) * math.pow(1.0 / k, 0.6);
    }
  }

  /// Compute the control point factor for concave (scoop) curves.
  ///
  /// Maps negative K values to how far the Bézier handles pull inward:
  /// - K = -1 (scoop): moderate inward pull
  /// - K → -∞ (notch): full inward pull (straight lines to inner point)
  static double _concaveControlFactor(double k) {
    if (k >= 0) return 0;

    final absK = k.abs();
    if (absK >= 100) return 1.0;

    // Map: -1 → ~0.5523 (circular), approaches 1.0 as |k| → ∞
    const circularFactor = 0.5522847498;

    if (absK == 1.0) return circularFactor;

    if (absK < 1) {
      return circularFactor * absK;
    } else {
      return 1.0 - (1.0 - circularFactor) * math.pow(1.0 / absK, 0.6);
    }
  }

  /// Computes the inner point for notch/concave corners.
  ///
  /// This is the point where a 90° inward cut would meet, calculated by
  /// reflecting the corner point inward along the diagonal.
  static Offset _notchInnerPoint(
    Offset corner,
    Offset start,
    Offset end,
  ) {
    // The inner point is at: start + end - corner
    // This creates a rectangle where the notch digs in.
    return Offset(
      start.dx + end.dx - corner.dx,
      start.dy + end.dy - corner.dy,
    );
  }
}
