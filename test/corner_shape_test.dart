import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_corner_shape/flutter_corner_shape.dart';

void main() {
  group('CornerShapeValue', () {
    test('keyword constants map to correct K values', () {
      expect(CornerShapeValue.round.k, 1.0);
      expect(CornerShapeValue.squircle.k, 2.0);
      expect(CornerShapeValue.bevel.k, 0.0);
      expect(CornerShapeValue.scoop.k, -1.0);
      expect(CornerShapeValue.notch.k, double.negativeInfinity);
      expect(CornerShapeValue.square.k, double.infinity);
    });

    test('fromType matches static constants', () {
      expect(
        CornerShapeValue.fromType(CornerShapeType.round),
        CornerShapeValue.round,
      );
      expect(
        CornerShapeValue.fromType(CornerShapeType.scoop),
        CornerShapeValue.scoop,
      );
    });

    test('isConvex / isConcave / isBevel', () {
      expect(CornerShapeValue.round.isConvex, isTrue);
      expect(CornerShapeValue.scoop.isConcave, isTrue);
      expect(CornerShapeValue.bevel.isBevel, isTrue);
      expect(CornerShapeValue.square.isSquare, isTrue);
      expect(CornerShapeValue.notch.isNotch, isTrue);
    });

    test('lerp interpolates between values', () {
      final result = CornerShapeValue.lerp(
        CornerShapeValue.round, // K=1
        CornerShapeValue.scoop, // K=-1
        0.5,
      );
      expect(result.k, closeTo(0.0, 0.001)); // midpoint = bevel
    });

    test('lerp handles infinity by clamping', () {
      final result = CornerShapeValue.lerp(
        CornerShapeValue.square, // +∞
        CornerShapeValue.notch, // -∞
        0.5,
      );
      expect(result.k, closeTo(0.0, 0.1));
    });

    test('equality and hashCode', () {
      expect(CornerShapeValue.round, CornerShapeValue.round);
      expect(
        const CornerShapeValue.superellipse(1.0),
        CornerShapeValue.round,
      );
      expect(
        CornerShapeValue.round.hashCode,
        const CornerShapeValue.superellipse(1.0).hashCode,
      );
    });

    test('toString returns readable names', () {
      expect(CornerShapeValue.round.toString(), 'CornerShapeValue.round');
      expect(CornerShapeValue.square.toString(), 'CornerShapeValue.square');
      expect(
        const CornerShapeValue.superellipse(1.5).toString(),
        'CornerShapeValue.superellipse(1.5)',
      );
    });
  });

  group('CornerShapeSpec', () {
    test('.all sets all corners to the same value', () {
      const spec = CornerShapeSpec.all(CornerShapeValue.scoop);
      expect(spec.topLeft, CornerShapeValue.scoop);
      expect(spec.topRight, CornerShapeValue.scoop);
      expect(spec.bottomRight, CornerShapeValue.scoop);
      expect(spec.bottomLeft, CornerShapeValue.scoop);
    });

    test('.only allows per-corner specification', () {
      const spec = CornerShapeSpec.only(
        topLeft: CornerShapeValue.round,
        topRight: CornerShapeValue.scoop,
        bottomRight: CornerShapeValue.bevel,
        bottomLeft: CornerShapeValue.notch,
      );
      expect(spec.topLeft, CornerShapeValue.round);
      expect(spec.topRight, CornerShapeValue.scoop);
      expect(spec.bottomRight, CornerShapeValue.bevel);
      expect(spec.bottomLeft, CornerShapeValue.notch);
    });

    test('.symmetric sets diagonal pairs', () {
      const spec = CornerShapeSpec.symmetric(
        diagonal1: CornerShapeValue.round,
        diagonal2: CornerShapeValue.scoop,
      );
      expect(spec.topLeft, CornerShapeValue.round);
      expect(spec.bottomRight, CornerShapeValue.round);
      expect(spec.topRight, CornerShapeValue.scoop);
      expect(spec.bottomLeft, CornerShapeValue.scoop);
    });

    test('.vertical sets top/bottom halves', () {
      const spec = CornerShapeSpec.vertical(
        top: CornerShapeValue.bevel,
        bottom: CornerShapeValue.scoop,
      );
      expect(spec.topLeft, CornerShapeValue.bevel);
      expect(spec.topRight, CornerShapeValue.bevel);
      expect(spec.bottomRight, CornerShapeValue.scoop);
      expect(spec.bottomLeft, CornerShapeValue.scoop);
    });

    test('lerp interpolates all corners', () {
      final result = CornerShapeSpec.lerp(
        CornerShapeSpec.round,
        CornerShapeSpec.scoop,
        0.5,
      );
      expect(result.topLeft.k, closeTo(0.0, 0.001));
      expect(result.topRight.k, closeTo(0.0, 0.001));
    });

    test('copyWith replaces specified corners', () {
      const original = CornerShapeSpec.all(CornerShapeValue.round);
      final modified = original.copyWith(topRight: CornerShapeValue.scoop);
      expect(modified.topLeft, CornerShapeValue.round);
      expect(modified.topRight, CornerShapeValue.scoop);
      expect(modified.bottomRight, CornerShapeValue.round);
    });
  });

  group('CornerShapeBorder', () {
    test('generates a valid outer path', () {
      const border = CornerShapeBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        cornerShape: CornerShapeSpec.scoop,
      );
      final path = border.getOuterPath(
        const Rect.fromLTWH(0, 0, 200, 200),
      );
      expect(path, isNotNull);
      expect(path.getBounds().width, greaterThan(0));
    });

    test('generates valid inner path with border', () {
      const border = CornerShapeBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        cornerShape: CornerShapeSpec.bevel,
        side: BorderSide(width: 2, color: Color(0xFF000000)),
      );
      final path = border.getInnerPath(
        const Rect.fromLTWH(0, 0, 200, 200),
      );
      expect(path, isNotNull);
      expect(path.getBounds().width, greaterThan(0));
    });

    test('lerpFrom another CornerShapeBorder', () {
      const a = CornerShapeBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        cornerShape: CornerShapeSpec.round,
      );
      const b = CornerShapeBorder(
        borderRadius: BorderRadius.all(Radius.circular(30)),
        cornerShape: CornerShapeSpec.scoop,
      );
      final result = b.lerpFrom(a, 0.5);
      expect(result, isA<CornerShapeBorder>());
    });

    test('lerpTo RoundedRectangleBorder', () {
      const a = CornerShapeBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        cornerShape: CornerShapeSpec.scoop,
      );
      const b = RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      );
      final result = a.lerpTo(b, 0.5);
      expect(result, isA<CornerShapeBorder>());
    });

    test('copyWith preserves unmodified fields', () {
      const original = CornerShapeBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        cornerShape: CornerShapeSpec.scoop,
        side: BorderSide(width: 2, color: Color(0xFFFF0000)),
      );
      final copy = original.copyWith(
        cornerShape: CornerShapeSpec.bevel,
      );
      expect(copy.borderRadius, original.borderRadius);
      expect(copy.side, original.side);
      expect(copy.cornerShape, CornerShapeSpec.bevel);
    });

    test('equality', () {
      const a = CornerShapeBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        cornerShape: CornerShapeSpec.scoop,
      );
      const b = CornerShapeBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        cornerShape: CornerShapeSpec.scoop,
      );
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });
  });

  group('CornerShapeSpecTween', () {
    test('lerp produces intermediate values', () {
      final tween = CornerShapeSpecTween(
        begin: CornerShapeSpec.round,
        end: CornerShapeSpec.scoop,
      );
      final mid = tween.lerp(0.5);
      // K=1 → K=-1, midpoint = K=0 (bevel)
      expect(mid.topLeft.k, closeTo(0.0, 0.001));
    });
  });

  group('ClipCornerShape widget', () {
    testWidgets('renders without errors', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ClipCornerShape(
                borderRadius: BorderRadius.circular(20),
                cornerShape: CornerShapeSpec.scoop,
                child: Container(
                  width: 100,
                  height: 100,
                  color: Colors.red,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(ClipCornerShape), findsOneWidget);
      expect(find.byType(ClipPath), findsOneWidget);
    });

    testWidgets('.all constructor works', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ClipCornerShape.all(
                borderRadius: BorderRadius.circular(20),
                cornerShapeValue: CornerShapeValue.bevel,
                child: Container(
                  width: 100,
                  height: 100,
                  color: Colors.blue,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(ClipCornerShape), findsOneWidget);
    });
  });

  group('CornerShapeDecoration', () {
    test('creates a valid ShapeDecoration', () {
      final decoration = CornerShapeDecoration(
        color: const Color(0xFFFF0000),
        borderRadius: BorderRadius.circular(20),
        cornerShape: CornerShapeSpec.scoop,
      );
      expect(decoration.shape, isA<CornerShapeBorder>());
    });

    test('.all convenience constructor', () {
      final decoration = CornerShapeDecoration.all(
        color: const Color(0xFFFF0000),
        borderRadius: BorderRadius.circular(20),
        cornerShapeValue: CornerShapeValue.bevel,
      );
      final shape = decoration.shape as CornerShapeBorder;
      expect(
        shape.cornerShape,
        const CornerShapeSpec.all(CornerShapeValue.bevel),
      );
    });
  });
}
