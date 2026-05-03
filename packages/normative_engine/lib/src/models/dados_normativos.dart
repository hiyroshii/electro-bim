// REV: 1.0.1
// CHANGELOG:
// [1.0.1] - 2026-05
// - FIX: construtor movido antes dos campos.
// [1.0.0] - 2026-04
// - ADD: criação do model DadosNormativos.

import 'fatores_correcao.dart';
import 'linha_ampacidade.dart';
import 'parametros_queda.dart';

/// Agregado de dados normativos para o [dimensionamento_engine].
/// Rastreabilidade: NBR 5410:2004 — 6.2.5 e 6.2.7.
final class DadosNormativos {
  const DadosNormativos({
    required this.fatores,
    required this.tabelaIz,
    required this.queda,
    required this.secaoMinimaNormativa,
  });

  final FatoresCorrecao fatores;
  final List<LinhaAmpacidade> tabelaIz;
  final ParametrosQueda queda;
  final double secaoMinimaNormativa;

  @override
  String toString() => 'DadosNormativos('
      'fct: ${fatores.fct}, fca: ${fatores.fca}, '
      'linhas: ${tabelaIz.length}, '
      'limiteQueda: ${queda.limitePercent}%, '
      'secaoMin: $secaoMinimaNormativa mm²)';
}
