import 'package:flutter/material.dart';
import 'package:flutter_corner_shape/flutter_corner_shape.dart';
import 'package:figma_squircle/figma_squircle.dart' as fs;

/// Side-by-side comparison of `flutter_corner_shape` vs the real
/// `figma_squircle` package for every squircle (corner-smoothing) config.
///
/// Column 1: `figma_squircle` (filled, blue)
/// Column 2: `flutter_corner_shape` native `CornerShapeBorder` (filled, purple)
/// Column 3: overlay — figma_squircle fill with the native outline on top.
///           If they match, the white outline hugs the blue fill exactly.
class ComparisonPage extends StatelessWidget {
  const ComparisonPage({super.key});

  static const _figmaColor = Color(0xFF3b82f6); // blue
  static const _mineColor = Color(0xFFa78bfa); // purple
  static const _outlineColor = Color(0xFFffffff);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Legend(),
          const SizedBox(height: 20),

          _block(
            title: 'Square box · radius 40 · smoothing 0 → 1',
            size: const Size(120, 120),
            radius: 40,
            smoothings: const [0, 0.25, 0.5, 0.6, 0.75, 1.0],
          ),
          const SizedBox(height: 40),

          _block(
            title: 'Wide box 220×110 · radius 36 · smoothing 0 → 1',
            size: const Size(220, 110),
            radius: 36,
            smoothings: const [0, 0.3, 0.6, 1.0],
          ),
          const SizedBox(height: 40),

          _block(
            title: 'Large radius (> maxRadius/2) · 120×120 · radius 55',
            size: const Size(120, 120),
            radius: 55,
            smoothings: const [0.3, 0.6, 1.0],
          ),
          const SizedBox(height: 40),

          _block(
            title: 'Small radius · 120×120 · radius 12',
            size: const Size(120, 120),
            radius: 12,
            smoothings: const [0.3, 0.6, 1.0],
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  Widget _block({
    required String title,
    required Size size,
    required double radius,
    required List<double> smoothings,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 22,
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B35),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 28,
          runSpacing: 28,
          children: [
            for (final s in smoothings)
              _row(size: size, radius: radius, smoothing: s),
          ],
        ),
      ],
    );
  }

  Widget _row({
    required Size size,
    required double radius,
    required double smoothing,
  }) {
    return Column(
      children: [
        Text(
          'cornerSmoothing = $smoothing',
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 12,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _labelled('figma_squircle', _figma(size, radius, smoothing)),
            const SizedBox(width: 16),
            _labelled('flutter_corner_shape', _mine(size, radius, smoothing)),
            const SizedBox(width: 16),
            _labelled('overlay (diff)', _overlay(size, radius, smoothing)),
          ],
        ),
      ],
    );
  }

  Widget _labelled(String label, Widget child) {
    return Column(
      children: [
        child,
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: Colors.grey[500]),
        ),
      ],
    );
  }

  // The real figma_squircle package.
  Widget _figma(Size size, double radius, double smoothing) {
    return Container(
      width: size.width,
      height: size.height,
      decoration: ShapeDecoration(
        color: _figmaColor,
        shape: fs.SmoothRectangleBorder(
          borderRadius: fs.SmoothBorderRadius(
            cornerRadius: radius,
            cornerSmoothing: smoothing,
          ),
        ),
      ),
    );
  }

  // This package's native API.
  Widget _mine(Size size, double radius, double smoothing) {
    return Container(
      width: size.width,
      height: size.height,
      decoration: ShapeDecoration(
        color: _mineColor,
        shape: CornerShapeBorder(
          borderRadius: BorderRadius.circular(radius),
          cornerShape: CornerShapeSpec.smooth(cornerSmoothing: smoothing),
        ),
      ),
    );
  }

  // figma_squircle fill with this package's native outline on top.
  Widget _overlay(Size size, double radius, double smoothing) {
    return SizedBox(
      width: size.width,
      height: size.height,
      child: Stack(
        children: [
          _figma(size, radius, smoothing),
          Container(
            width: size.width,
            height: size.height,
            decoration: ShapeDecoration(
              shape: CornerShapeBorder(
                side: const BorderSide(color: _outlineColor, width: 1.5),
                borderRadius: BorderRadius.circular(radius),
                cornerShape: CornerShapeSpec.smooth(cornerSmoothing: smoothing),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a20),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What am I looking at?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Each config is rendered three ways. The "overlay" column draws '
            'the real figma_squircle shape as a blue fill and this package\'s '
            'native CornerShapeBorder as a white outline on top. When they '
            'agree, the white line sits exactly on the blue edge.',
            style: TextStyle(fontSize: 13, color: Colors.grey[400], height: 1.4),
          ),
          const SizedBox(height: 10),
          Text(
            'Note: this package\'s drop-in SmoothRectangleBorder is a verbatim '
            'port of figma_squircle\'s path builder, so it is identical by '
            'construction — this page instead stress-tests the native '
            'generalized renderer against the original.',
            style: TextStyle(fontSize: 12, color: Colors.grey[600], height: 1.4),
          ),
        ],
      ),
    );
  }
}
