import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_corner_shape/flutter_corner_shape.dart';

void main() {
  group('SmoothCornerGeometry', () {
    test('control points satisfy the article invariants', () {
      final g = SmoothCornerGeometry(
        cornerRadius: 30,
        cornerSmoothing: 0.6,
        width: 200,
        height: 120,
      );
      // a == 2b (11.1 in the article).
      expect(g.a, closeTo(2 * g.b, 1e-9));
      // p is partitioned into 3b + c + d + circularSectionLength.
      expect(
        g.p,
        closeTo(3 * g.b + g.c + g.d + g.circularSectionLength, 1e-6),
      );
      // p == (1 + smoothing) * radius when within budget.
      expect(g.p, closeTo(1.6 * 30, 1e-6));
    });

    test('cornerRadius is clamped to half the shortest side', () {
      final g = SmoothCornerGeometry(
        cornerRadius: 500,
        cornerSmoothing: 0.5,
        width: 200,
        height: 120,
      );
      expect(g.cornerRadius, 60); // min(200,120)/2
    });

    test('zero smoothing keeps p at the corner radius', () {
      final g = SmoothCornerGeometry(
        cornerRadius: 20,
        cornerSmoothing: 0,
        width: 200,
        height: 200,
      );
      expect(g.p, closeTo(20, 1e-9));
    });
  });

  group('CornerShapeValue smoothing', () {
    test('smooth() is a round corner with smoothing', () {
      const v = CornerShapeValue.smooth(cornerSmoothing: 0.6);
      expect(v.k, 1.0);
      expect(v.cornerSmoothing, 0.6);
      expect(v.isSmooth, isTrue);
      expect(v.isConvex, isTrue);
    });

    test('smoothing only counts as smooth on convex corners', () {
      const scoopSmooth =
          CornerShapeValue.superellipse(-1, cornerSmoothing: 0.6);
      expect(scoopSmooth.isSmooth, isFalse);
    });

    test('equality distinguishes smoothing', () {
      expect(
        const CornerShapeValue.smooth(cornerSmoothing: 0.6),
        isNot(const CornerShapeValue.smooth(cornerSmoothing: 0.3)),
      );
      expect(CornerShapeValue.round.isSmooth, isFalse);
    });

    test('lerp interpolates smoothing', () {
      final mid = CornerShapeValue.lerp(
        const CornerShapeValue.smooth(cornerSmoothing: 0),
        const CornerShapeValue.smooth(cornerSmoothing: 1),
        0.5,
      );
      expect(mid.cornerSmoothing, closeTo(0.5, 1e-9));
    });
  });

  group('compat classes', () {
    test('SmoothBorderRadius.toPath is closed and correctly bounded', () {
      final radius =
          SmoothBorderRadius(cornerRadius: 24, cornerSmoothing: 0.6);
      const rect = Rect.fromLTWH(0, 0, 200, 120);
      final path = radius.toPath(rect);
      final bounds = path.getBounds();
      expect(bounds.left, closeTo(0, 0.01));
      expect(bounds.top, closeTo(0, 0.01));
      expect(bounds.width, closeTo(200, 0.01));
      expect(bounds.height, closeTo(120, 0.01));
      // Center is inside, far corner is outside.
      expect(path.contains(const Offset(100, 60)), isTrue);
      expect(path.contains(const Offset(0.5, 0.5)), isFalse);
    });

    test('SmoothRadius operators behave like figma_squircle', () {
      const r = SmoothRadius(cornerRadius: 10, cornerSmoothing: 0.6);
      expect((r * 2).cornerRadius, 20);
      expect((r * 2).cornerSmoothing, closeTo(1.2, 1e-9));
      const other = SmoothRadius(cornerRadius: 30, cornerSmoothing: 0.2);
      final sum = (r + other) as SmoothRadius;
      expect(sum.cornerRadius, 40);
      expect(sum.cornerSmoothing, closeTo(0.4, 1e-9)); // averaged
    });

    testWidgets('SmoothRectangleBorder and ClipSmoothRect render',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: ClipSmoothRect(
              radius:
                  SmoothBorderRadius(cornerRadius: 24, cornerSmoothing: 0.6),
              child: Container(
                width: 100,
                height: 100,
                decoration: ShapeDecoration(
                  color: Colors.blue,
                  shape: SmoothRectangleBorder(
                    side: const BorderSide(color: Colors.black, width: 2),
                    borderRadius: SmoothBorderRadius(
                      cornerRadius: 24,
                      cornerSmoothing: 0.6,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('native smooth corner == figma compat geometry', () {
    // The native generalized smooth-corner builder must produce the same
    // shape as the verbatim Figma path in SmoothBorderRadius.
    for (final config in [
      (radius: 24.0, smoothing: 0.6, w: 200.0, h: 120.0),
      (radius: 40.0, smoothing: 1.0, w: 160.0, h: 160.0),
      (radius: 12.0, smoothing: 0.3, w: 300.0, h: 90.0),
      (radius: 55.0, smoothing: 0.8, w: 120.0, h: 120.0), // radius > maxR/2
    ]) {
      test('config r=${config.radius} s=${config.smoothing}', () {
        final rect = Rect.fromLTWH(0, 0, config.w, config.h);

        final compat = SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius(
            cornerRadius: config.radius,
            cornerSmoothing: config.smoothing,
          ),
        ).getOuterPath(rect);

        final native = CornerShapeBorder(
          borderRadius: BorderRadius.circular(config.radius),
          cornerShape: CornerShapeSpec.all(
            CornerShapeValue.smooth(cornerSmoothing: config.smoothing),
          ),
        ).getOuterPath(rect);

        // Sample a dense grid and require the two shapes to agree on
        // inside/outside for all but a thin anti-aliased boundary band.
        final rng = math.Random(42);
        var mismatches = 0;
        const int samples = 4000;
        for (var i = 0; i < samples; i++) {
          final pt = Offset(
            rng.nextDouble() * config.w,
            rng.nextDouble() * config.h,
          );
          if (compat.contains(pt) != native.contains(pt)) {
            // Allow disagreement only very close to the outline.
            final nearEdge = _distanceToOutline(pt, rect, config.radius) < 1.5;
            if (!nearEdge) mismatches++;
          }
        }
        expect(mismatches, 0,
            reason: 'native and figma smooth paths diverge away from edges');
      });
    }
  });
}

/// Rough distance from [pt] to the rounded-rect outline, used only to ignore
/// boundary-band disagreements between two near-identical shapes.
double _distanceToOutline(Offset pt, Rect rect, double r) {
  // Distance to the axis-aligned inset rectangle edges is a good enough proxy.
  final dx = math.min(pt.dx - rect.left, rect.right - pt.dx);
  final dy = math.min(pt.dy - rect.top, rect.bottom - pt.dy);
  return math.min(dx, dy);
}
