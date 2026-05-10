// REV: 1.2.0
// CHANGELOG:
// [1.2.0] - 2026-05
// - FIX: prefer_final_parameters em resolver() e lambdas; remove unused_import.
// [1.1.0] - 2026-05
// - ADD: resolve tabelaXi por material e popula DadosNormativos.tabelaXi.
// [1.0.1] - 2026-04
// - CHG: paramsAgrupamento movido para parâmetro de resolver() — era por instância.
// [1.0.0] - 2026-04
// - ADD: sub-orquestrador de procedimento normativo.

import '../models/entrada_normativa.dart';
import '../models/dados_normativos.dart';
import '../specification/spec_queda_tensao.dart';
import '../procedure/proc_ampacidade.dart';
import '../procedure/proc_queda_tensao.dart';
import '../tables/tabela_47_48_secao_minima_neutro.dart';
import '../tables/tabela_xi_reatancia.dart';

/// Sub-orquestrador de procedimento normativo.
///
/// Consulta [ProcAmpacidade] e [ProcQuedaTensao] e monta [DadosNormativos].
/// Não contém lógica normativa — só coordena e agrega.
///
/// Rastreabilidade: ARCHITECTURE.md — Seção 6.3.
final class ProcedureService {
  const ProcedureService({required this.origemAlimentacao});

  final OrigemAlimentacao origemAlimentacao;

  /// Resolve todos os dados normativos para o contexto da entrada.
  ///
  /// [paramsAgrupamento] é por chamada — varia por circuito.
  DadosNormativos resolver(
    final EntradaNormativa entrada,
    final ParamsAgrupamento paramsAgrupamento,
  ) {
    final resultadoAmpacidade = const ProcAmpacidade().resolver(
      (entrada, paramsAgrupamento),
    );

    final parametrosQueda = const ProcQuedaTensao().resolver(
      (entrada, origemAlimentacao),
    );

    final secaoMinima =
        tabelaSecaoMinima[(entrada.tagCircuito, entrada.material)] ?? 0.0;

    final xiPorSecao = Map<double, double>.fromEntries(
      tabelaXi.entries
          .where((final e) => e.key.$2 == entrada.material)
          .map((final e) => MapEntry(e.key.$1, e.value)),
    );

    return DadosNormativos(
      fatores: resultadoAmpacidade.fatores,
      tabelaIz: resultadoAmpacidade.tabelaIz,
      tabelaXi: xiPorSecao,
      queda: parametrosQueda,
      secaoMinimaNormativa: secaoMinima,
    );
  }
}
