// REV: 1.0.1
// CHANGELOG:
// [1.0.1] - 2026-04
// - ADD: implementação completa de criarComodoComSugestoes, criarComodoCustom e processar.
// [1.0.0] - 2026-04
// - ADD: scaffold de DimensionamentoCargaService.

import 'package:uuid/uuid.dart';

import '../../models/carga/comodo.dart';
import '../../models/carga/entrada_carga.dart';
import '../../models/carga/relatorio_carga.dart';
import 'gerador_pontos_comodo.dart';
import 'validador_comodo.dart';
import 'agregador_circuitos.dart';

/// Orquestra o dimensionamento de cargas do projeto.
///
/// Responsabilidades:
/// - Criar cômodos com pontos sugeridos pela norma.
/// - Criar cômodos com regra definida pelo usuário.
/// - Processar o projeto inteiro: validar cômodos + agregar circuitos.
///
/// Não faz cálculos — delega para [GeradorPontosComodo],
/// [ValidadorComodo] e [AgregadorCircuitos].
final class DimensionamentoCargaService {
  final GeradorPontosComodo _gerador;
  final ValidadorComodo _validador;
  final AgregadorCircuitos _agregador;
  final Uuid _uuid;

  DimensionamentoCargaService({
    GeradorPontosComodo? gerador,
    ValidadorComodo validador = const ValidadorComodo(),
    AgregadorCircuitos agregador = const AgregadorCircuitos(),
    Uuid uuid = const Uuid(),
  })  : _gerador = gerador ?? GeradorPontosComodo(uuid: uuid),
        _validador = validador,
        _agregador = agregador,
        _uuid = uuid;

  // ── Criação de cômodo ────────────────────────────────────────────────────

  /// Cria cômodo com pontos TUG e IL sugeridos automaticamente pela norma.
  Comodo criarComodoComSugestoes({
    required String idTipo,
    required String label,
    required RegraTomadasComodo regraTomadasComodo,
    required double areaM2,
    required double perimetroM,
  }) {
    final comodoBase = Comodo.criar(
      id: _uuid.v4(),
      idTipo: idTipo,
      label: label,
      regraTomadasComodo: regraTomadasComodo,
      areaM2: areaM2,
      perimetroM: perimetroM,
    );

    final pontos = _gerador.gerar(comodoBase);

    return comodoBase.copyWith(
      pontosTug: pontos.tug,
      pontosIl: pontos.il,
    );
  }

  /// Cria cômodo personalizado — pontos definidos pelo usuário.
  Comodo criarComodoCustom({
    required String label,
    required double areaM2,
    required double perimetroM,
    RegraTomadasComodo regraTomadasComodo = RegraTomadasComodo.custom,
  }) =>
      Comodo.criar(
        id: _uuid.v4(),
        idTipo: 'custom',
        label: label,
        regraTomadasComodo: regraTomadasComodo,
        areaM2: areaM2,
        perimetroM: perimetroM,
      );

  // ── Processamento ────────────────────────────────────────────────────────

  /// Processa o projeto inteiro e retorna o [RelatorioCarga].
  ///
  /// - Valida cada cômodo contra os mínimos normativos.
  /// - Agrega todos os pontos por [idCircuito] entre os cômodos.
  /// - Calcula o VA total do projeto (soma simples, sem fator de demanda).
  /// - Status global: [StatusRelatorio.ok] somente se todos aprovados.
  RelatorioCarga processar(EntradaCarga entrada) {
    // 1. Validar cada cômodo
    final previsoes = entrada.comodos
        .map(_validador.validar)
        .toList();

    // 2. Agregar circuitos de todos os cômodos
    final circuitos = _agregador.agregar(entrada.comodos);

    // 3. VA total do projeto
    final vaTotal = previsoes.fold(0.0, (s, p) => s + p.vaTotalComodo);

    // 4. Status global — reprovado se qualquer cômodo ou circuito reprovado
    final comodoReprovado = previsoes.any(
      (p) => p.status == StatusPrevisao.reprovadoNorma,
    );
    final circuitoReprovado = circuitos.any(
      (c) => c.status == StatusCircuito.reprovado,
    );

    final status = (comodoReprovado || circuitoReprovado)
        ? StatusRelatorio.reprovado
        : StatusRelatorio.ok;

    return RelatorioCarga(
      previsoesPorComodo: previsoes,
      circuitos: circuitos,
      vaTotalProjeto: vaTotal,
      status: status,
    );
  }
}
