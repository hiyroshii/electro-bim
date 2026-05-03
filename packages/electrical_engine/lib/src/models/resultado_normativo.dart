// REV: 1.0.0
// CHANGELOG:
// [1.0.0] - 2026-04
// - ADD: criação de ResultadoNormativo — dados do relatório para auditoria.

/// Dados do relatório de dimensionamento necessários para auditoria normativa.
///
/// Criado pelo [dimensionamento_engine] a partir do [RelatorioDimensionamento]
/// antes de chamar [NormativeEngine.auditar].
///
/// Contém apenas os campos que as specs pós-cálculo precisam verificar.
final class ResultadoNormativo {
  /// Seção calculada dos condutores de fase (mm²).
  final double secaoFase;

  /// Seção calculada do condutor neutro (mm²).
  final double secaoNeutro;

  /// Queda de tensão calculada (%).
  final double quedaPercent;

  const ResultadoNormativo({
    required this.secaoFase,
    required this.secaoNeutro,
    required this.quedaPercent,
  });
}
