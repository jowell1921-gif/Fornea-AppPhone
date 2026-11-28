import 'package:fornea/core/motion/motion.dart';
import 'package:material_ui/material_ui.dart';

/// Aparición al desplazar, como `.scroll-reveal` de la web: el contenido sube 36 px y aparece
/// a medida que entra por abajo en la pantalla.
///
/// Está ligado al desplazamiento (no al tiempo), igual que en la web: si el usuario vuelve
/// hacia arriba, el efecto se deshace.
class ScrollReveal extends StatefulWidget {
  const ScrollReveal({required this.child, super.key});

  final Widget child;

  /// Distancia de subida, la misma que la web.
  static const double offset = 36;

  @override
  State<ScrollReveal> createState() => _ScrollRevealState();
}

class _ScrollRevealState extends State<ScrollReveal> {
  /// Avance de 0 (oculto) a 1 (visible). Empieza en 1 para que lo que ya está en pantalla al
  /// abrir no parpadee; el primer cálculo llega tras pintar el primer fotograma.
  final ValueNotifier<double> _progress = ValueNotifier(1);
  ScrollPosition? _position;
  bool _measureScheduled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _position?.removeListener(_scheduleMeasure);
    _position = reduceMotionOf(context)
        ? null
        : Scrollable.maybeOf(context)?.position;
    _position?.addListener(_scheduleMeasure);
    if (_position == null) {
      _progress.value = 1;
    } else {
      _scheduleMeasure();
    }
  }

  @override
  void dispose() {
    _position?.removeListener(_scheduleMeasure);
    _progress.dispose();
    super.dispose();
  }

  /// Mide después de dibujar el fotograma: cuando avisa el desplazamiento, las posiciones en
  /// pantalla aún son las del fotograma anterior. Como mucho una medida por fotograma.
  void _scheduleMeasure() {
    if (_measureScheduled) return;
    _measureScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measureScheduled = false;
      _update();
    });
  }

  /// Calcula cuánto ha entrado el widget en la zona visible.
  void _update() {
    if (!mounted) return;
    final box = context.findRenderObject();
    final viewport = Scrollable.maybeOf(context)?.context.findRenderObject();
    if (box is! RenderBox || viewport is! RenderBox) return;
    if (!box.attached || !box.hasSize || !viewport.hasSize) return;

    final top = box.localToGlobal(Offset.zero, ancestor: viewport).dy;
    final entered = viewport.size.height - top;
    // Como `animation-range: entry 0% entry 70%`: termina cuando ha entrado el 70 % de su
    // altura (con un mínimo, para que en tarjetas bajas no sea instantáneo).
    final range = (box.size.height * 0.7).clamp(48.0, double.infinity);
    _progress.value = (entered / range).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: _progress,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, ScrollReveal.offset * (1 - t)),
          child: child,
        ),
      ),
      child: widget.child,
    );
  }
}
