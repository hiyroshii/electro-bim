// REV: 1.0.2
// CHANGELOG:
// [1.0.2] - 2026-05
// - FIX: construtor movido antes dos campos.
// [1.0.1] - 2026-04
// - CHG: comentário corrigido — alimentador 1%/3%, terminal 4%.
// [1.0.0] - 2026-04
// - ADD: criação do model ParametrosQueda.

/// Parâmetros normativos de queda de tensão.
/// Rastreabilidade: NBR 5410:2004 — 6.2.5.6, 6.2.7.
final class ParametrosQueda {
  const ParametrosQueda({
    required this.limitePercent,
    required this.condutoresCarregados,
    required this.fatorHarmonico,
  });

  /// Terminal (TUG, TUE, IL): 4% fixo.
  /// Alimentador via concessionária: 1% (total 5%).
  /// Alimentador via trafo/gerador próprio: 3% (total 7%).
  final double limitePercent;

  /// Número de condutores carregados para o cálculo de ΔV.
  /// Rastreabilidade: NBR 5410:2004 — Tabela 46, 6.2.5.6.1.
  final int condutoresCarregados;

  /// 0,86 se harm 3ª > 15% em trifásico com neutro, 1,0 caso contrário.
  /// Rastreabilidade: NBR 5410:2004 — 6.2.5.6.1.
  final double fatorHarmonico;

  bool get temCorrecaoHarmonica => fatorHarmonico < 1.0;

  @override
  String toString() => 'ParametrosQueda('
      'limite: $limitePercent%, '
      'condutores: $condutoresCarregados, '
      'fatorHarmonico: $fatorHarmonico)';
}
