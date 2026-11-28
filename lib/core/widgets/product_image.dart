import 'package:material_ui/material_ui.dart';

/// Imagen de un producto descargada de la URL que da la API.
///
/// Si el producto no tiene imagen o falla la descarga, muestra un icono de pizza en su lugar
/// (la web hace lo mismo con una ilustración), para que la tarjeta nunca quede rota.
class ProductImage extends StatelessWidget {
  const ProductImage({required this.url, required this.alt, super.key});

  final String? url;

  /// Texto alternativo para lectores de pantalla (viene de la API junto a la URL).
  final String alt;

  @override
  Widget build(BuildContext context) {
    final url = this.url;
    if (url == null) return const _Placeholder();

    return Image.network(
      url,
      fit: BoxFit.contain,
      semanticLabel: alt,
      errorBuilder: (_, _, _) => const _Placeholder(),
      // Mientras descarga, el hueco queda vacío con el fondo de la tarjeta en vez de un spinner
      // por cada imagen de la lista.
      frameBuilder: (_, child, frame, wasSynchronouslyLoaded) =>
          wasSynchronouslyLoaded || frame != null
          ? child
          : const SizedBox.expand(),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder();

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(
          Icons.local_pizza,
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}
