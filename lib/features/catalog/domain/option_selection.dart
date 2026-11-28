import 'package:fornea/features/catalog/domain/product.dart';

/// Opciones elegidas de un producto, por grupo. Es inmutable: cada cambio devuelve una nueva.
///
/// Repite las reglas de la web para guiar al usuario (opción única, máximo por grupo, mínimos),
/// pero no decide nada: el servidor vuelve a validar la selección al presupuestar y al pedir.
class OptionSelection {
  const OptionSelection._(this._byGroup);

  /// Lo que viene marcado por defecto (y está disponible), como en la web.
  factory OptionSelection.defaults(Product product) => OptionSelection._({
    for (final group in product.optionGroups)
      group.id: [
        for (final option in group.options)
          if (option.isDefault && option.available) option.id,
      ],
  });

  final Map<String, List<String>> _byGroup;

  List<String> _selectedIn(OptionGroup group) => _byGroup[group.id] ?? const [];

  bool isSelected(OptionGroup group, ProductOption option) =>
      _selectedIn(group).contains(option.id);

  /// El grupo ya tiene el máximo: el resto de opciones no se pueden marcar hasta quitar una.
  bool isFull(OptionGroup group) =>
      !group.isSingleChoice && _selectedIn(group).length >= group.maxSelect;

  /// Marca o desmarca [option]. En un grupo de opción única, la sustituye.
  OptionSelection toggle(OptionGroup group, ProductOption option) {
    final selected = _selectedIn(group);
    final List<String> next;
    if (group.isSingleChoice) {
      next = [option.id];
    } else if (selected.contains(option.id)) {
      next = [
        for (final id in selected)
          if (id != option.id) id,
      ];
    } else if (isFull(group)) {
      return this;
    } else {
      next = [...selected, option.id];
    }
    return OptionSelection._({..._byGroup, group.id: next});
  }

  /// Todos los grupos tienen al menos su mínimo.
  bool isCompleteFor(Product product) => product.optionGroups.every(
    (group) => _selectedIn(group).length >= group.minimumSelection,
  );

  /// Ids de todas las opciones elegidas, lo único que se envía al servidor.
  List<String> get optionIds => [for (final ids in _byGroup.values) ...ids];
}
