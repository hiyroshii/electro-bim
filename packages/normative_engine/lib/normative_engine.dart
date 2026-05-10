// REV: 2.0.0
// CHANGELOG:
// [2.0.0] - 2026-05
// - ADD: exports de IClassification, IVerification, PerfilInstalacao, CodigoInfluencia (Fase 2).
// - REM: ContextoInstalacao removido do barrel (substituído por PerfilInstalacao).
// - CHG: ParamsAgrupamento agora vem de procedure/condutor/proc_ampacidade.dart.
// [1.2.0] - 2026-05
// - REF: reescrito como barrel puro de re-exports.
// - ADD: export de FaixaTensao.

// Barrel público do normative_engine. Somente re-exports — sem lógica.

// Contratos
export 'src/contracts/normative_engine.dart';
export 'src/contracts/i_specification.dart';
export 'src/contracts/i_procedure.dart';
export 'src/contracts/i_classification.dart';
export 'src/contracts/i_verification.dart';

// Domínio
export 'src/domain/instalacao/perfil_instalacao.dart';
export 'src/domain/influencias/codigo_influencia.dart';

// Enums
export 'src/enums/isolacao.dart';
export 'src/enums/arquitetura.dart';
export 'src/enums/metodo_instalacao.dart';
export 'src/enums/arranjo_condutores.dart';
export 'src/enums/faixa_tensao.dart';
export 'src/enums/material.dart';
export 'src/enums/tag_circuito.dart';
export 'src/enums/tensao.dart';
export 'src/enums/numero_fases.dart';
export 'src/enums/origem_alimentacao.dart';
export 'src/enums/escopo_projeto.dart';

// Models
export 'src/models/entrada_normativa.dart';
export 'src/models/resultado_normativo.dart';
export 'src/models/dados_normativos.dart';
export 'src/models/violacao.dart';
export 'src/models/fatores_correcao.dart';
export 'src/models/linha_ampacidade.dart';
export 'src/models/parametros_queda.dart';

// ParamsAgrupamento — definido em proc_ampacidade, exposto seletivamente
export 'src/procedure/condutor/proc_ampacidade.dart' show ParamsAgrupamento;
