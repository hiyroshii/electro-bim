// REV: 1.0.0
// CHANGELOG:
// [1.0.0] - 2026-04
// - ADD: criação do model FatoresCorrecao.

/// Fatores de correção de ampacidade resolvidos pelo [ProcedureService].
///
/// Imutável — calculado uma vez por contexto de entrada.
/// Rastreabilidade: NBR 5410:2004 — 6.2.5.3 (FCT) e 6.2.5.5 (FCA).
final class FatoresCorrecao {
  /// Fator de correção de temperatura.
  /// Derivado da Tabela 40 para a isolação e temperatura informadas.
  /// Referência ar: 30 °C | Referência solo (Método D): 20 °C.
  /// Rastreabilidade: NBR 5410:2004 — Tabela 40.
  final double fct;

  /// Fator de correção de agrupamento.
  /// Derivado das Tabelas 42–45 para o método e número de circuitos.
  /// Rastreabilidade: NBR 5410:2004 — Tabelas 42–45.
  final double fca;

  /// Fator combinado: FCT × FCA.
  /// Aplicado sobre Iz base para obter Iz corrigida.
  /// Rastreabilidade: NBR 5410:2004 — 6.2.5.2.1.
  double get combinado => fct * fca;

  const FatoresCorrecao({
    required this.fct,
    required this.fca,
  });

  /// Fatores sem correção — temperatura de referência, agrupamento unitário.
  const FatoresCorrecao.referencia()
      : fct = 1.0,
        fca = 1.0;

  @override
  String toString() =>
      'FatoresCorrecao(fct: $fct, fca: $fca, combinado: ${combinado.toStringAsFixed(4)})';
}
