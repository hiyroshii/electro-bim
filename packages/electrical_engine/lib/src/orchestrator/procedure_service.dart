// REV: 1.0.1
// CHANGELOG:
// [1.0.1] - 2026-04
// - CHG: paramsAgrupamento movido para parâmetro de resolver() — era por instância.
// [1.0.0] - 2026-04
// - ADD: sub-orquestrador de procedimento normativo.

import '../models/entrada_normativa.dart';
import '../models/dados_normativos.dart';
import '../models/parametros_queda.dart';
import '../specification/spec_queda_tensao.dart';
import '../procedure/proc_ampacidade.dart';
import '../procedure/proc_queda_tensao.dart';
import '../tables/tabela_47_48_secao_minima_neutro.dart';

/// Sub-orquestrador de procedimento normativo.
///
/// Consulta [ProcAmpacidade] e [ProcQuedaTensao] e monta [DadosNormativos].
/// Não contém lógica normativa — só coordena e agrega.
///
/// Rastreabilidade: ARCHITECTURE.md — Seção 6.3.
final class ProcedureService {
  final OrigemAlimentacao origemAlimentacao;

  const ProcedureService({required this.origemAlimentacao});

  /// Resolve todos os dados normativos para o contexto da entrada.
  ///
  /// [paramsAgrupamento] é por chamada — varia por circuito.
  DadosNormativos resolver(
    EntradaNormativa entrada,
    ParamsAgrupamento paramsAgrupamento,
  ) {
    final resultadoAmpacidade = const ProcAmpacidade().resolver(
      (entrada, paramsAgrupamento),
    );

    final parametrosQueda = const ProcQuedaTensao().resolver(
      (entrada, origemAlimentacao),
    );

    final secaoMinima =
        tabelaSecaoMinima[(entrada.tagCircuito, entrada.material)] ?? 0.0;

    return DadosNormativos(
      fatores: resultadoAmpacidade.fatores,
      tabelaIz: resultadoAmpacidade.tabelaIz,
      queda: parametrosQueda,
      secaoMinimaNormativa: secaoMinima,
    );
  }
}
