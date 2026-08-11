import 'dart:math' as math;

/// The precomputed control-point geometry for a single Figma-style smooth
/// corner (a.k.a. "squircle" with corner smoothing).
///
/// This is a faithful port of the algorithm Figma uses for its corner
/// smoothing feature, as described in
/// <https://www.figma.com/blog/desperately-seeking-squircles/> and the
/// reference implementation at
/// <https://github.com/MartinRGB/Figma_Squircles_Approximation>.
///
/// A smooth corner is built from three pieces on each side of a central
/// circular arc:
///
/// ```
///   straight edge ──▶ cubic Bézier ──▶ circular arc ──▶ cubic Bézier ──▶ straight edge
/// ```
///
/// The [a], [b], [c] and [d] values describe how far the Bézier control
/// points sit from the corner, [p] is the distance from the corner at which
/// the straight edge ends and the curved region begins, and
/// [circularSectionLength] is the size of the central circular arc.
///
/// Instances are cached because the math is comparatively expensive and the
/// same `(cornerRadius, cornerSmoothing, width, height)` tuples recur across
/// frames.
class SmoothCornerGeometry {
  const SmoothCornerGeometry._({
    required this.a,
    required this.b,
    required this.c,
    required this.d,
    required this.p,
    required this.width,
    required this.height,
    required this.cornerRadius,
    required this.cornerSmoothing,
    required this.circularSectionLength,
  });

  static final Map<(double, double, double, double), SmoothCornerGeometry>
      _cache = {};

  /// Computes the smooth-corner geometry for a corner of [cornerRadius] with
  /// the given [cornerSmoothing] (0..1), inside a box of [width] × [height].
  ///
  /// [cornerRadius] is clamped to `min(width, height) / 2` (matching Figma),
  /// so overly large radii degrade gracefully to a fully rounded side.
  ///
  /// Results are memoized when [useCache] is true.
  factory SmoothCornerGeometry({
    required double cornerRadius,
    required double cornerSmoothing,
    required double width,
    required double height,
    bool useCache = true,
  }) {
    final key = (cornerRadius, cornerSmoothing, width, height);
    if (useCache) {
      final cached = _cache[key];
      if (cached != null) return cached;
    }

    final maxRadius = math.min(width, height) / 2;
    final radius = math.min(cornerRadius, maxRadius);

    // 12.2 from the article: how far the smoothing extends past the arc.
    final p = math.min((1 + cornerSmoothing) * radius, maxRadius);

    final double angleAlpha, angleBeta;
    if (radius <= maxRadius / 2) {
      angleBeta = 90 * (1 - cornerSmoothing);
      angleAlpha = 45 * cornerSmoothing;
    } else {
      // For large radii the angles additionally depend on how far past
      // `maxRadius / 2` the radius reaches.
      final diffRatio = (radius - maxRadius / 2) / (maxRadius / 2);
      angleBeta = 90 * (1 - cornerSmoothing * (1 - diffRatio));
      angleAlpha = 45 * cornerSmoothing * (1 - diffRatio);
    }

    final angleTheta = (90 - angleBeta) / 2;

    // Distance between control points P3 and P4 in the article.
    final p3ToP4Distance = radius * math.tan(_radians(angleTheta / 2));

    // Length of the central circular arc section.
    final circularSectionLength =
        math.sin(_radians(angleBeta / 2)) * radius * math.sqrt2;

    // a, b, c, d from 11.1 in the article.
    final c = p3ToP4Distance * math.cos(_radians(angleAlpha));
    final d = c * math.tan(_radians(angleAlpha));
    final b = (p - circularSectionLength - c - d) / 3;
    final a = 2 * b;

    final result = SmoothCornerGeometry._(
      a: a,
      b: b,
      c: c,
      d: d,
      p: p,
      width: width,
      height: height,
      cornerRadius: radius,
      cornerSmoothing: cornerSmoothing,
      circularSectionLength: circularSectionLength,
    );
    if (useCache) _cache[key] = result;
    return result;
  }

  /// First Bézier handle length (`= 2 * b`).
  final double a;

  /// Second Bézier handle length.
  final double b;

  /// Bézier handle length feeding into the circular arc.
  final double c;

  /// Perpendicular offset of the arc-adjacent control point.
  final double d;

  /// Distance from the corner at which the straight edge ends.
  final double p;

  /// Length of the central circular arc section.
  final double circularSectionLength;

  /// The (clamped) corner radius the geometry was computed for.
  final double cornerRadius;

  /// The corner smoothing factor (0..1) the geometry was computed for.
  final double cornerSmoothing;

  /// The box width the geometry was computed for.
  final double width;

  /// The box height the geometry was computed for.
  final double height;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SmoothCornerGeometry &&
          other.cornerRadius == cornerRadius &&
          other.cornerSmoothing == cornerSmoothing &&
          other.width == width &&
          other.height == height;

  @override
  int get hashCode =>
      Object.hash(cornerRadius, cornerSmoothing, width, height);

  @override
  String toString() => 'SmoothCornerGeometry('
      'cornerRadius: ${cornerRadius.toStringAsFixed(2)}, '
      'cornerSmoothing: ${cornerSmoothing.toStringAsFixed(2)}, '
      'a: ${a.toStringAsFixed(2)}, b: ${b.toStringAsFixed(2)}, '
      'c: ${c.toStringAsFixed(2)}, d: ${d.toStringAsFixed(2)}, '
      'p: ${p.toStringAsFixed(2)})';
}

double _radians(double degrees) => degrees * (math.pi / 180.0);
