// REV: 1.0.0
// CHANGELOG:
// [1.0.0] - 2026-04
// - ADD: contrato abstrato DimensionamentoEngine.

import '../models/carga/comodo.dart';
import '../models/carga/entrada_carga.dart';
import '../models/carga/relatorio_carga.dart';
import '../models/circuito/entrada_dimensionamento.dart';
import '../models/circuito/relatorio_dimensionamento.dart';

/// Contrato público do electrical_engine.
///
/// Ponto único de acesso para o apps/flutter.
/// Implementado por [DimensionamentoService].
///
/// Fluxo completo:
///   1. Criar cômodos com [criarComodoComSugestoes] ou [criarComodoCustom].
///   2. Processar cargas com [processarCarga] → [RelatorioCarga].
///   3. Para cada circuito em [RelatorioCarga.circuitos]:
///      → criar [EntradaDimensionamento] e chamar [dimensionarCircuito].
///   4. Enviar [RelatorioDimensionamento] para auditoria normativa.
abstract interface class DimensionamentoEngine {
  /// Cria cômodo com pontos TUG e IL sugeridos pela norma.
  Comodo criarComodoComSugestoes({
    required String idTipo,
    required String label,
    required RegraTomadasComodo regraTomadasComodo,
    required double areaM2,
    required double perimetroM,
  });

  /// Cria cômodo personalizado com regra definida pelo usuário.
  Comodo criarComodoCustom({
    required String label,
    required double areaM2,
    required double perimetroM,
    RegraTomadasComodo regraTomadasComodo,
  });

  /// Processa o projeto de cargas e retorna circuitos agregados.
  RelatorioCarga processarCarga(EntradaCarga entrada);

  /// Dimensiona um único circuito elétrico.
  ///
  /// Lança [EntradaInvalidaException] se a entrada for normalmente inválida.
  RelatorioDimensionamento dimensionarCircuito(EntradaDimensionamento entrada);
}
