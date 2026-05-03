// REV: 1.0.1
// CHANGELOG:
// [1.0.1] - 2026-05
// - FIX: construtor movido antes dos campos.
// [1.0.0] - 2026-04
// - ADD: criação do model LinhaAmpacidade.

/// Uma linha da tabela de ampacidade resolvida para o contexto da entrada.
/// Rastreabilidade: NBR 5410:2004 — Tabelas 36–39.
final class LinhaAmpacidade {
  const LinhaAmpacidade({
    required this.secao,
    required this.izBase,
  });

  final double secao;

  /// Ampacidade base (A) — sem fatores de correção.
  final double izBase;

  @override
  String toString() => 'LinhaAmpacidade(secao: $secao mm², izBase: $izBase A)';
}
