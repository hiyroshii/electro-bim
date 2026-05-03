// REV: 1.0.1
// CHANGELOG:
// [1.0.1] - 2026-05
// - FIX: construtor movido antes dos campos em ResultadoSelecao.
// [1.0.0] - 2026-04
// - ADD: scaffold de ResultadoSelecao.

/// Status do dimensionamento do circuito.
enum StatusDimensionamento {
  aprovado,
  reprovadoDisjuntor,
  reprovadoAmpacidade,
  reprovadoQueda,
}

/// Resultado da iteração do [SelecionadorCondutor].
///
/// Registra dois momentos:
/// - **Teórico:** primeira seção que atende só ampacidade (Iz ≥ In).
/// - **Final:** primeira seção que atende ampacidade E queda (ΔV ≤ limite).
final class ResultadoSelecao {
  const ResultadoSelecao({
    required this.secaoTeorica,
    required this.izTeorico,
    required this.quedaTeorica,
    required this.secaoFinal,
    required this.izFinal,
    required this.quedaFinal,
    required this.status,
  });

  factory ResultadoSelecao.reprovadoAmpacidade() => const ResultadoSelecao(
        secaoTeorica: 0,
        izTeorico: 0,
        quedaTeorica: 0,
        secaoFinal: 0,
        izFinal: 0,
        quedaFinal: 0,
        status: StatusDimensionamento.reprovadoAmpacidade,
      );

  factory ResultadoSelecao.reprovadoQueda({
    required double secaoTeorica,
    required double izTeorico,
    required double quedaTeorica,
    required double secaoMaior,
    required double izMaior,
    required double quedaMaior,
  }) =>
      ResultadoSelecao(
        secaoTeorica: secaoTeorica,
        izTeorico: izTeorico,
        quedaTeorica: quedaTeorica,
        secaoFinal: secaoMaior,
        izFinal: izMaior,
        quedaFinal: quedaMaior,
        status: StatusDimensionamento.reprovadoQueda,
      );

  final double secaoTeorica;
  final double izTeorico;
  final double quedaTeorica;
  final double secaoFinal;
  final double izFinal;
  final double quedaFinal;
  final StatusDimensionamento status;
}
