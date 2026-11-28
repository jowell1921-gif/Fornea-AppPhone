import 'dart:math' as math;

import 'package:fornea/core/theme/app_spacing.dart';
import 'package:material_ui/material_ui.dart';

/// Borde discontinuo con esquinas redondeadas alrededor de [child].
///
/// Flutter no trae bordes discontinuos, así que se dibujan a mano con un [CustomPainter].
/// La web los usa para lo que no está disponible y para los avisos.
class DashedOutline extends StatelessWidget {
  const DashedOutline({
    required this.child,
    this.color,
    this.radius = AppRadius.lg,
    super.key,
  });

  final Widget child;

  /// Por defecto, el color de contorno del tema.
  final Color? color;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: _DashedRRectPainter(
        color: color ?? Theme.of(context).colorScheme.outline,
        radius: radius,
      ),
      child: child,
    );
  }
}

class _DashedRRectPainter extends CustomPainter {
  _DashedRRectPainter({required this.color, required this.radius});

  static const double _dash = 6;
  static const double _gap = 4;
  static const double _strokeWidth = 1;

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth;
    // Se encoge medio trazo para que la línea quede entera dentro del widget.
    final outline = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          (Offset.zero & size).deflate(_strokeWidth / 2),
          Radius.circular(radius),
        ),
      );

    // Se recorre el contorno y se dibujan solo los tramos «trazo», saltando los huecos.
    for (final metric in outline.computeMetrics()) {
      for (var start = 0.0; start < metric.length; start += _dash + _gap) {
        final end = math.min(start + _dash, metric.length);
        canvas.drawPath(metric.extractPath(start, end), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedRRectPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}
