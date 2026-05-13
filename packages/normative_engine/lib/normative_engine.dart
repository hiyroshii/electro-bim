// REV: 3.2.0
// CHANGELOG:
// [3.2.0] - 2026-05
// - ADD: NormativeService exportado no barrel (orquestrador padrão).
// [3.1.0] - 2026-05
// - ADD: SpecMinimoIL + EntradaMinimoIL (S-12, Fase 3.3).
// - ADD: SpecMinimoTUG + EntradaMinimoTUG (S-13, Fase 3.3).
// [3.0.0] - 2026-05
// - ADD: TipoComodo (domain/locais) — tipo de cômodo residencial (Fase 3.2).
// - ADD: ProcCargaResidencial + EntradaCargaResidencial (Fase 3.2).
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
export 'src/domain/locais/tipo_comodo.dart';

// Enums — condutor
export 'src/domain/condutor/isolacao.dart';
export 'src/domain/condutor/arquitetura.dart';
export 'src/domain/condutor/metodo_instalacao.dart';
export 'src/domain/condutor/arranjo_condutores.dart';
export 'src/domain/condutor/material.dart';

// Enums — instalacao
export 'src/domain/instalacao/faixa_tensao.dart';
export 'src/domain/instalacao/tag_circuito.dart';
export 'src/domain/instalacao/tensao.dart';
export 'src/domain/instalacao/numero_fases.dart';
export 'src/domain/instalacao/origem_alimentacao.dart';
export 'src/domain/instalacao/escopo_projeto.dart';

// Models
export 'src/models/entrada_normativa.dart';
export 'src/models/resultado_normativo.dart';
export 'src/models/dados_normativos.dart';
export 'src/models/violacao.dart';
export 'src/models/fatores_correcao.dart';
export 'src/models/linha_ampacidade.dart';
export 'src/models/parametros_queda.dart';

// Orquestrador — implementação padrão de NormativeEngine
export 'src/orchestrator/normative_service.dart';

// ParamsAgrupamento — definido em proc_ampacidade, exposto seletivamente
export 'src/procedure/condutor/proc_ampacidade.dart' show ParamsAgrupamento;

// ProcCargaResidencial — P-6
export 'src/procedure/carga/proc_carga_residencial.dart'
    show ProcCargaResidencial, EntradaCargaResidencial;

// Specs de piso mínimo — S-12 e S-13
export 'src/specification/carga/spec_minimo_il.dart'
    show SpecMinimoIL, EntradaMinimoIL;
export 'src/specification/carga/spec_minimo_tug.dart'
    show SpecMinimoTUG, EntradaMinimoTUG;
