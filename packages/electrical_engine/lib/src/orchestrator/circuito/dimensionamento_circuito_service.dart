// REV: 1.2.0
// CHANGELOG:
// [1.2.0] - 2026-05
// - ADD: calcularSecaoNeutro() via NormativeEngine após seleção do condutor (ciclo 4.1).
// [1.1.0] - 2026-05
// - CHG: ContextoSelecao passa tabelaXi de DadosNormativos — remove reatanciaXi fixo.
// [1.0.1] - 2026-04
// - ADD: implementação completa de processar() — fluxo normativa → cálculo → seleção → relatório.
// [1.0.0] - 2026-04
// - ADD: scaffold de DimensionamentoCircuitoService.

import 'package:normative_engine/normative_engine.dart';

import '../../calculos/calc_corrente_projeto.dart';
import '../../models/circuito/contexto_selecao.dart';
import '../../models/circuito/entrada_dimensionamento.dart';
import '../../models/circuito/relatorio_dimensionamento.dart';
import '../../models/circuito/resultado_selecao.dart';
import 'politica_disjuntor.dart';
import 'selecionador_condutor.dart';

/// Orquestra o dimensionamento de um único circuito elétrico.
///
/// Fluxo:
///   1. Converte entrada → [EntradaNormativa].
///   2. [NormativeEngine.verificarConformidade] — lança [EntradaInvalidaException] se inválido.
///   3. Calcula Ib via [CalcCorrenteProjeto].
///   4. Seleciona disjuntor (In) via [PoliticaDisjuntor].
///      → [StateError]: retorna REPROVADO_DISJUNTOR sem propagar exceção.
///   5. [NormativeEngine.resolverDadosNormativos] — tabelas, FCT, FCA, limites.
///   6. Monta [ContextoSelecao].
///   7. [SelecionadorCondutor.selecionar] — itera tabela, encontra seção ótima.
///   8. Monta e retorna [RelatorioDimensionamento].
final class DimensionamentoCircuitoService {
  final NormativeEngine _normative;
  final PoliticaDisjuntor _disjuntor;
  final SelecionadorCondutor _selecionador;
  final List<Disjuntor> _catalogoDisjuntores;

  const DimensionamentoCircuitoService({
    required NormativeEngine normative,
    required List<Disjuntor> catalogoDisjuntores,
    PoliticaDisjuntor disjuntor = const PoliticaDisjuntor(),
    SelecionadorCondutor selecionador = const SelecionadorCondutor(),
  })  : _normative = normative,
        _catalogoDisjuntores = catalogoDisjuntores,
        _disjuntor = disjuntor,
        _selecionador = selecionador;

  /// Dimensiona o circuito e retorna o relatório completo.
  ///
  /// Lança [EntradaInvalidaException] se a entrada não passar na
  /// verificação normativa pré-cálculo.
  /// Demais falhas (disjuntor, ampacidade, queda) chegam via status
  /// do [RelatorioDimensionamento] — sem exceção propagada.
  RelatorioDimensionamento processar(EntradaDimensionamento entrada) {
    // ── 1. Validação normativa pré-cálculo ──────────────────────────────────
    final entradaNormativa = entrada.toEntradaNormativa();
    final violacoes = _normative.verificarConformidade(entradaNormativa);
    if (violacoes.isNotEmpty) throw EntradaInvalidaException(violacoes);

    // ── 2. Corrente de projeto ───────────────────────────────────────────────
    final ib = CalcCorrenteProjeto.calcular(
      potenciaVA: entrada.potenciaVA,
      tensaoV: entrada.tensao.valor.toDouble(),
      fatorPotencia: entrada.fatorPotencia,
      isTrifasico: entrada.numeroFases.isTrifasico,
    );

    // ── 3. Seleção do disjuntor ──────────────────────────────────────────────
    // Obtemos os dados normativos antes do disjuntor para ter os fatores
    // disponíveis mesmo no caso de reprovação.
    final dados = _normative.resolverDadosNormativos(
      entradaNormativa,
      entrada.paramsAgrupamento,
    );

    double inDisjuntor;
    try {
      inDisjuntor = _disjuntor.selecionar(
        ib: ib,
        catalogo: _catalogoDisjuntores,
      );
    } on StateError {
      return _montarRelatorio(
        entrada: entrada,
        ib: ib,
        inDisjuntor: 0,
        dados: dados,
        selecao: ResultadoSelecao.reprovadoAmpacidade(),
        secaoNeutro: 0.0,
        status: StatusDimensionamento.reprovadoDisjuntor,
      );
    }

    // ── 4. Contexto de seleção ───────────────────────────────────────────────
    final ctx = ContextoSelecao(
      material: entrada.material,
      isolacao: entrada.isolacao,
      arquitetura: entrada.arquitetura,
      metodoInstalacao: entrada.metodo,
      arranjo: entrada.arranjo,
      numeroFases: entrada.numeroFases,
      condutoresAtivos: entrada.condutoresAtivos,
      ib: ib,
      inDisjuntor: inDisjuntor,
      secaoMinima: dados.secaoMinimaNormativa,
      limiteQueda: dados.queda.limitePercent,
      fatores: dados.fatores,
      tabelaIz: dados.tabelaIz,
      tabelaXi: dados.tabelaXi,
      tensao: entrada.tensao.valor.toDouble(),
      distancia: entrada.distancia,
      fatorPotencia: entrada.fatorPotencia,
      fatorHarmonico: dados.queda.fatorHarmonico,
    );

    // ── 5. Seleção do condutor ───────────────────────────────────────────────
    final selecao = _selecionador.selecionar(ctx);

    // ── 6. Seção do neutro ───────────────────────────────────────────────────
    final secaoNeutro = _normative.calcularSecaoNeutro(
      selecao.secaoFinal,
      entradaNormativa,
    );

    return _montarRelatorio(
      entrada: entrada,
      ib: ib,
      inDisjuntor: inDisjuntor,
      dados: dados,
      selecao: selecao,
      secaoNeutro: secaoNeutro,
      status: selecao.status,
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────

  RelatorioDimensionamento _montarRelatorio({
    required EntradaDimensionamento entrada,
    required double ib,
    required double inDisjuntor,
    required DadosNormativos dados,
    required ResultadoSelecao selecao,
    required double secaoNeutro,
    required StatusDimensionamento status,
  }) =>
      RelatorioDimensionamento(
        idCircuito: entrada.idCircuito,
        tagCircuito: entrada.tagCircuito,
        material: entrada.material,
        isolacao: entrada.isolacao,
        arquitetura: entrada.arquitetura,
        metodoInstalacao: entrada.metodo,
        ib: ib,
        inDisjuntor: inDisjuntor,
        fatores: dados.fatores,
        selecao: selecao,
        secaoNeutro: secaoNeutro,
        limiteQuedaAplicado: dados.queda.limitePercent,
        status: status,
      );
}

