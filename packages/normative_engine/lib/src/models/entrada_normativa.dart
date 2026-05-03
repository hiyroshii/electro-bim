// REV: 1.0.2
// CHANGELOG:
// [1.0.2] - 2026-05
// - FIX: construtor movido antes dos campos.
// [1.0.1] - 2026-04
// - CHG: removido numCircuitosAgrupados.
// [1.0.0] - 2026-04
// - ADD: criação de EntradaNormativa.

import '../enums/isolacao.dart';
import '../enums/arquitetura.dart';
import '../enums/metodo_instalacao.dart';
import '../enums/arranjo_condutores.dart';
import '../enums/material.dart';
import '../enums/tag_circuito.dart';
import '../enums/tensao.dart';
import '../enums/numero_fases.dart';

/// Entrada normalizada do [NormativeEngine].
/// Criada pelo [dimensionamento_engine] antes de chamar o engine.
final class EntradaNormativa {
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
}
