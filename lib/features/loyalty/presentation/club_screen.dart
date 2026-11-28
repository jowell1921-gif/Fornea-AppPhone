import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fornea/core/formatting/money.dart';
import 'package:fornea/core/motion/scroll_reveal.dart';
import 'package:fornea/core/network/error_messages.dart';
import 'package:fornea/core/theme/app_colors.dart';
import 'package:fornea/core/theme/app_spacing.dart';
import 'package:fornea/core/widgets/section_heading.dart';
import 'package:fornea/features/loyalty/domain/loyalty_program.dart';
import 'package:fornea/features/loyalty/domain/points_text.dart';
import 'package:fornea/features/loyalty/presentation/loyalty_providers.dart';
import 'package:material_ui/material_ui.dart';

/// FORNEA CLUB: cómo funciona, recompensas reales y preguntas frecuentes (textos de la web).
class ClubScreen extends ConsumerWidget {
  const ClubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final program = ref.watch(loyaltyProgramProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.charcoal,
        foregroundColor: AppColors.cream,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: ListView(
        children: [
          _Intro(program: program),
          const Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: _Steps(),
          ),
          ColoredBox(
            color: AppColors.creamSoft,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: _Rewards(
                program: program,
                onRetry: () => ref.invalidate(loyaltyProgramProvider),
              ),
            ),
          ),
          const Padding(padding: EdgeInsets.all(AppSpacing.md), child: _Faq()),
        ],
      ),
    );
  }
}

class _Intro extends StatelessWidget {
  const _Intro({required this.program});

  final AsyncValue<LoyaltyProgram> program;

  @override
  Widget build(BuildContext context) {
    // Como en la web: con la regla del local si ya ha llegado; si no, el texto genérico.
    final description = switch (program) {
      AsyncData(:final value) =>
        'Por cada euro de tus pedidos sumas '
            '${pointsRuleText(value.pointsPerEuro).replaceFirst(' por cada euro', '')} '
            '(configurable por el local).',
      _ => 'Suma puntos en cada pedido y canjéalos por recompensas.',
    };

    return ColoredBox(
      color: AppColors.charcoal,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.xl,
        ),
        child: SectionHeading(
          eyebrow: 'Fidelización',
          title: 'FORNEA CLUB',
          description: description,
          onDark: true,
        ),
      ),
    );
  }
}

class _Steps extends StatelessWidget {
  const _Steps();

  static const _steps = [
    (
      icon: Icons.shopping_bag_outlined,
      title: 'Pide',
      text: 'Haz tus pedidos con tu cuenta, para recoger o a domicilio.',
    ),
    (
      icon: Icons.star_outline,
      title: 'Suma',
      text: 'Recibes puntos cuando el pedido se completa.',
    ),
    (
      icon: Icons.card_giftcard,
      title: 'Canjea',
      text: 'Cambia tus puntos por las recompensas disponibles.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeading(title: 'Cómo funciona'),
        const SizedBox(height: AppSpacing.md),
        for (final (index, step) in _steps.indexed)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: ScrollReveal(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(step.icon, color: AppColors.tomatoStrong, size: 28),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${index + 1}. ${step.title}',
                              style: theme.textTheme.titleLarge,
                            ),
                            Text(
                              step.text,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _Rewards extends StatelessWidget {
  const _Rewards({required this.program, required this.onRetry});

  final AsyncValue<LoyaltyProgram> program;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final Widget content = switch (program) {
      AsyncData(value: LoyaltyProgram(rewards: [])) => const Text(
        'Ahora mismo no hay recompensas disponibles.',
      ),
      AsyncData(:final value) => Column(
        children: [
          for (final reward in value.rewards)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: ScrollReveal(child: _RewardCard(reward: reward)),
            ),
        ],
      ),
      AsyncError(:final error) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(loadErrorMessage(error)),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
      _ => const Center(
        child: CircularProgressIndicator(semanticsLabel: 'Cargando'),
      ),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeading(
          title: 'Recompensas',
          description: 'Canjea tus puntos desde «Tu cuenta» y úsalas en tu próximo pedido.',
        ),
        const SizedBox(height: AppSpacing.md),
        content,
      ],
    );
  }
}

class _RewardCard extends StatelessWidget {
  const _RewardCard({required this.reward});

  final Reward reward;

  String? get _benefit => switch (reward.benefit) {
    RewardBenefit(type: BenefitType.freeProduct, :final productName?) =>
      'Producto gratis: $productName',
    RewardBenefit(type: BenefitType.discount, :final amount?) =>
      'Descuento de ${formatEuro(amount)}',
    _ => null,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final description = reward.description;
    final benefit = _benefit;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(reward.name, style: theme.textTheme.titleLarge),
                  if (description != null) Text(description, style: muted),
                  if (benefit != null) Text(benefit, style: muted),
                  if (!reward.inStock)
                    Text(
                      'Agotada de momento',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              pointsText(reward.pointsCost),
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppColors.tomatoDeep,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Faq extends StatelessWidget {
  const _Faq();

  static const _questions = [
    (
      question: '¿Cuándo recibo los puntos?',
      answer:
          'Cuando el pedido pasa al estado completado. Si se cancela o se devuelve, se '
          'retiran los puntos que habías ganado (sin dejar tu saldo en negativo) y se te '
          'devuelven los que gastaste en una recompensa.',
    ),
    (
      question: '¿Todo el importe suma puntos?',
      answer:
          'Suman los productos de tu pedido una vez descontadas las promociones y las '
          'recompensas que hayas usado. Los gastos de envío no suman puntos. La conversión '
          'de euros a puntos la configura el local.',
    ),
    (
      question: '¿Los puntos caducan?',
      answer:
          'Depende de la configuración del local. Si hay caducidad, se indicará en tu '
          'historial de puntos.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeading(title: 'Preguntas frecuentes'),
        const SizedBox(height: AppSpacing.sm),
        for (final item in _questions)
          ExpansionTile(
            title: Text(
              item.question,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            tilePadding: EdgeInsets.zero,
            childrenPadding: const EdgeInsets.only(bottom: AppSpacing.md),
            expandedAlignment: Alignment.centerLeft,
            shape: const Border(),
            children: [Text(item.answer)],
          ),
      ],
    );
  }
}
