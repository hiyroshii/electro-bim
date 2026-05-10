// REV: 1.2.0
// CHANGELOG:
// [1.2.0] - 2026-05
// - ADD: faixaTensao, outrasCircuitosNoConduto, compartilhaCaboMultipolar — suporte a COMB_007/008.
// [1.1.0] - 2026-05
// - ADD: dispositivoMultipolar:bool (default true) — suporte à spec_dispositivo_multipolar.
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
import '../enums/faixa_tensao.dart';
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
    this.dispositivoMultipolar = true,
    this.faixaTensao = FaixaTensao.faixaII,
    this.outrasCircuitosNoConduto = const [],
    this.compartilhaCaboMultipolar = false,
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

  /// Indica se o dispositivo de proteção é multipolar (corte simultâneo).
  /// Rastreabilidade: NBR 5410:2004 — 9.5.4.
  final bool dispositivoMultipolar;

  /// Faixa de tensão deste circuito (I = SELV/PELV, II = convencional).
  /// Rastreabilidade: NBR 5410:2004 — 6.2.9.5.
  final FaixaTensao faixaTensao;

  /// Faixas de tensão dos outros circuitos que compartilham o mesmo conduto.
  /// Lista vazia indica que o circuito está sozinho ou situação não informada.
  /// Rastreabilidade: NBR 5410:2004 — 6.2.9.5.
  final List<FaixaTensao> outrasCircuitosNoConduto;

  /// Indica se o cabo multipolar deste circuito contém condutores de outro circuito.
  /// Rastreabilidade: NBR 5410:2004 — 6.2.10.1.
  final bool compartilhaCaboMultipolar;
}
