import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fornea/features/loyalty/data/loyalty_repository.dart';
import 'package:fornea/features/loyalty/domain/loyalty_program.dart';

/// Regla de puntos y recompensas reales del local (público, sin sesión).
final loyaltyProgramProvider = FutureProvider<LoyaltyProgram>(
  (ref) => ref.watch(loyaltyRepositoryProvider).fetchProgram(),
);
