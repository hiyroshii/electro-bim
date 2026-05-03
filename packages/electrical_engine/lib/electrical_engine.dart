// REV: 1.0.0
// CHANGELOG:
// [1.0.0] - 2026-04
// - ADD: barrel público do electrical_engine.

library electrical_engine;

// Contrato público
export 'src/orchestrator/dimensionamento_engine.dart';

// Orquestrador mestre — executável
export 'src/orchestrator/dimensionamento_service.dart';

// Política de disjuntor (catálogo de produto — app fornece)
export 'src/orchestrator/circuito/politica_disjuntor.dart' show Disjuntor;

// Models — carga
export 'src/models/carga/comodo.dart';
export 'src/models/carga/entrada_carga.dart';
export 'src/models/carga/relatorio_carga.dart';

// Models — circuito
export 'src/models/circuito/entrada_dimensionamento.dart';
export 'src/models/circuito/relatorio_dimensionamento.dart';
export 'src/models/circuito/resultado_selecao.dart' show StatusDimensionamento;
