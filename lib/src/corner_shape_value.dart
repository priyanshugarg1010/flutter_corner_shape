import 'dart:ui' show lerpDouble;

/// Defines the shape of a corner, mirroring CSS `corner-shape` values.
///
/// Each keyword maps to a `superellipse(K)` value:
///
/// | Keyword     | K value   | Description                            |
/// |-------------|-----------|----------------------------------------|
/// | `round`     | 1         | Standard outward circular arc          |
/// | `squircle`  | 2         | Smooth iOS-style superellipse          |
/// | `bevel`     | 0         | Straight diagonal cut                  |
/// | `scoop`     | -1        | Concave inward arc                     |
/// | `notch`     | -infinity | 90° inward square cut                  |
/// | `square`    | +infinity | No rounding (sharp 90° corner)         |
enum CornerShapeType {
  /// Standard outward circular arc. Equivalent to `superellipse(1)`.
  round,

  /// Smooth iOS-style superellipse curve. Equivalent to `superellipse(2)`.
  squircle,

  /// Straight diagonal cut between two border edges. Equivalent to `superellipse(0)`.
  bevel,

  /// Concave (inward) circular arc. Equivalent to `superellipse(-1)`.
  scoop,

  /// 90° inward square cut. Equivalent to `superellipse(-infinity)`.
  notch,

  /// Disables rounding entirely. Equivalent to `superellipse(+infinity)`.
  square,
}

/// A value representing the curvature of a corner, modeled after the CSS
/// `superellipse()` function, with optional Figma-style [cornerSmoothing].
///
/// Positive values curve outward (1 = round, 2 = squircle, ∞ = square).
/// Zero gives a straight bevel. Negative values curve inward
/// (-1 = scoop, -∞ = notch).
///
/// ```dart
/// // CSS:   corner-shape: superellipse(-1.5);
/// // Dart:  CornerShapeValue.superellipse(-1.5)
///
/// // CSS:   corner-shape: scoop;
/// // Dart:  CornerShapeValue.scoop
/// ```
///
/// ## Corner smoothing (Figma squircles)
///
/// For convex corners you can additionally apply [cornerSmoothing] (0..1),
/// which renders the corner using Figma's corner-smoothing algorithm instead
/// of the superellipse Bézier. This is the same model used by the
/// `figma_squircle` package — a value of `0` is a plain circular corner and
/// `0.6` matches Figma's default "smooth" corner.
///
/// ```dart
/// // Figma default smooth corner
/// CornerShapeValue.smooth(cornerSmoothing: 0.6)
///
/// // Fully smooth (iOS-like)
/// CornerShapeValue.smooth(cornerSmoothing: 1.0)
/// ```
class CornerShapeValue {
  /// The superellipse exponent K.
  ///
  /// - `K > 0`: outward curve (larger = flatter)
  /// - `K == 0`: bevel (straight line)
  /// - `K < 0`: inward curve (smaller = deeper)
  /// - `K == double.infinity`: square (no rounding)
  /// - `K == double.negativeInfinity`: notch (90° inward cut)
  final double k;

  /// Figma-style corner smoothing, in the range `0..1`.
  ///
  /// Only applies to convex corners ([isConvex]). When greater than zero the
  /// corner is rendered with Figma's corner-smoothing algorithm rather than
  /// the raw superellipse curve:
  ///
  /// - `0`: a plain circular/superellipse corner (default).
  /// - `0.6`: Figma's default "smooth" preset.
  /// - `1.0`: maximum smoothing (iOS-like continuous curvature).
  final double cornerSmoothing;

  /// Creates a corner shape value with the given superellipse exponent [k]
  /// and optional [cornerSmoothing].
  const CornerShapeValue.superellipse(this.k, {this.cornerSmoothing = 0});

  /// Creates a Figma-style smooth (squircle) corner.
  ///
  /// This is a round corner (`K = 1`) with the given [cornerSmoothing]
  /// (0..1). Equivalent to `figma_squircle`'s `cornerSmoothing`.
  const CornerShapeValue.smooth({this.cornerSmoothing = 0.6}) : k = 1.0;

  /// Creates a corner shape value from a [CornerShapeType] keyword.
  CornerShapeValue.fromType(CornerShapeType type)
      : cornerSmoothing = 0,
        k = switch (type) {
          CornerShapeType.round => 1.0,
          CornerShapeType.squircle => 2.0,
          CornerShapeType.bevel => 0.0,
          CornerShapeType.scoop => -1.0,
          CornerShapeType.notch => double.negativeInfinity,
          CornerShapeType.square => double.infinity,
        };

  // ── Preset constants ────────────────────────────────────────────────

  /// Standard outward circular arc. `K = 1`.
  static const round = CornerShapeValue.superellipse(1);

  /// Smooth iOS-style superellipse. `K = 2`.
  static const squircle = CornerShapeValue.superellipse(2);

  /// Straight diagonal cut. `K = 0`.
  static const bevel = CornerShapeValue.superellipse(0);

  /// Concave inward arc. `K = -1`.
  static const scoop = CornerShapeValue.superellipse(-1);

  /// 90° inward square cut. `K = -∞`.
  static const notch = CornerShapeValue.superellipse(double.negativeInfinity);

  /// No rounding at all. `K = +∞`.
  static const square = CornerShapeValue.superellipse(double.infinity);

  /// Figma's default smooth corner (`cornerSmoothing = 0.6`).
  static const smoothSquircle = CornerShapeValue.smooth();

  // ── Helpers ─────────────────────────────────────────────────────────

  /// Returns a copy of this value with the given [cornerSmoothing].
  CornerShapeValue withCornerSmoothing(double cornerSmoothing) =>
      CornerShapeValue.superellipse(k, cornerSmoothing: cornerSmoothing);

  /// Whether this corner should be rendered with Figma corner smoothing.
  ///
  /// True only for convex corners with a non-zero [cornerSmoothing].
  bool get isSmooth => cornerSmoothing > 0 && isConvex;

  /// Whether this corner has outward curvature (K > 0, finite).
  bool get isConvex => k > 0 && k.isFinite;

  /// Whether this corner has inward curvature (K < 0, finite).
  bool get isConcave => k < 0 && k.isFinite;

  /// Whether this is a straight bevel (K == 0).
  bool get isBevel => k == 0;

  /// Whether this is a sharp square corner (K == +∞).
  bool get isSquare => k == double.infinity;

  /// Whether this is a notch corner (K == -∞).
  bool get isNotch => k == double.negativeInfinity;

  /// Linearly interpolates between two [CornerShapeValue]s.
  ///
  /// Handles ±infinity by clamping to large finite values for smooth
  /// animation, matching CSS behavior where keywords interpolate through
  /// their superellipse equivalents.
  static CornerShapeValue lerp(
    CornerShapeValue a,
    CornerShapeValue b,
    double t,
  ) {
    // Clamp infinities for smooth interpolation
    const maxK = 100.0;
    final aK = a.k.clamp(-maxK, maxK);
    final bK = b.k.clamp(-maxK, maxK);
    return CornerShapeValue.superellipse(
      lerpDouble(aK, bK, t)!,
      cornerSmoothing: lerpDouble(a.cornerSmoothing, b.cornerSmoothing, t)!,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CornerShapeValue &&
          runtimeType == other.runtimeType &&
          k == other.k &&
          cornerSmoothing == other.cornerSmoothing;

  @override
  int get hashCode => Object.hash(k, cornerSmoothing);

  @override
  String toString() {
    final smoothing =
        cornerSmoothing > 0 ? ', cornerSmoothing: $cornerSmoothing' : '';
    if (cornerSmoothing > 0 && k == 1.0) {
      return 'CornerShapeValue.smooth(cornerSmoothing: $cornerSmoothing)';
    }
    if (k == double.infinity) return 'CornerShapeValue.square';
    if (k == double.negativeInfinity) return 'CornerShapeValue.notch';
    if (k == 1.0) return 'CornerShapeValue.round$smoothing';
    if (k == 2.0) return 'CornerShapeValue.squircle$smoothing';
    if (k == 0.0) return 'CornerShapeValue.bevel';
    if (k == -1.0) return 'CornerShapeValue.scoop';
    return 'CornerShapeValue.superellipse($k$smoothing)';
  }
}
