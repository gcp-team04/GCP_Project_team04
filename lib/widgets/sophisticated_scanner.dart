import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../utils/consumer_design.dart';

class SophisticatedScanner extends StatefulWidget {
  final double progress;
  final String? imageUrl;
  const SophisticatedScanner({
    super.key,
    required this.progress,
    this.imageUrl,
  });

  @override
  State<SophisticatedScanner> createState() => _SophisticatedScannerState();
}

class _SophisticatedScannerState extends State<SophisticatedScanner>
    with TickerProviderStateMixin {
  late AnimationController _scanningLineController;
  late AnimationController _digitalFragmentsController;

  final List<_DigitalFragment> _fragments = List.generate(
    10,
    (index) => _DigitalFragment(),
  );

  @override
  void initState() {
    super.initState();
    _scanningLineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _digitalFragmentsController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _scanningLineController.dispose();
    _digitalFragmentsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      height: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: ConsumerColor.brand400.withOpacity(0.3),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            // Image Background (Uploaded image or gray fallback)
            Container(
              color: ConsumerColor.slate100,
              width: double.infinity,
              height: double.infinity,
              child: widget.imageUrl != null
                  ? ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        ConsumerColor.brand500.withOpacity(0.1),
                        BlendMode.softLight,
                      ),
                      child: Image.network(
                        widget.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const SizedBox(),
                      ),
                    )
                  : const SizedBox(),
            ),

            // Scanning Line
            AnimatedBuilder(
              animation: _scanningLineController,
              builder: (context, child) {
                return Positioned(
                  top: _scanningLineController.value * 180,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 2,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: ConsumerColor.brand400,
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                        BoxShadow(
                          color: ConsumerColor.brand300,
                          blurRadius: 20,
                          spreadRadius: 4,
                        ),
                      ],
                      color: ConsumerColor.brand400,
                    ),
                  ),
                );
              },
            ),

            // HUD Corners
            Positioned(left: 10, top: 10, child: _HUDCorner(quadrant: 1)),
            Positioned(right: 10, top: 10, child: _HUDCorner(quadrant: 2)),
            Positioned(left: 10, bottom: 10, child: _HUDCorner(quadrant: 3)),
            Positioned(right: 10, bottom: 10, child: _HUDCorner(quadrant: 4)),

            // Digital Fragments
            ..._buildDigitalFragments(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDigitalFragments() {
    return _fragments.map((fragment) {
      return AnimatedBuilder(
        animation: _digitalFragmentsController,
        builder: (context, child) {
          double progress =
              (_digitalFragmentsController.value + fragment.delay) % 1.0;
          return Positioned(
            left:
                fragment.startX + (fragment.endX - fragment.startX) * progress,
            top: fragment.startY + (fragment.endY - fragment.startY) * progress,
            child: Opacity(
              opacity: (1 - progress) * 0.6,
              child: Transform.rotate(
                angle: fragment.rotation * progress,
                child: Text(
                  fragment.text,
                  style: const TextStyle(
                    fontSize: 10,
                    fontFamily: 'monospace',
                    color: ConsumerColor.brand400,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      );
    }).toList();
  }
}

class _HUDCorner extends StatelessWidget {
  final int quadrant;
  const _HUDCorner({required this.quadrant});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(15, 15),
      painter: _HUDCornerPainter(quadrant: quadrant),
    );
  }
}

class _HUDCornerPainter extends CustomPainter {
  final int quadrant;
  _HUDCornerPainter({required this.quadrant});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = ConsumerColor.brand400
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    switch (quadrant) {
      case 1: // Top-left
        path.moveTo(0, size.height);
        path.lineTo(0, 0);
        path.lineTo(size.width, 0);
        break;
      case 2: // Top-right
        path.moveTo(size.width, size.height);
        path.lineTo(size.width, 0);
        path.lineTo(0, 0);
        break;
      case 3: // Bottom-left
        path.moveTo(0, 0);
        path.lineTo(0, size.height);
        path.lineTo(size.width, size.height);
        break;
      case 4: // Bottom-right
        path.moveTo(size.width, 0);
        path.lineTo(size.width, size.height);
        path.lineTo(0, size.height);
        break;
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DigitalFragment {
  late final double startX;
  late final double startY;
  late final double endX;
  late final double endY;
  late final double delay;
  late final double rotation;
  late final String text;

  _DigitalFragment() {
    final random = math.Random();
    startX = random.nextDouble() * 280;
    startY = random.nextDouble() * 180;
    endX = startX + (random.nextDouble() - 0.5) * 100;
    endY = startY - 100 - random.nextDouble() * 100;
    delay = random.nextDouble();
    rotation = random.nextDouble() * 2 * math.pi;
    text = random.nextBool() ? '01' : '10';
  }
}
