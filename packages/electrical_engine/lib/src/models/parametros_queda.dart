// REV: 1.0.1
// CHANGELOG:
// [1.0.1] - 2026-04
// - CHG: comentário de limitePercent corrigido — alimentador 1%, terminal 4%, total 5%.
// [1.0.0] - 2026-04
// - ADD: criação do model ParametrosQueda.

/// Parâmetros normativos para o cálculo de queda de tensão.
///
/// Resolvido pelo [ProcedureService] para o contexto da entrada.
/// Consumido diretamente pelo cálculo de ΔV no [dimensionamento_engine].
///
/// Rastreabilidade: NBR 5410:2004 — 6.2.5.6, 6.2.7.
final class ParametrosQueda {
  /// Limite normativo de queda de tensão (%).
  /// Terminal (TUG, TUE, IL): 4% fixo.
  /// Alimentador via concessionária (MED, QDG, QD): 1% (total 5%).
  /// Alimentador via trafo/gerador próprio (MED, QDG, QD): 3% (total 7%).
  /// Rastreabilidade: NBR 5410:2004 — 6.2.7.1 e 6.2.7.2.
  final double limitePercent;

  /// Número de condutores carregados para o cálculo de ΔV.
  /// Derivado do esquema de fases e da presença de harmônicas.
  /// Rastreabilidade: NBR 5410:2004 — Tabela 46, 6.2.5.6.1.
  final int condutoresCarregados;

  /// Fator aplicado à ampacidade quando há 4 condutores carregados.
  /// 0,86 se harmônicas de 3ª ordem > 15% em circuito trifásico com neutro.
  /// 1,0 nos demais casos.
  /// Rastreabilidade: NBR 5410:2004 — 6.2.5.6.1.
  final double fatorHarmonico;

  const ParametrosQueda({
    required this.limitePercent,
    required this.condutoresCarregados,
    required this.fatorHarmonico,
  });

  /// Indica se há correção harmônica ativa (4 condutores carregados).
  bool get temCorrecaoHarmonica => fatorHarmonico < 1.0;

  @override
  String toString() => 'ParametrosQueda('
      'limite: $limitePercent%, '
      'condutores: $condutoresCarregados, '
      'fatorHarmonico: $fatorHarmonico)';
}
