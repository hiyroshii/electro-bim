// REV: 1.0.1
// CHANGELOG:
// [1.0.1] - 2026-04
// - ADD: exports de contexto_instalacao e origem_alimentacao direto de enums/.
// [1.0.0] - 2026-04
// - ADD: criação do barrel público.

/// normative_engine
///
/// Package Dart puro que encapsula as regras da ABNT NBR 5410:2004
/// aplicáveis ao dimensionamento de instalações elétricas de baixa tensão.
///
/// Importe este arquivo — nunca importe diretamente de src/.
library normative_engine;

// Contrato público do engine
export 'src/contracts/normative_engine.dart';

// Orquestrador mestre — executável
export 'src/orchestrator/normative_service.dart';

// Tipos auxiliares públicos de specification
export 'src/enums/contexto_instalacao.dart';
export 'src/enums/origem_alimentacao.dart';

// Tipos auxiliares públicos de procedure
export 'src/procedure/proc_ampacidade.dart' show ParamsAgrupamento;

// Models — value objects do domínio normativo
export 'src/models/entrada_normativa.dart';
export 'src/models/resultado_normativo.dart';
export 'src/models/violacao.dart';
export 'src/models/fatores_correcao.dart';
export 'src/models/linha_ampacidade.dart';
export 'src/models/parametros_queda.dart';
export 'src/models/dados_normativos.dart';

// Enums — tipos do domínio normativo
export 'src/enums/isolacao.dart';
export 'src/enums/arquitetura.dart';
export 'src/enums/metodo_instalacao.dart';
export 'src/enums/arranjo_condutores.dart';
export 'src/enums/material.dart';
export 'src/enums/tag_circuito.dart';
export 'src/enums/tensao.dart';
export 'src/enums/numero_fases.dart';
