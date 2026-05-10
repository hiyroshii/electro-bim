// REV: 1.2.0
// CHANGELOG:
// [1.2.0] - 2026-05
// - REF: reescrito como barrel puro de re-exports — definição de NormativeEngine
//   permanece exclusivamente em src/contracts/normative_engine.dart.
// - ADD: export de FaixaTensao.
// [1.1.0] - 2026-05
// - ADD: calcularSecaoNeutro() — cálculo real do neutro conforme 6.2.6.2.
// [1.0.1] - 2026-04
// - CHG: resolverDadosNormativos recebe ParamsAgrupamento por chamada.
// [1.0.0] - 2026-04
// - ADD: contrato abstrato NormativeEngine.

// Barrel público do normative_engine. Somente re-exports — sem lógica.

// Contratos
export 'src/contracts/normative_engine.dart';
export 'src/contracts/i_specification.dart';
export 'src/contracts/i_procedure.dart';

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
export 'src/enums/contexto_instalacao.dart';
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
export 'src/procedure/proc_ampacidade.dart' show ParamsAgrupamento;
