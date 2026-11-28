import 'package:fornea/core/theme/app_spacing.dart';
import 'package:material_ui/material_ui.dart';

/// Control de cantidad «− 2 +» con botones táctiles, como el de la web.
class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    required this.value,
    required this.onChanged,
    required this.itemLabel,
    required this.max,
    this.min = 1,
    super.key,
  });

  final int value;
  final ValueChanged<int> onChanged;

  /// Nombre del producto, para que los lectores de pantalla digan qué cantidad cambia.
  final String itemLabel;
  final int min;
  final int max;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: 'Cantidad de $itemLabel',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton.outlined(
            onPressed: value > min ? () => onChanged(value - 1) : null,
            icon: const Icon(Icons.remove),
            tooltip: 'Quitar una unidad',
          ),
          SizedBox(
            width: AppSpacing.xl,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          IconButton.outlined(
            onPressed: value < max ? () => onChanged(value + 1) : null,
            icon: const Icon(Icons.add),
            tooltip: 'Añadir una unidad',
          ),
        ],
      ),
    );
  }
}
