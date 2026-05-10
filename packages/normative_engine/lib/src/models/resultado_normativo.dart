// REV: 1.1.0
// CHANGELOG:
// [1.1.0] - 2026-05
// - ADD: ib, inDisjuntor, izFinal — necessários para S-3 (spec_sobrecarga).
// [1.0.1] - 2026-05
// - FIX: construtor movido antes dos campos.
// [1.0.0] - 2026-04
// - ADD: criação de ResultadoNormativo.

/// Dados do relatório para auditoria normativa.
/// Criado pelo [dimensionamento_engine] antes de chamar [NormativeEngine.auditar].
final class ResultadoNormativo {
  const ResultadoNormativo({
    required this.ib,
    required this.inDisjuntor,
    required this.izFinal,
    required this.secaoFase,
    required this.secaoNeutro,
    required this.quedaPercent,
  });

  final double ib;
  final double inDisjuntor;
  final double izFinal;
  final double secaoFase;
  final double secaoNeutro;
  final double quedaPercent;
}
