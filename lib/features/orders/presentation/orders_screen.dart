import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fornea/core/navigation/app_routes.dart';
import 'package:fornea/core/network/error_messages.dart';
import 'package:fornea/core/theme/app_spacing.dart';
import 'package:fornea/core/widgets/empty_state.dart';
import 'package:fornea/core/widgets/error_view.dart';
import 'package:fornea/core/widgets/loading_view.dart';
import 'package:fornea/dev/sample_data_banner.dart';
import 'package:fornea/features/orders/presentation/widgets/order_tile.dart';
import 'package:fornea/features/profile/presentation/account_providers.dart';
import 'package:fornea/features/profile/presentation/widgets/sign_in_required.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// Historial de pedidos del cliente, del más reciente al más antiguo.
class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Widget body;
    if (!ref.watch(hasAccountProvider)) {
      body = const SignInRequired(
        icon: Icons.receipt_long_outlined,
        message: 'Aquí verás el estado y el historial de tus pedidos.',
      );
    } else {
      body = switch (ref.watch(myOrdersProvider)) {
        AsyncData(value: []) => EmptyState(
          icon: Icons.receipt_long_outlined,
          title: 'Aún no tienes pedidos',
          message: 'Cuando hagas el primero, aquí verás su estado.',
          action: FilledButton(
            onPressed: () => context.go(AppRoutes.catalog),
            child: const Text('Ver la carta'),
          ),
        ),
        AsyncData(value: final orders) => ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            if (ref.watch(isSampleAccountProvider)) ...[
              const SampleDataBanner(
                detail: 'tus pedidos reales llegan en la Fase 5',
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            for (final order in orders)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: OrderTile(order: order),
              ),
          ],
        ),
        AsyncError(:final error) => ErrorView(
          message: loadErrorMessage(error),
          onRetry: () => ref.invalidate(myOrdersProvider),
        ),
        _ => const LoadingView(),
      };
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Pedidos')),
      body: body,
    );
  }
}
