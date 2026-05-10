// REV: 1.1.0
// CHANGELOG:
// [1.1.0] - 2026-05
// - ADD: calcularSecaoNeutro() — delega para ProcSecaoNeutro.
// [1.0.1] - 2026-04
// - CHG: paramsAgrupamento movido para parâmetro de resolverDadosNormativos().
// [1.0.0] - 2026-04
// - ADD: orquestrador mestre do normative_engine.

import '../contracts/normative_engine.dart';
import '../models/violacao.dart';
import '../models/dados_normativos.dart';
import '../models/entrada_normativa.dart';
import '../models/resultado_normativo.dart';
import '../specification/spec_aluminio.dart';
import '../specification/spec_queda_tensao.dart';
import '../procedure/proc_ampacidade.dart';
import '../procedure/proc_secao_neutro.dart';
import 'specification_service.dart';
import 'procedure_service.dart';

/// Orquestrador mestre do normative_engine.
///
/// Implementa [NormativeEngine] — ponto único de entrada para o
/// [dimensionamento_engine].
///
/// Não contém lógica normativa — delega para [SpecificationService]
/// e [ProcedureService].
///
/// Fluxo:
///   1. [verificarConformidade] → specs pré-cálculo.
///   2. [resolverDadosNormativos] → tabelas e fatores para o cálculo.
///   3. [auditar] → specs pós-cálculo sobre o relatório.
///
/// Rastreabilidade: ARCHITECTURE.md — Seção 6.1.
final class NormativeService implements NormativeEngine {

  NormativeService({
    required final OrigemAlimentacao origemAlimentacao,
    required final ContextoInstalacao contextoInstalacao,
  })  : _specification = SpecificationService(
          origemAlimentacao: origemAlimentacao,
          contextoInstalacao: contextoInstalacao,
        ),
        _procedure = ProcedureService(
          origemAlimentacao: origemAlimentacao,
        );
  final SpecificationService _specification;
  final ProcedureService _procedure;

  @override
  List<Violacao> verificarConformidade(final EntradaNormativa entrada) =>
      _specification.verificarConformidade(entrada);

  @override
  DadosNormativos resolverDadosNormativos(
    final EntradaNormativa entrada,
    final ParamsAgrupamento paramsAgrupamento,
  ) =>
      _procedure.resolver(entrada, paramsAgrupamento);

  @override
  List<Violacao> auditar(
    final EntradaNormativa entrada,
    final ResultadoNormativo resultado,
  ) =>
      _specification.auditar(entrada, resultado);

  @override
  double calcularSecaoNeutro(final double secaoFase, final EntradaNormativa entrada) =>
      const ProcSecaoNeutro().resolver(
        (secaoFase, entrada.numeroFases, entrada.harmonicasAcima15pct),
      );
}
