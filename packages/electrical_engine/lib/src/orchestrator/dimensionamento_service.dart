// REV: 1.0.1
// CHANGELOG:
// [1.0.1] - 2026-04
// - CHG: removidos imports não usados (gerador, validador, agregador, selecionador).
// - CHG: removidos parâmetros origemAlimentacao e contextoInstalacao do construtor
//        — são responsabilidade da EntradaDimensionamento por circuito.
// [1.0.0] - 2026-04
// - ADD: scaffold do orquestrador mestre do electrical_engine.

import 'package:normative_engine/normative_engine.dart';

import 'dimensionamento_engine.dart';
import 'carga/dimensionamento_carga_service.dart';
import 'circuito/dimensionamento_circuito_service.dart';
import 'circuito/politica_disjuntor.dart';
import '../models/carga/comodo.dart';
import '../models/carga/entrada_carga.dart';
import '../models/carga/relatorio_carga.dart';
import '../models/circuito/entrada_dimensionamento.dart';
import '../models/circuito/relatorio_dimensionamento.dart';

/// Orquestrador mestre do electrical_engine.
///
/// Implementa [DimensionamentoEngine] — ponto único de entrada para o app.
/// Instancia e coordena [DimensionamentoCargaService] e
/// [DimensionamentoCircuitoService].
///
/// O app instancia este serviço passando o [NormativeEngine] (via injeção)
/// e o catálogo de disjuntores (asset do app — lista de produto, não norma).
///
/// Contexto normativo ([OrigemAlimentacao], [ContextoInstalacao]) é definido
/// por circuito em [EntradaDimensionamento] — cada circuito pode ter contexto
/// diferente no mesmo projeto.
final class DimensionamentoService implements DimensionamentoEngine {
  final DimensionamentoCargaService _carga;
  final DimensionamentoCircuitoService _circuito;

  DimensionamentoService({
    required NormativeEngine normative,
    required List<Disjuntor> catalogoDisjuntores,
  })  : _carga = DimensionamentoCargaService(),
        _circuito = DimensionamentoCircuitoService(
          normative: normative,
          catalogoDisjuntores: catalogoDisjuntores,
        );

  @override
  Comodo criarComodoComSugestoes({
    required String idTipo,
    required String label,
    required RegraTomadasComodo regraTomadasComodo,
    required double areaM2,
    required double perimetroM,
  }) =>
      _carga.criarComodoComSugestoes(
        idTipo: idTipo,
        label: label,
        regraTomadasComodo: regraTomadasComodo,
        areaM2: areaM2,
        perimetroM: perimetroM,
      );

  @override
  Comodo criarComodoCustom({
    required String label,
    required double areaM2,
    required double perimetroM,
    RegraTomadasComodo regraTomadasComodo = RegraTomadasComodo.custom,
  }) =>
      _carga.criarComodoCustom(
        label: label,
        areaM2: areaM2,
        perimetroM: perimetroM,
        regraTomadasComodo: regraTomadasComodo,
      );

  @override
  RelatorioCarga processarCarga(EntradaCarga entrada) =>
      _carga.processar(entrada);

  @override
  RelatorioDimensionamento dimensionarCircuito(EntradaDimensionamento entrada) =>
      _circuito.processar(entrada);
}
