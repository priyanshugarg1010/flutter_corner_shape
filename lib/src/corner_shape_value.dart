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
/// `superellipse()` function.
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
class CornerShapeValue {
  /// The superellipse exponent K.
  ///
  /// - `K > 0`: outward curve (larger = flatter)
  /// - `K == 0`: bevel (straight line)
  /// - `K < 0`: inward curve (smaller = deeper)
  /// - `K == double.infinity`: square (no rounding)
  /// - `K == double.negativeInfinity`: notch (90° inward cut)
  final double k;

  /// Creates a corner shape value with the given superellipse exponent [k].
  const CornerShapeValue.superellipse(this.k);

  /// Creates a corner shape value from a [CornerShapeType] keyword.
  CornerShapeValue.fromType(CornerShapeType type)
      : k = switch (type) {
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

  // ── Helpers ─────────────────────────────────────────────────────────

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
    return CornerShapeValue.superellipse(lerpDouble(aK, bK, t)!);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CornerShapeValue &&
          runtimeType == other.runtimeType &&
          k == other.k;

  @override
  int get hashCode => k.hashCode;

  @override
  String toString() {
    if (k == double.infinity) return 'CornerShapeValue.square';
    if (k == double.negativeInfinity) return 'CornerShapeValue.notch';
    if (k == 1.0) return 'CornerShapeValue.round';
    if (k == 2.0) return 'CornerShapeValue.squircle';
    if (k == 0.0) return 'CornerShapeValue.bevel';
    if (k == -1.0) return 'CornerShapeValue.scoop';
    return 'CornerShapeValue.superellipse($k)';
  }
}
