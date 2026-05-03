// REV: 1.0.1
// CHANGELOG:
// [1.0.1] - 2026-05
// - FIX: construtor movido antes dos campos.
// [1.0.0] - 2026-04
// - ADD: criação do model FatoresCorrecao.

/// Fatores de correção de ampacidade.
/// Rastreabilidade: NBR 5410:2004 — 6.2.5.3 (FCT) e 6.2.5.5 (FCA).
final class FatoresCorrecao {
  const FatoresCorrecao({
    required this.fct,
    required this.fca,
  });

  const FatoresCorrecao.referencia()
      : fct = 1.0,
        fca = 1.0;

  /// Fator de correção de temperatura (Tabela 40).
  final double fct;

  /// Fator de correção de agrupamento (Tabelas 42–45).
  final double fca;

  /// FCT × FCA — aplica sobre Iz base para obter Iz corrigida.
  double get combinado => fct * fca;

  @override
  String toString() =>
      'FatoresCorrecao(fct: $fct, fca: $fca, combinado: ${combinado.toStringAsFixed(4)})';
}
