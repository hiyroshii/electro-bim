// REV: 1.0.0
// CHANGELOG:
// [1.0.0] - 2026-04
// - ADD: criação do model DadosNormativos.

import 'fatores_correcao.dart';
import 'linha_ampacidade.dart';
import 'parametros_queda.dart';

/// Agregado de dados normativos resolvidos pelo [ProcedureService].
///
/// Retornado pelo [NormativeEngine.resolverDadosNormativos] e consumido
/// diretamente pelo [dimensionamento_engine] — sem que o engine de
/// dimensionamento precise conhecer nenhuma tabela ou regra normativa.
///
/// Rastreabilidade: NBR 5410:2004 — 6.2.5 e 6.2.7.
final class DadosNormativos {
  /// Fatores de correção combinados (FCT × FCA).
  /// Rastreabilidade: NBR 5410:2004 — Tabelas 40–45.
  final FatoresCorrecao fatores;

  /// Linhas de ampacidade base disponíveis para o contexto.
  /// Ordenadas por seção crescente — prontas para iteração do selecionador.
  /// Rastreabilidade: NBR 5410:2004 — Tabelas 36–39.
  final List<LinhaAmpacidade> tabelaIz;

  /// Parâmetros normativos de queda de tensão.
  /// Rastreabilidade: NBR 5410:2004 — 6.2.5.6, 6.2.7.
  final ParametrosQueda queda;

  /// Seção mínima normativa para o circuito (mm²).
  /// Derivada da Tabela 47 — piso que o selecionador não pode violar.
  /// Rastreabilidade: NBR 5410:2004 — Tabela 47.
  final double secaoMinimaNormativa;

  const DadosNormativos({
    required this.fatores,
    required this.tabelaIz,
    required this.queda,
    required this.secaoMinimaNormativa,
  });

  @override
  String toString() => 'DadosNormativos('
      'fct: ${fatores.fct}, '
      'fca: ${fatores.fca}, '
      'linhas: ${tabelaIz.length}, '
      'limiteQueda: ${queda.limitePercent}%, '
      'secaoMin: $secaoMinimaNormativa mm²)';
}
