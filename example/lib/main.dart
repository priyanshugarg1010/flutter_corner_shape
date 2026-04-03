import 'package:flutter/material.dart';
import 'package:flutter_corner_shape/flutter_corner_shape.dart';

void main() => runApp(const CornerShapeDemo());

class CornerShapeDemo extends StatelessWidget {
  const CornerShapeDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Corner Shape Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: const Color(0xFF0c0c0f),
      ),
      home: const DemoPage(),
    );
  }
}

class DemoPage extends StatefulWidget {
  const DemoPage({super.key});

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('corner_shape'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Section 1: All keyword shapes ──────────────────────
            _sectionTitle('Keyword Values'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _shapeBox('round', CornerShapeSpec.round),
                _shapeBox('squircle', CornerShapeSpec.squircle),
                _shapeBox('bevel', CornerShapeSpec.bevel),
                _shapeBox('scoop', CornerShapeSpec.scoop),
                _shapeBox('notch', CornerShapeSpec.notch),
                _shapeBox('square', CornerShapeSpec.square),
              ],
            ),

            const SizedBox(height: 48),

            // ── Section 2: Superellipse spectrum ──────────────────
            _sectionTitle('Superellipse Spectrum'),
            const SizedBox(height: 8),
            Text(
              'From K = -3 (deep scoop) → K = 3 (nearly square)',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final k in [-3.0, -2.0, -1.0, -0.5, 0.0, 0.5, 1.0, 2.0, 3.0])
                  _superellipseBox(k),
              ],
            ),

            const SizedBox(height: 48),

            // ── Section 3: Ticket / Coupon ────────────────────────
            _sectionTitle('Ticket Shape'),
            const SizedBox(height: 16),
            Center(
              child: Container(
                width: 300,
                height: 100,
                decoration: ShapeDecoration(
                  color: const Color(0xFFFF6B35),
                  shape: CornerShapeBorder(
                    borderRadius: BorderRadius.circular(50),
                    cornerShape: CornerShapeSpec.scoop,
                  ),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'ADMIT ONE',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 4,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 48),

            // ── Section 4: Mixed corners ──────────────────────────
            _sectionTitle('Per-Corner Control'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _mixedBox(
                  'round / scoop\nbevel / notch',
                  const CornerShapeSpec.only(
                    topLeft: CornerShapeValue.round,
                    topRight: CornerShapeValue.scoop,
                    bottomRight: CornerShapeValue.bevel,
                    bottomLeft: CornerShapeValue.notch,
                  ),
                ),
                _mixedBox(
                  'scoop top\nround bottom',
                  CornerShapeSpec.vertical(
                    top: CornerShapeValue.scoop,
                    bottom: CornerShapeValue.round,
                  ),
                ),
                _mixedBox(
                  'bevel left\nscoop right',
                  CornerShapeSpec.horizontal(
                    left: CornerShapeValue.bevel,
                    right: CornerShapeValue.scoop,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 48),

            // ── Section 5: Animated morph ─────────────────────────
            _sectionTitle('Animated Morph'),
            const SizedBox(height: 16),
            Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final spec = CornerShapeSpec.lerp(
                    CornerShapeSpec.all(
                        CornerShapeValue.superellipse(3)),
                    CornerShapeSpec.all(
                        CornerShapeValue.superellipse(-3)),
                    _controller.value,
                  );
                  return Container(
                    width: 140,
                    height: 140,
                    decoration: ShapeDecoration(
                      color: const Color(0xFFFF6B35),
                      shape: CornerShapeBorder(
                        borderRadius: const BorderRadius.all(
                            Radius.circular(70)),
                        cornerShape: spec,
                        side: const BorderSide(
                            color: Colors.white, width: 3),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 48),

            // ── Section 6: ClipCornerShape demo ───────────────────
            _sectionTitle('ClipCornerShape'),
            const SizedBox(height: 16),
            Center(
              child: ClipCornerShape(
                borderRadius: BorderRadius.circular(40),
                cornerShape: CornerShapeSpec.scoop,
                child: Container(
                  width: 200,
                  height: 200,
                  color: const Color(0xFF4ade80),
                  alignment: Alignment.center,
                  child: const Text(
                    'Clipped!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 48),

            // ── Section 7: CornerShapeDecoration demo ─────────────
            _sectionTitle('CornerShapeDecoration'),
            const SizedBox(height: 16),
            Center(
              child: Container(
                width: 200,
                height: 120,
                decoration: CornerShapeDecoration(
                  color: const Color(0xFF1e1e24),
                  borderRadius: BorderRadius.circular(24),
                  cornerShape: CornerShapeSpec.all(
                      CornerShapeValue.superellipse(-1.5)),
                  side: const BorderSide(
                      color: Color(0xFFFF6B35), width: 2),
                  shadows: const [
                    BoxShadow(
                      color: Color(0x40FF6B35),
                      blurRadius: 20,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Text(
                  'With shadows!',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: const Color(0xFFFF6B35),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _shapeBox(String label, CornerShapeSpec spec) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: ShapeDecoration(
            color: const Color(0xFFFF6B35),
            shape: CornerShapeBorder(
              borderRadius: BorderRadius.circular(24),
              cornerShape: spec,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 12,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  Widget _superellipseBox(double k) {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: ShapeDecoration(
            color: const Color(0xFFFF6B35).withValues(
              alpha: 0.5 + 0.5 * ((k + 3) / 6).clamp(0, 1),
            ),
            shape: CornerShapeBorder(
              borderRadius: BorderRadius.circular(20),
              cornerShape: CornerShapeSpec.all(
                  CornerShapeValue.superellipse(k)),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'K=$k',
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _mixedBox(String label, CornerShapeSpec spec) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: ShapeDecoration(
            color: const Color(0xFF60a5fa),
            shape: CornerShapeBorder(
              borderRadius: BorderRadius.circular(24),
              cornerShape: spec,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 10,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }
}
