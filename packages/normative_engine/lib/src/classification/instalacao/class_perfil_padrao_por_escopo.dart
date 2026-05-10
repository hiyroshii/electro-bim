// REV: 1.0.0
// CHANGELOG:
// [1.0.0] - 2026-05
// - ADD: ClassPerfilPadraoPorEscopo — C-1 (Fase 2).

import '../../domain/instalacao/escopo_projeto.dart';
import '../../domain/instalacao/perfil_instalacao.dart';

/// Retorna o [PerfilInstalacao] padrão para um dado [EscopoProjeto].
///
/// Usado quando não há classificação detalhada de influências externas —
/// aplica o perfil conservador mínimo para o escopo.
///
/// Rastreabilidade: ARCHITECTURE.md — C-1.
final class ClassPerfilPadraoPorEscopo {
  const ClassPerfilPadraoPorEscopo();

  /// Resolve o perfil padrão para [escopo].
  PerfilInstalacao resolver(final EscopoProjeto escopo) => switch (escopo) {
        EscopoProjeto.residencial => PerfilInstalacao.residencial,
        EscopoProjeto.comercial =>
          const PerfilInstalacao(escopo: EscopoProjeto.comercial),
        EscopoProjeto.industrial =>
          const PerfilInstalacao(escopo: EscopoProjeto.industrial),
      };
}
