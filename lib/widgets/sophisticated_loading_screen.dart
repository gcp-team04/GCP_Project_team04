import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../utils/consumer_design.dart';
import 'sophisticated_scanner.dart';

class SophisticatedLoadingScreen extends StatefulWidget {
  final double progress; // 0.0 to 1.0
  final String statusText;
  final String? imageUrl;

  const SophisticatedLoadingScreen({
    super.key,
    required this.progress,
    required this.statusText,
    this.imageUrl,
  });

  @override
  State<SophisticatedLoadingScreen> createState() =>
      _SophisticatedLoadingScreenState();
}

class _SophisticatedLoadingScreenState extends State<SophisticatedLoadingScreen>
    with TickerProviderStateMixin {
  late AnimationController _floatingController;
  late AnimationController _pulsingController;

  @override
  void initState() {
    super.initState();
    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _pulsingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatingController.dispose();
    _pulsingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: ConsumerColor.slate100),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background Decorative Blurs
          Positioned(
            top: -20,
            left: -40,
            child: _DecorativeBlur(
              color: ConsumerColor.brand200.withOpacity(0.3),
              size: 150,
            ),
          ),
          Positioned(
            bottom: 40,
            right: -40,
            child: _DecorativeBlur(
              color: ConsumerColor.brand300.withOpacity(0.2),
              size: 180,
            ),
          ),

          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pixie Mascot with Floating Animation
              AnimatedBuilder(
                animation: _floatingController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      0,
                      10 * math.sin(_floatingController.value * 2 * math.pi),
                    ),
                    child: child,
                  );
                },
                child: const PixieMascot(status: 'thinking', size: 120),
              ),
              const SizedBox(height: 24),

              // Scanner Component
              SophisticatedScanner(
                progress: widget.progress,
                imageUrl: widget.imageUrl,
              ),
              const SizedBox(height: 32),

              // Status Text & Progress
              AnimatedBuilder(
                animation: _pulsingController,
                builder: (context, child) {
                  return Opacity(
                    opacity: 0.3 + (_pulsingController.value * 0.7),
                    child: child,
                  );
                },
                child: Text(
                  widget.statusText,
                  style: ConsumerTypography.h2.copyWith(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: ConsumerColor.brand500,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${(widget.progress * 100).toInt()}%',
                    style: ConsumerTypography.h1.copyWith(
                      color: ConsumerColor.brand500,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Progress Bar
              _buildProgressBar(),
              const SizedBox(height: 16),

              Text(
                '픽시가 정밀 스캔을 통해 빠르게 견적을 내어드려요.\n잠시만 기다려 주세요!',
                style: ConsumerTypography.bodySmall.copyWith(
                  color: ConsumerColor.slate400,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      width: double.infinity,
      height: 8,
      decoration: BoxDecoration(
        color: ConsumerColor.slate100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: widget.progress.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [ConsumerColor.brand400, ConsumerColor.brand600],
            ),
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: ConsumerColor.brand500.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DecorativeBlur extends StatelessWidget {
  final Color color;
  final double size;
  const _DecorativeBlur({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ColorFilter.mode(color, BlendMode.srcIn),
          child: Container(color: Colors.transparent),
        ),
      ),
    );
  }
}
