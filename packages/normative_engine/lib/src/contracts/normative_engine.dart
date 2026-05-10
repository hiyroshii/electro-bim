// REV: 2.0.0
// CHANGELOG:
// [2.0.0] - 2026-05
// - CHG: imports atualizados para nova estrutura (Fase 2); PerfilInstalacao visível via barrel.
// [1.1.0] - 2026-05
// - ADD: calcularSecaoNeutro() — cálculo real do neutro conforme 6.2.6.2.
// [1.0.1] - 2026-04
// - CHG: resolverDadosNormativos recebe ParamsAgrupamento por chamada.
// [1.0.0] - 2026-04
// - ADD: contrato abstrato NormativeEngine.

import '../models/violacao.dart';
import '../models/dados_normativos.dart';
import '../models/entrada_normativa.dart';
import '../models/resultado_normativo.dart';
import '../procedure/condutor/proc_ampacidade.dart';

/// Contrato público do normative_engine.
///
/// Ponto único de acesso para o [dimensionamento_engine].
/// Implementado por [NormativeService].
///
/// Fluxo de uso:
///   1. UI envia entrada ao [ServicoDimensionamento].
///   2. Serviço chama [verificarConformidade] — valida combinações e material.
///   3. Serviço chama [resolverDadosNormativos] — obtém tabelas e fatores.
///   4. Serviço executa os cálculos e monta o [RelatorioDimensionamento].
///   5. UI envia relatório de volta — engine chama [auditar].
///   6. Engine audita o resultado e devolve [List<Violacao>] à UI.
///
/// O consumidor nunca importa specification/, procedure/ ou tables/
/// diretamente — apenas este contrato e os models/enums do barrel.
///
/// Rastreabilidade: ARCHITECTURE.md — Seções 3 e 4.
abstract interface class NormativeEngine {
  List<Violacao> verificarConformidade(final EntradaNormativa entrada);

  DadosNormativos resolverDadosNormativos(
    final EntradaNormativa entrada,
    final ParamsAgrupamento paramsAgrupamento,
  );

  List<Violacao> auditar(final EntradaNormativa entrada, final ResultadoNormativo resultado);

  double calcularSecaoNeutro(final double secaoFase, final EntradaNormativa entrada);
}
