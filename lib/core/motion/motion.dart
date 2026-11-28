/// Animaciones de la marca, copiadas de la web (`frontend/src/app/globals.css`).
///
/// Todas se desactivan si el sistema tiene «Quitar animaciones» activado (en Android, en
/// Accesibilidad u Opciones de desarrollador), igual que la web con `prefers-reduced-motion`.
library;

import 'package:material_ui/material_ui.dart';

/// La curva de las entradas de la web: `cubic-bezier(0.22, 1, 0.36, 1)` (arranca rápido y
/// frena suave).
const Cubic brandEaseOut = Cubic(0.22, 1, 0.36, 1);

/// ¿Hay que evitar el movimiento? (accesibilidad).
bool reduceMotionOf(BuildContext context) =>
    MediaQuery.disableAnimationsOf(context);

/// Entrada que se reproduce una vez al aparecer: [builder] recibe el avance de 0 a 1.
class Entrance extends StatelessWidget {
  const Entrance({
    required this.duration,
    required this.builder,
    required this.child,
    super.key,
  });

  final Duration duration;
  final Widget Function(double t, Widget child) builder;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (reduceMotionOf(context)) return child;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: duration,
      curve: brandEaseOut,
      builder: (context, t, child) => builder(t, child!),
      child: child,
    );
  }
}

/// Movimiento continuo de ida y vuelta (flotar, «respirar»): [builder] recibe un valor que
/// oscila entre 0 y 1 durante [period] (ida + vuelta), con aceleración suave en los extremos
/// como el `ease-in-out` de la web.
class LoopingMotion extends StatefulWidget {
  const LoopingMotion({
    required this.period,
    required this.builder,
    required this.child,
    super.key,
  });

  final Duration period;
  final Widget Function(double t, Widget child) builder;
  final Widget child;

  @override
  State<LoopingMotion> createState() => _LoopingMotionState();
}

class _LoopingMotionState extends State<LoopingMotion>
    with SingleTickerProviderStateMixin {
  // Ida en medio periodo y vuelta en el otro medio.
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.period ~/ 2,
  );
  late final Animation<double> _value = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInOut,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Se activa o se para si el usuario cambia «Quitar animaciones» con la app abierta.
    if (reduceMotionOf(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (reduceMotionOf(context)) return widget.child;

    // AnimatedBuilder solo reconstruye la transformación; el hijo (la imagen) se reutiliza.
    return AnimatedBuilder(
      animation: _value,
      builder: (context, child) => widget.builder(_value.value, child!),
      child: widget.child,
    );
  }
}
