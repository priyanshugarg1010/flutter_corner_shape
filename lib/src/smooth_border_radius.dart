// SmoothBorderRadius intentionally re-declares BorderRadius's corner fields
// with the more specific SmoothRadius type (as figma_squircle does).
// ignore_for_file: overridden_fields

import 'dart:math' as math;

import 'package:flutter/rendering.dart';

import 'smooth_corner_geometry.dart';
import 'smooth_radius.dart';

/// A [BorderRadius] whose corners are Figma-style smooth (squircle) corners.
///
/// Drop-in equivalent of `figma_squircle`'s `SmoothBorderRadius`. Existing
/// code can switch packages by only changing the import.
///
/// ```dart
/// SmoothBorderRadius(cornerRadius: 20, cornerSmoothing: 0.6)
///
/// SmoothBorderRadius.only(
///   topLeft: SmoothRadius(cornerRadius: 20, cornerSmoothing: 1),
///   bottomRight: SmoothRadius(cornerRadius: 8, cornerSmoothing: 0.6),
/// )
/// ```
class SmoothBorderRadius extends BorderRadius {
  /// Creates a smooth border radius with the same [cornerRadius] and
  /// [cornerSmoothing] on every corner.
  SmoothBorderRadius({
    required double cornerRadius,
    double cornerSmoothing = 0,
    bool useCache = true,
  }) : this.only(
          useCache: useCache,
          topLeft: SmoothRadius(
            cornerRadius: cornerRadius,
            cornerSmoothing: cornerSmoothing,
          ),
          topRight: SmoothRadius(
            cornerRadius: cornerRadius,
            cornerSmoothing: cornerSmoothing,
          ),
          bottomLeft: SmoothRadius(
            cornerRadius: cornerRadius,
            cornerSmoothing: cornerSmoothing,
          ),
          bottomRight: SmoothRadius(
            cornerRadius: cornerRadius,
            cornerSmoothing: cornerSmoothing,
          ),
        );

  /// Creates a border radius where all corners use [radius].
  const SmoothBorderRadius.all(
    SmoothRadius radius, {
    bool useCache = true,
  }) : this.only(
          useCache: useCache,
          topLeft: radius,
          topRight: radius,
          bottomLeft: radius,
          bottomRight: radius,
        );

  /// Creates a vertically symmetric border radius.
  const SmoothBorderRadius.vertical({
    SmoothRadius top = SmoothRadius.zero,
    SmoothRadius bottom = SmoothRadius.zero,
    bool useCache = true,
  }) : this.only(
          topLeft: top,
          topRight: top,
          bottomLeft: bottom,
          bottomRight: bottom,
          useCache: useCache,
        );

  /// Creates a horizontally symmetric border radius.
  const SmoothBorderRadius.horizontal({
    SmoothRadius left = SmoothRadius.zero,
    SmoothRadius right = SmoothRadius.zero,
    bool useCache = true,
  }) : this.only(
          useCache: useCache,
          topLeft: left,
          topRight: right,
          bottomLeft: left,
          bottomRight: right,
        );

  /// Creates a border radius with the given per-corner smooth radii. Omitted
  /// corners default to [SmoothRadius.zero] (a right angle).
  const SmoothBorderRadius.only({
    this.topLeft = SmoothRadius.zero,
    this.topRight = SmoothRadius.zero,
    this.bottomLeft = SmoothRadius.zero,
    this.bottomRight = SmoothRadius.zero,
    this.useCache = true,
  }) : super.only(
          topLeft: topLeft,
          topRight: topRight,
          bottomLeft: bottomLeft,
          bottomRight: bottomRight,
        );

  /// A border radius with all zero radii.
  static const SmoothBorderRadius zero =
      SmoothBorderRadius.all(SmoothRadius.zero);

  @override
  final SmoothRadius topLeft;
  @override
  final SmoothRadius topRight;
  @override
  final SmoothRadius bottomLeft;
  @override
  final SmoothRadius bottomRight;

  /// Whether smooth-corner geometry is memoized across calls.
  final bool useCache;

  /// Returns a copy of this radius with the given fields replaced.
  ///
  /// Non-[SmoothRadius] arguments are ignored (the existing corner is kept).
  @override
  SmoothBorderRadius copyWith({
    Radius? topLeft,
    Radius? topRight,
    Radius? bottomLeft,
    Radius? bottomRight,
    bool? useCache,
  }) {
    return SmoothBorderRadius.only(
      useCache: useCache ?? this.useCache,
      topLeft: topLeft is SmoothRadius ? topLeft : this.topLeft,
      topRight: topRight is SmoothRadius ? topRight : this.topRight,
      bottomLeft: bottomLeft is SmoothRadius ? bottomLeft : this.bottomLeft,
      bottomRight: bottomRight is SmoothRadius ? bottomRight : this.bottomRight,
    );
  }

  /// Builds the smooth-cornered [Path] filling [rect].
  Path toPath(Rect rect) {
    final width = rect.width;
    final height = rect.height;
    final result = Path();

    // Only recompute geometry for corners whose radius actually differs.
    final gTopLeft = _geometry(topLeft, width, height);
    final gBottomLeft = topLeft == bottomLeft
        ? gTopLeft
        : _geometry(bottomLeft, width, height);
    final gBottomRight = bottomLeft == bottomRight
        ? gBottomLeft
        : _geometry(bottomRight, width, height);
    final gTopRight = topRight == bottomRight
        ? gBottomRight
        : _geometry(topRight, width, height);

    _addSmoothTopRight(result, gTopRight, width, height);
    _addSmoothBottomRight(result, gBottomRight, width, height);
    _addSmoothBottomLeft(result, gBottomLeft, width, height);
    _addSmoothTopLeft(result, gTopLeft, width, height);

    return result.transform(
      Matrix4.translationValues(rect.left, rect.top, 0).storage,
    );
  }

  SmoothCornerGeometry _geometry(
    SmoothRadius radius,
    double width,
    double height,
  ) =>
      SmoothCornerGeometry(
        cornerRadius: radius.cornerRadius,
        cornerSmoothing: radius.cornerSmoothing,
        width: width,
        height: height,
        useCache: useCache,
      );

  // ── Figma corner path builders (ported verbatim, drawing clockwise) ──

  void _addSmoothTopRight(
      Path path, SmoothCornerGeometry g, double width, double height) {
    if (g.cornerRadius <= 0) {
      path
        ..moveTo(width / 2, 0)
        ..lineTo(width, 0)
        ..lineTo(width, height / 2);
      return;
    }
    final a = g.a, b = g.b, c = g.c, d = g.d, p = g.p;
    path
      ..moveTo(math.max(width / 2, width - p), 0)
      ..cubicTo(
        width - (p - a), 0,
        width - (p - a - b), 0,
        width - (p - a - b - c), d,
      )
      ..relativeArcToPoint(
        Offset(g.circularSectionLength, g.circularSectionLength),
        radius: Radius.circular(g.cornerRadius),
      )
      ..cubicTo(
        width, p - a - b,
        width, p - a,
        width, math.min(height / 2, p),
      );
  }

  void _addSmoothBottomRight(
      Path path, SmoothCornerGeometry g, double width, double height) {
    if (g.cornerRadius <= 0) {
      path
        ..lineTo(width, height)
        ..lineTo(width / 2, height);
      return;
    }
    final a = g.a, b = g.b, c = g.c, d = g.d, p = g.p;
    path
      ..lineTo(width, math.max(height / 2, height - p))
      ..cubicTo(
        width, height - (p - a),
        width, height - (p - a - b),
        width - d, height - (p - a - b - c),
      )
      ..relativeArcToPoint(
        Offset(-g.circularSectionLength, g.circularSectionLength),
        radius: Radius.circular(g.cornerRadius),
      )
      ..cubicTo(
        width - (p - a - b), height,
        width - (p - a), height,
        math.max(width / 2, width - p), height,
      );
  }

  void _addSmoothBottomLeft(
      Path path, SmoothCornerGeometry g, double width, double height) {
    if (g.cornerRadius <= 0) {
      path
        ..lineTo(0, height)
        ..lineTo(0, height / 2);
      return;
    }
    final a = g.a, b = g.b, c = g.c, d = g.d, p = g.p;
    path
      ..lineTo(math.min(width / 2, p), height)
      ..cubicTo(
        p - a, height,
        p - a - b, height,
        p - a - b - c, height - d,
      )
      ..relativeArcToPoint(
        Offset(-g.circularSectionLength, -g.circularSectionLength),
        radius: Radius.circular(g.cornerRadius),
      )
      ..cubicTo(
        0, height - (p - a - b),
        0, height - (p - a),
        0, math.max(height / 2, height - p),
      );
  }

  void _addSmoothTopLeft(
      Path path, SmoothCornerGeometry g, double width, double height) {
    if (g.cornerRadius <= 0) {
      path
        ..lineTo(0, 0)
        ..close();
      return;
    }
    final a = g.a, b = g.b, c = g.c, d = g.d, p = g.p;
    path
      ..lineTo(0, math.min(height / 2, p))
      ..cubicTo(
        0, p - a,
        0, p - a - b,
        d, p - a - b - c,
      )
      ..relativeArcToPoint(
        Offset(g.circularSectionLength, -g.circularSectionLength),
        radius: Radius.circular(g.cornerRadius),
      )
      ..cubicTo(
        p - a - b, 0,
        p - a, 0,
        math.min(width / 2, p), 0,
      )
      ..close();
  }

  @override
  BorderRadiusGeometry subtract(BorderRadiusGeometry other) {
    if (other is SmoothBorderRadius) return this - other;
    return super.subtract(other);
  }

  @override
  BorderRadiusGeometry add(BorderRadiusGeometry other) {
    if (other is SmoothBorderRadius) return this + other;
    return super.add(other);
  }

  /// Returns the difference between two smooth border radii.
  @override
  SmoothBorderRadius operator -(BorderRadius other) {
    if (other is SmoothBorderRadius) {
      return SmoothBorderRadius.only(
        useCache: useCache,
        topLeft: (topLeft - other.topLeft) as SmoothRadius,
        topRight: (topRight - other.topRight) as SmoothRadius,
        bottomLeft: (bottomLeft - other.bottomLeft) as SmoothRadius,
        bottomRight: (bottomRight - other.bottomRight) as SmoothRadius,
      );
    }
    return this;
  }

  /// Returns the sum of two smooth border radii.
  @override
  SmoothBorderRadius operator +(BorderRadius other) {
    if (other is SmoothBorderRadius) {
      return SmoothBorderRadius.only(
        useCache: useCache,
        topLeft: (topLeft + other.topLeft) as SmoothRadius,
        topRight: (topRight + other.topRight) as SmoothRadius,
        bottomLeft: (bottomLeft + other.bottomLeft) as SmoothRadius,
        bottomRight: (bottomRight + other.bottomRight) as SmoothRadius,
      );
    }
    return this;
  }

  @override
  SmoothBorderRadius operator -() {
    return SmoothBorderRadius.only(
      useCache: useCache,
      topLeft: (-topLeft) as SmoothRadius,
      topRight: (-topRight) as SmoothRadius,
      bottomLeft: (-bottomLeft) as SmoothRadius,
      bottomRight: (-bottomRight) as SmoothRadius,
    );
  }

  @override
  SmoothBorderRadius operator *(double other) {
    return SmoothBorderRadius.only(
      useCache: useCache,
      topLeft: topLeft * other,
      topRight: topRight * other,
      bottomLeft: bottomLeft * other,
      bottomRight: bottomRight * other,
    );
  }

  @override
  SmoothBorderRadius operator /(double other) {
    return SmoothBorderRadius.only(
      useCache: useCache,
      topLeft: topLeft / other,
      topRight: topRight / other,
      bottomLeft: bottomLeft / other,
      bottomRight: bottomRight / other,
    );
  }

  @override
  SmoothBorderRadius operator ~/(double other) {
    return SmoothBorderRadius.only(
      useCache: useCache,
      topLeft: topLeft ~/ other,
      topRight: topRight ~/ other,
      bottomLeft: bottomLeft ~/ other,
      bottomRight: bottomRight ~/ other,
    );
  }

  @override
  SmoothBorderRadius operator %(double other) {
    return SmoothBorderRadius.only(
      useCache: useCache,
      topLeft: topLeft % other,
      topRight: topRight % other,
      bottomLeft: bottomLeft % other,
      bottomRight: bottomRight % other,
    );
  }

  /// Linearly interpolates between two smooth border radii.
  ///
  /// If either is null, interpolates from [SmoothBorderRadius.zero].
  static SmoothBorderRadius? lerp(
      SmoothBorderRadius? a, SmoothBorderRadius? b, double t) {
    if (a == null && b == null) return null;
    if (a == null) return b!.copyWith(useCache: false) * t;
    if (b == null) return a.copyWith(useCache: false) * (1.0 - t);
    return SmoothBorderRadius.only(
      useCache: false, // Disable caching while animating.
      topLeft: SmoothRadius.lerp(a.topLeft, b.topLeft, t)!,
      topRight: SmoothRadius.lerp(a.topRight, b.topRight, t)!,
      bottomLeft: SmoothRadius.lerp(a.bottomLeft, b.bottomLeft, t)!,
      bottomRight: SmoothRadius.lerp(a.bottomRight, b.bottomRight, t)!,
    );
  }

  @override
  BorderRadius resolve(TextDirection? direction) => BorderRadius.only(
        topLeft: topLeft,
        topRight: topRight,
        bottomLeft: bottomLeft,
        bottomRight: bottomRight,
      );

  @override
  String toString() {
    if (topLeft == topRight &&
        topLeft == bottomRight &&
        topLeft == bottomLeft) {
      return 'SmoothBorderRadius(${topLeft.toString()})';
    }
    return 'SmoothBorderRadius('
        'topLeft: $topLeft, '
        'topRight: $topRight, '
        'bottomLeft: $bottomLeft, '
        'bottomRight: $bottomRight)';
  }
}
