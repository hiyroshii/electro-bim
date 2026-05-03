// REV: 1.0.1
// CHANGELOG:
// [1.0.1] - 2026-04
// - CHG: removido numCircuitosAgrupados — campo morto, agrupamento via ParamsAgrupamento.
// [1.0.0] - 2026-04
// - ADD: criação de EntradaNormativa — tipo de entrada público do package.

import '../enums/isolacao.dart';
import '../enums/arquitetura.dart';
import '../enums/metodo_instalacao.dart';
import '../enums/arranjo_condutores.dart';
import '../enums/material.dart';
import '../enums/tag_circuito.dart';
import '../enums/tensao.dart';
import '../enums/numero_fases.dart';

/// Entrada normalizada do [NormativeEngine].
///
/// Contém apenas os campos que as regras normativas precisam conhecer.
/// Criada pelo [dimensionamento_engine] a partir de sua própria
/// [EntradaDimensionamento] antes de chamar o engine.
///
/// Agrupamento é passado separadamente via [ParamsAgrupamento] em
/// [NormativeEngine.resolverDadosNormativos] — varia por circuito.
///
/// Imutável — todos os campos são finais.
final class EntradaNormativa {
  final TagCircuito tagCircuito;
  final Tensao tensao;
  final NumeroFases numeroFases;
  final Isolacao isolacao;
  final Arquitetura arquitetura;
  final MetodoInstalacao metodo;
  final ArranjoCondutores? arranjo;
  final Material material;
  final int temperatura;
  final bool harmonicasAcima15pct;

  const EntradaNormativa({
    required this.tagCircuito,
    required this.tensao,
    required this.numeroFases,
    required this.isolacao,
    required this.arquitetura,
    required this.metodo,
    required this.material,
    required this.temperatura,
    required this.harmonicasAcima15pct,
    this.arranjo,
  });
}
