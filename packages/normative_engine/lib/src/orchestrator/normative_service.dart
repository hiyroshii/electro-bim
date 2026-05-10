// REV: 2.0.0
// CHANGELOG:
// [2.0.0] - 2026-05
// - CHG: ContextoInstalacao substituído por PerfilInstalacao (Fase 2).
// - CHG: imports atualizados para nova estrutura de subpastas.
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
import '../domain/instalacao/perfil_instalacao.dart';
import '../specification/instalacao/spec_queda_tensao.dart';
import '../procedure/condutor/proc_ampacidade.dart';
import '../procedure/condutor/proc_secao_neutro.dart';
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
/// Rastreabilidade: ARCHITECTURE.md — Seção 4.
final class NormativeService implements NormativeEngine {

  NormativeService({
    required final OrigemAlimentacao origemAlimentacao,
    required final PerfilInstalacao perfil,
  })  : _specification = SpecificationService(
          origemAlimentacao: origemAlimentacao,
          perfil: perfil,
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
