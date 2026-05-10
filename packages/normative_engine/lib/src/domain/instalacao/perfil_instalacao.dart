// REV: 1.0.0
// CHANGELOG:
// [1.0.0] - 2026-05
// - ADD: VO PerfilInstalacao — agrega EscopoProjeto + influências externas.

import 'escopo_projeto.dart';
import '../influencias/codigo_influencia.dart';

export '../influencias/codigo_influencia.dart';

/// Perfil normativo de uma instalação elétrica.
///
/// Value Object imutável que agrega o escopo do projeto e as influências
/// externas classificadas. Usado pelos [ISpecification] via [aplicavelA]
/// para determinar se uma regra se aplica ao contexto.
///
/// Substitui [ContextoInstalacao] — mais expressivo e extensível.
///
/// Rastreabilidade: ARCHITECTURE.md — Seção 2 (contratos Fase 2).
final class PerfilInstalacao {
  const PerfilInstalacao({
    required this.escopo,
    this.influencias = const {},
  });

  final EscopoProjeto escopo;

  /// Influências externas classificadas para esta instalação.
  final Set<CodigoInfluencia> influencias;

  /// Retorna true se a influência [codigo] está presente neste perfil.
  bool possuiInfluencia(final CodigoInfluencia codigo) =>
      influencias.contains(codigo);

  /// Perfil padrão residencial — sem influências especiais.
  static const residencial = PerfilInstalacao(
    escopo: EscopoProjeto.residencial,
  );
}
