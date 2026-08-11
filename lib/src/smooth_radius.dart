import 'dart:ui';

/// A [Radius] with an associated Figma-style [cornerSmoothing] factor.
///
/// This is a drop-in equivalent of `figma_squircle`'s `SmoothRadius`, so
/// existing code that imports it from `figma_squircle` can switch to
/// `flutter_corner_shape` by only changing the import.
///
/// ```dart
/// const SmoothRadius(cornerRadius: 20, cornerSmoothing: 0.6)
/// ```
///
/// [cornerSmoothing] ranges from `0` (a plain circular corner) to `1`
/// (maximum smoothing). Figma's default "smooth" preset is `0.6`.
class SmoothRadius extends Radius {
  /// Creates a circular smooth radius of [cornerRadius] with the given
  /// [cornerSmoothing].
  const SmoothRadius({
    required double cornerRadius,
    required this.cornerSmoothing,
  }) : super.circular(cornerRadius);

  /// The corner smoothing factor, in the range `0..1`.
  final double cornerSmoothing;

  /// The corner radius (equal to [Radius.x]).
  double get cornerRadius => x;

  /// A smooth radius of zero with no smoothing.
  static const zero = SmoothRadius(cornerRadius: 0, cornerSmoothing: 0);

  /// Unary negation. Negates the radius, preserving the smoothing.
  @override
  Radius operator -() => SmoothRadius(
        cornerRadius: -cornerRadius,
        cornerSmoothing: cornerSmoothing,
      );

  /// Subtraction. When subtracting another [SmoothRadius], smoothing is
  /// averaged; otherwise the smoothing is preserved.
  @override
  Radius operator -(Radius other) {
    if (other is SmoothRadius) {
      return SmoothRadius(
        cornerRadius: cornerRadius - other.cornerRadius,
        cornerSmoothing: (cornerSmoothing + other.cornerSmoothing) / 2,
      );
    }
    return SmoothRadius(
      cornerRadius: cornerRadius - other.x,
      cornerSmoothing: cornerSmoothing,
    );
  }

  /// Addition. When adding another [SmoothRadius], smoothing is averaged;
  /// otherwise the smoothing is preserved.
  @override
  Radius operator +(Radius other) {
    if (other is SmoothRadius) {
      return SmoothRadius(
        cornerRadius: cornerRadius + other.cornerRadius,
        cornerSmoothing: (cornerSmoothing + other.cornerSmoothing) / 2,
      );
    }
    return SmoothRadius(
      cornerRadius: cornerRadius + other.x,
      cornerSmoothing: cornerSmoothing,
    );
  }

  /// Scalar multiplication.
  @override
  SmoothRadius operator *(double operand) => SmoothRadius(
        cornerRadius: cornerRadius * operand,
        cornerSmoothing: cornerSmoothing * operand,
      );

  /// Scalar division.
  @override
  SmoothRadius operator /(double operand) => SmoothRadius(
        cornerRadius: cornerRadius / operand,
        cornerSmoothing: cornerSmoothing / operand,
      );

  /// Integer (truncating) scalar division.
  @override
  SmoothRadius operator ~/(double operand) => SmoothRadius(
        cornerRadius: (cornerRadius ~/ operand).toDouble(),
        cornerSmoothing: (cornerSmoothing ~/ operand).toDouble(),
      );

  /// Scalar modulo.
  @override
  SmoothRadius operator %(double operand) => SmoothRadius(
        cornerRadius: cornerRadius % operand,
        cornerSmoothing: cornerSmoothing % operand,
      );

  /// Linearly interpolates between two smooth radii.
  ///
  /// If either is null, [SmoothRadius.zero] is substituted.
  static SmoothRadius? lerp(SmoothRadius? a, SmoothRadius? b, double t) {
    if (b == null) {
      if (a == null) return null;
      final k = 1.0 - t;
      return SmoothRadius(
        cornerRadius: a.cornerRadius * k,
        cornerSmoothing: a.cornerSmoothing * k,
      );
    }
    if (a == null) {
      return SmoothRadius(
        cornerRadius: b.cornerRadius * t,
        cornerSmoothing: b.cornerSmoothing * t,
      );
    }
    return SmoothRadius(
      cornerRadius: lerpDouble(a.cornerRadius, b.cornerRadius, t) ?? 0,
      cornerSmoothing:
          lerpDouble(a.cornerSmoothing, b.cornerSmoothing, t) ?? 0,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (runtimeType != other.runtimeType) return false;
    return other is SmoothRadius &&
        other.cornerRadius == cornerRadius &&
        other.cornerSmoothing == cornerSmoothing;
  }

  @override
  int get hashCode => Object.hash(cornerRadius, cornerSmoothing);

  @override
  String toString() => 'SmoothRadius('
      'cornerRadius: ${cornerRadius.toStringAsFixed(2)}, '
      'cornerSmoothing: ${cornerSmoothing.toStringAsFixed(2)})';
}
