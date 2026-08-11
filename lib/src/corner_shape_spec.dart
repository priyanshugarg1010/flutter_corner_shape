import 'corner_shape_value.dart';

/// Specifies the [CornerShapeValue] for each corner of a rectangle,
/// mirroring CSS `corner-shape` shorthand.
///
/// ```dart
/// // CSS:  corner-shape: scoop;
/// CornerShapeSpec.all(CornerShapeValue.scoop)
///
/// // CSS:  corner-shape: round scoop bevel notch;
/// CornerShapeSpec.only(
///   topLeft: CornerShapeValue.round,
///   topRight: CornerShapeValue.scoop,
///   bottomRight: CornerShapeValue.bevel,
///   bottomLeft: CornerShapeValue.notch,
/// )
///
/// // CSS shorthand with 2 values (top-left+bottom-right, top-right+bottom-left)
/// CornerShapeSpec.symmetric(
///   diagonal1: CornerShapeValue.round,
///   diagonal2: CornerShapeValue.scoop,
/// )
/// ```
class CornerShapeSpec {
  /// The shape of the top-left corner.
  final CornerShapeValue topLeft;

  /// The shape of the top-right corner.
  final CornerShapeValue topRight;

  /// The shape of the bottom-right corner.
  final CornerShapeValue bottomRight;

  /// The shape of the bottom-left corner.
  final CornerShapeValue bottomLeft;

  /// Creates a [CornerShapeSpec] with explicit values for each corner.
  const CornerShapeSpec.only({
    this.topLeft = CornerShapeValue.round,
    this.topRight = CornerShapeValue.round,
    this.bottomRight = CornerShapeValue.round,
    this.bottomLeft = CornerShapeValue.round,
  });

  /// Creates a [CornerShapeSpec] with the same value for all corners.
  ///
  /// CSS equivalent: `corner-shape: <value>;`
  const CornerShapeSpec.all(CornerShapeValue value)
      : topLeft = value,
        topRight = value,
        bottomRight = value,
        bottomLeft = value;

  /// Creates a [CornerShapeSpec] with symmetric diagonal values.
  ///
  /// CSS equivalent: `corner-shape: <diagonal1> <diagonal2>;`
  /// - [diagonal1]: top-left and bottom-right
  /// - [diagonal2]: top-right and bottom-left
  const CornerShapeSpec.symmetric({
    required CornerShapeValue diagonal1,
    required CornerShapeValue diagonal2,
  })  : topLeft = diagonal1,
        topRight = diagonal2,
        bottomRight = diagonal1,
        bottomLeft = diagonal2;

  /// Creates a [CornerShapeSpec] with different vertical halves.
  ///
  /// CSS equivalent: `corner-shape: <top> <top> <bottom> <bottom>;`
  const CornerShapeSpec.vertical({
    required CornerShapeValue top,
    required CornerShapeValue bottom,
  })  : topLeft = top,
        topRight = top,
        bottomRight = bottom,
        bottomLeft = bottom;

  /// Creates a [CornerShapeSpec] with different horizontal halves.
  const CornerShapeSpec.horizontal({
    required CornerShapeValue left,
    required CornerShapeValue right,
  })  : topLeft = left,
        topRight = right,
        bottomRight = right,
        bottomLeft = left;

  /// All corners are standard round.
  static const round = CornerShapeSpec.all(CornerShapeValue.round);

  /// All corners are squircle (iOS-style).
  static const squircle = CornerShapeSpec.all(CornerShapeValue.squircle);

  /// All corners are beveled.
  static const bevel = CornerShapeSpec.all(CornerShapeValue.bevel);

  /// All corners are scooped (concave).
  static const scoop = CornerShapeSpec.all(CornerShapeValue.scoop);

  /// All corners are notched.
  static const notch = CornerShapeSpec.all(CornerShapeValue.notch);

  /// All corners are square (no rounding).
  static const square = CornerShapeSpec.all(CornerShapeValue.square);

  /// All corners use Figma's default smooth (squircle) corner
  /// (`cornerSmoothing = 0.6`).
  static const smoothSquircle =
      CornerShapeSpec.all(CornerShapeValue.smoothSquircle);

  /// Creates a [CornerShapeSpec] whose corners are Figma-style smooth
  /// corners with the given [cornerSmoothing] (0..1).
  CornerShapeSpec.smooth({double cornerSmoothing = 0.6})
      : this.all(CornerShapeValue.smooth(cornerSmoothing: cornerSmoothing));

  /// Linearly interpolates between two [CornerShapeSpec]s.
  static CornerShapeSpec lerp(CornerShapeSpec a, CornerShapeSpec b, double t) {
    return CornerShapeSpec.only(
      topLeft: CornerShapeValue.lerp(a.topLeft, b.topLeft, t),
      topRight: CornerShapeValue.lerp(a.topRight, b.topRight, t),
      bottomRight: CornerShapeValue.lerp(a.bottomRight, b.bottomRight, t),
      bottomLeft: CornerShapeValue.lerp(a.bottomLeft, b.bottomLeft, t),
    );
  }

  /// Returns a copy with the given fields replaced.
  CornerShapeSpec copyWith({
    CornerShapeValue? topLeft,
    CornerShapeValue? topRight,
    CornerShapeValue? bottomRight,
    CornerShapeValue? bottomLeft,
  }) {
    return CornerShapeSpec.only(
      topLeft: topLeft ?? this.topLeft,
      topRight: topRight ?? this.topRight,
      bottomRight: bottomRight ?? this.bottomRight,
      bottomLeft: bottomLeft ?? this.bottomLeft,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CornerShapeSpec &&
          topLeft == other.topLeft &&
          topRight == other.topRight &&
          bottomRight == other.bottomRight &&
          bottomLeft == other.bottomLeft;

  @override
  int get hashCode => Object.hash(topLeft, topRight, bottomRight, bottomLeft);

  @override
  String toString() {
    if (topLeft == topRight &&
        topRight == bottomRight &&
        bottomRight == bottomLeft) {
      return 'CornerShapeSpec.all($topLeft)';
    }
    return 'CornerShapeSpec.only('
        'topLeft: $topLeft, '
        'topRight: $topRight, '
        'bottomRight: $bottomRight, '
        'bottomLeft: $bottomLeft)';
  }
}
