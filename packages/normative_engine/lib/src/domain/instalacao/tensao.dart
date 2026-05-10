// REV: 1.0.0
// CHANGELOG:
// [1.0.0] - 2026-04
// - ADD: criação do enum.

import 'numero_fases.dart';

/// Tensões nominais suportadas pelo sistema.
///
/// Usada no cálculo da corrente de projeto (Ib) e na validação de
/// combinações válidas com [NumeroFases].
///
/// Rastreabilidade: NBR 5410:2004 — 6.1.3.1.1.
enum Tensao {
  /// 127 V — monofásico em redes 127/220 V.
  v127(127),

  /// 220 V — monofásico, bifásico ou trifásico em redes 127/220 V.
  v220(220),

  /// 380 V — trifásico em redes 220/380 V.
  v380(380);

  const Tensao(this.valor);

  /// Valor numérico da tensão em Volts.
  final int valor;

  /// Combinações válidas de tensão e número de fases.
  /// Rastreabilidade: NBR 5410:2004 — 6.1.3.1.1 e prática normativa BR.
  static const Map<Tensao, List<NumeroFases>> combinacoesValidas = {
    Tensao.v127: [NumeroFases.monofasico],
    Tensao.v220: [
      NumeroFases.monofasico,
      NumeroFases.bifasico,
      NumeroFases.trifasico,
    ],
    Tensao.v380: [NumeroFases.trifasico],
  };
}
