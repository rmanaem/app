import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';
import 'package:starter_app/src/app/design_system/app_spacing.dart';
import 'package:starter_app/src/app/design_system/app_typography.dart';
import 'package:starter_app/src/presentation/atoms/app_button.dart';

/// Lightweight screen to exercise the auth CTAs without touching the main app.
class AuthPreviewPage extends StatelessWidget {
  /// Creates the auth preview experience.
  const AuthPreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final spacing = Theme.of(context).extension<AppSpacing>()!;
    final type = Theme.of(context).extension<AppTypography>()!;

    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing.gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: spacing.xl),
              Text(
                'SIGN IN',
                style: type.display.copyWith(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                  color: colors.ink,
                ),
              ),
              SizedBox(height: spacing.sm),
              Text(
                'Choose a provider to continue.',
                style: type.caption.copyWith(
                  color: colors.inkSubtle,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: spacing.xl),
              AppButton(
                label: 'CONTINUE WITH APPLE',
                isPrimary: true,
                icon: Icons.apple,
                onTap: () {},
              ),
              SizedBox(height: spacing.md),
              AppButton(
                label: 'CONTINUE WITH GOOGLE',
                leading: const _GoogleLogo(size: 22),
                onTap: () {},
              ),
              SizedBox(height: spacing.md),
              AppButton(
                label: 'CONTINUE WITH EMAIL',
                icon: Icons.alternate_email,
                onTap: () {},
              ),
              const Spacer(),
              Text(
                'This screen is isolated for styling the Firebase buttons '
                'before wiring full auth flows.',
                style: type.caption.copyWith(
                  color: colors.inkSubtle,
                  height: 1.4,
                ),
              ),
              SizedBox(height: spacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoogleLogo extends StatelessWidget {
  const _GoogleLogo({this.size = 20});

  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: const _GoogleLogoPainter(),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  const _GoogleLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.18;
    final rect = Rect.fromLTWH(
      stroke / 2,
      stroke / 2,
      size.width - stroke,
      size.height - stroke,
    );

    // Segment angles (quarter arcs with tiny gaps).
    const gap = 0.08;
    final segments = [
      const _Segment(
        start: -math.pi / 4,
        sweep: (math.pi / 2) - gap,
        color: Color(0xFF4285F4), // Blue
      ),
      const _Segment(
        start: math.pi / 4,
        sweep: (math.pi / 2) - gap,
        color: Color(0xFFDB4437), // Red
      ),
      const _Segment(
        start: 3 * math.pi / 4,
        sweep: (math.pi / 2) - gap,
        color: Color(0xFFF4B400), // Yellow
      ),
      const _Segment(
        start: 5 * math.pi / 4,
        sweep: (math.pi / 2) - gap,
        color: Color(0xFF0F9D58), // Green
      ),
    ];

    for (final segment in segments) {
      final paint = Paint()
        ..color = segment.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, segment.start, segment.sweep, false, paint);
    }

    // Horizontal bar of the "G"
    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    final y = size.height / 2;
    canvas.drawLine(
      Offset(size.width * 0.55, y),
      Offset(size.width * 0.9, y),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Segment {
  const _Segment({
    required this.start,
    required this.sweep,
    required this.color,
  });

  final double start;
  final double sweep;
  final Color color;
}
