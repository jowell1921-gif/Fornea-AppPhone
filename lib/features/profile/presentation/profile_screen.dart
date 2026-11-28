import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fornea/core/navigation/app_routes.dart';
import 'package:fornea/core/network/error_messages.dart';
import 'package:fornea/core/theme/app_spacing.dart';
import 'package:fornea/core/widgets/section_heading.dart';
import 'package:fornea/dev/sample_data_banner.dart';
import 'package:fornea/features/orders/presentation/widgets/order_tile.dart';
import 'package:fornea/features/profile/presentation/account_providers.dart';
import 'package:fornea/features/profile/presentation/widgets/account_header.dart';
import 'package:fornea/features/profile/presentation/widgets/points_card.dart';
import 'package:fornea/features/profile/presentation/widgets/sign_in_required.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// «Tu cuenta»: datos del cliente, puntos de FORNEA CLUB y últimos pedidos (con sesión), más
/// el acceso al club y a la información legal (siempre).
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasAccount = ref.watch(hasAccountProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Tu cuenta')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          if (hasAccount)
            const _AccountSections()
          else
            const SizedBox(
              height: 360,
              child: SignInRequired(
                icon: Icons.person_outline,
                message: 'Consulta tus puntos de FORNEA CLUB y tus pedidos.',
              ),
            ),
          const SizedBox(height: AppSpacing.lg),
          const _MoreSection(),
        ],
      ),
    );
  }
}

/// Lo que exige sesión: cabecera, puntos y últimos pedidos.
class _AccountSections extends ConsumerWidget {
  const _AccountSections();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final account = ref.watch(loyaltyAccountProvider);
    final transactions = ref.watch(recentTransactionsProvider);
    final orders = ref.watch(myOrdersProvider);

    final error = profile.error ?? account.error ?? orders.error;
    if (error != null) {
      return Column(
        children: [
          Text(loadErrorMessage(error)),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            onPressed: () => ref
              ..invalidate(profileProvider)
              ..invalidate(loyaltyAccountProvider)
              ..invalidate(recentTransactionsProvider)
              ..invalidate(myOrdersProvider),
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      );
    }

    return switch ((profile.value, account.value, orders.value)) {
      (final profile?, final account?, final orders?) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (ref.watch(isSampleAccountProvider)) ...[
            const SampleDataBanner(
              detail: 'el inicio de sesión llega en la Fase 5',
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          AccountHeader(profile: profile),
          const SizedBox(height: AppSpacing.md),
          PointsCard(
            account: account,
            transactions: transactions.value ?? const [],
            onOpenClub: () => context.push(AppRoutes.club),
          ),
          const SizedBox(height: AppSpacing.lg),
          SectionHeading(
            title: 'Mis pedidos',
            action: TextButton(
              onPressed: () => context.go(AppRoutes.orders),
              child: const Text('Ver todos'),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (orders.isEmpty)
            const Text(
              'Todavía no has hecho ningún pedido. Cuando hagas el primero, aquí verás '
              'su estado.',
            )
          else
            // Los tres más recientes; el historial completo está en la pestaña Pedidos.
            for (final order in orders.take(3))
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: OrderTile(order: order),
              ),
        ],
      ),
      _ => const Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Center(
          child: CircularProgressIndicator(semanticsLabel: 'Cargando'),
        ),
      ),
    };
  }
}

/// Accesos que no dependen de la sesión.
class _MoreSection extends StatelessWidget {
  const _MoreSection();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.card_giftcard),
            title: const Text('FORNEA CLUB'),
            subtitle: const Text('Cómo funciona y recompensas'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppRoutes.club),
          ),
          const Divider(height: 1),
          // Las licencias OFL de las tipografías deben quedar accesibles desde la app.
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Licencias de código abierto'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => showLicensePage(context: context),
          ),
          if (kDebugMode) ...[
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.widgets_outlined),
              title: const Text('Componentes (desarrollo)'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(AppRoutes.devComponents),
            ),
          ],
        ],
      ),
    );
  }
}
