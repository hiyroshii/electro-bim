// REV: 1.1.0
// CHANGELOG:
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
import '../procedure/proc_ampacidade.dart';

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
/// Rastreabilidade: ARCHITECTURE.md — Seções 5 e 6.
abstract interface class NormativeEngine {
  /// Verifica conformidade da entrada antes do cálculo.
  ///
  /// Verifica combinações (iso × arq × método × arranjo × tensão)
  /// e restrições de material (alumínio).
  /// Retorna lista vazia se a entrada for plenamente conforme.
  /// Nunca lança exceção.
  ///
  /// O [ServicoDimensionamento] deve abortar se a lista não estiver vazia.
  List<Violacao> verificarConformidade(final EntradaNormativa entrada);

  /// Resolve todos os dados normativos necessários para o cálculo.
  ///
  /// [paramsAgrupamento] é por chamada — varia por circuito.
  /// Pré-condição: [verificarConformidade] retornou lista vazia.
  /// Retorna tabelas, fatores FCT/FCA, limites de queda e seção mínima.
  ///
  /// Rastreabilidade: ARCHITECTURE.md — Seção 5.2.
  DadosNormativos resolverDadosNormativos(
    final EntradaNormativa entrada,
    final ParamsAgrupamento paramsAgrupamento,
  );

  /// Audita o resultado do dimensionamento após o cálculo.
  ///
  /// Recebe o relatório já calculado pelo [ServicoDimensionamento]
  /// e verifica seção mínima, neutro e queda de tensão.
  /// Retorna lista vazia se o resultado for plenamente conforme.
  /// Nunca lança exceção.
  List<Violacao> auditar(final EntradaNormativa entrada, final ResultadoNormativo resultado);

  /// Calcula a seção mínima do condutor neutro após a seleção do condutor de fase.
  ///
  /// Aplica as regras de 6.2.6.2 conforme fase e harmônicas.
  /// Deve ser chamado com [secaoFase] já determinada pelo [SelecionadorCondutor].
  /// Nunca lança exceção.
  ///
  /// Rastreabilidade: NBR 5410:2004 — 6.2.6.2.
  double calcularSecaoNeutro(final double secaoFase, final EntradaNormativa entrada);
}
