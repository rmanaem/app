import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:starter_app/src/app/design_system/app_colors.dart';

/// A button with the "Dense Smoke" industrial aesthetic.
/// Features a backdrop blur, semi-transparent fill, and crisp steel border.
class GlassButton extends StatelessWidget {
  /// Creates a GlassButton.
  const GlassButton({
    required this.label,
    required this.onTap,
    this.isSelected = false,
    this.isPrimary = false, // Toggle for the brighter "Enter" button
    super.key,
  });

  /// The text displayed on the button.
  final String label;

  /// Callback when tapped.
  final VoidCallback onTap;

  /// Whether the button is in a selected state (for toggle buttons).
  final bool isSelected;

  /// Whether this is a primary CTA (brighter steel look).
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;

    // VISIBILITY FIX:
    // Primary buttons get a brighter steel wash to pop against black.
    // Secondary/Toggle buttons keep the dark smoke look.
    final surfaceGradient = isPrimary
        ? [
            Colors.white.withValues(alpha: 0.20), // Stronger Top Highlight
            Colors.white.withValues(alpha: 0.08), // Visible Bottom
          ]
        : [
            c.glassFill.withValues(alpha: 0.6),
            c.glassFill.withValues(alpha: 0.2),
          ];

    // BORDER FIX: "Diamond Cut" Edge
    // Extremely bright top-left to simulate metal reflection
    final Gradient borderGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isPrimary
          ? [
              Colors.white.withValues(
                alpha: 0.9,
              ), // Almost pure white reflection
              Colors.white.withValues(alpha: 0.1),
              Colors.white.withValues(alpha: 0.05),
              Colors.white.withValues(alpha: 0.3), // Bottom bounce light
            ]
          : [
              c.glassBorder.withValues(alpha: 0.8),
              c.glassBorder.withValues(alpha: 0.1),
            ],
      stops: isPrimary ? const [0.0, 0.3, 0.6, 1.0] : null,
    );

    // TEXT COLOR FIX:
    // Primary buttons use white text for max contrast.
    // Secondary use the "Argent" (Silver) ink color.
    final textColor = isPrimary ? Colors.white : (isSelected ? c.ink : c.ink);

    return Container(
      height: 64, // Tall, touchable target
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100), // Stadium Shape
        // AMBIENT GLOW: Separation from the void
        boxShadow: isPrimary
            ? [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.05),
                  blurRadius: 24,
                  spreadRadius: -4,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20), // Heavy Blur
          child: Stack(
            children: [
              // 1. Surface Gradient
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: surfaceGradient,
                  ),
                ),
              ),

              // 2. Inner Bevel (Top Highlight)
              // Draws a faint white line INSIDE the border for thickness
              Positioned(
                top: 1,
                left: 12,
                right: 12,
                height: 1,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0),
                        Colors.white.withValues(alpha: 0.4),
                        Colors.white.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),

              // 3. Gradient Border Painter
              CustomPaint(
                painter: _GradientBorderPainter(
                  radius: 100,
                  strokeWidth: 1, // Razor thin precision
                  gradient: borderGradient,
                ),
                child: Container(),
              ),

              // 4. Interaction & Text
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTap,
                  splashColor: Colors.white.withValues(alpha: 0.2),
                  highlightColor: Colors.white.withValues(alpha: 0.1),
                  child: Center(
                    child: Text(
                      label,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w800, // Thicker font
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GradientBorderPainter extends CustomPainter {
  _GradientBorderPainter({
    required this.radius,
    required this.strokeWidth,
    required this.gradient,
  });
  final double radius;
  final double strokeWidth;
  final Gradient gradient;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..shader = gradient.createShader(rect);

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
