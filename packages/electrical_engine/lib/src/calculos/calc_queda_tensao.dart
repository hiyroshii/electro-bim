// REV: 1.0.1
// CHANGELOG:
// [1.0.1] - 2026-04
// - ADD: implementação completa de calcularPercentual() com resistência, reatância e cosφ.
// [1.0.0] - 2026-04
// - ADD: scaffold de CalcQuedaTensao com reatância (xi) e cosφ.

import 'dart:math';

/// Calcula a queda de tensão percentual do circuito.
///
/// Fórmula completa (com resistência e reatância):
///   ΔV = k × Ib × L × (R × cosφ + X × senφ)
///   k = 2 para mono/bifásico | k = √3 para trifásico
///   ΔV% = (ΔV / V) × 100
///
/// Onde:
///   R = resistência do condutor (Ω/m) = resistividade / seção
///   X = reatância (xi) do condutor (Ω/m) — da tabela de impedâncias
///   L = distância (m)
///   V = tensão nominal (V)
///
/// Matemática pura — sem conhecimento de norma.
/// Rastreabilidade: NBR 5410:2004 — 6.2.7.4.
abstract final class CalcQuedaTensao {
  /// Calcula ΔV (%).
  ///
  /// [distancia]      — comprimento do circuito (m).
  /// [corrente]       — corrente de projeto Ib (A).
  /// [tensao]         — tensão nominal (V).
  /// [resistencia]    — resistência do condutor (Ω/m) = resistividade / seção.
  /// [reatancia]      — reatância xi (Ω/m) da tabela de impedâncias.
  /// [isTrifasico]    — usa fator √3, senão fator 2.
  /// [cosPhi]         — fator de potência do circuito.
  static double calcularPercentual({
    required double distancia,
    required double corrente,
    required double tensao,
    required double resistencia,
    required double reatancia,
    required bool isTrifasico,
    required double cosPhi,
  }) {
    assert(tensao > 0, 'tensao deve ser > 0');
    assert(cosPhi >= 0.0 && cosPhi <= 1.0, 'cosPhi deve estar entre 0 e 1');

    final senPhi = sqrt(1 - cosPhi * cosPhi);
    final k = isTrifasico ? sqrt(3) : 2.0;

    final deltaV = k * corrente * distancia *
        (resistencia * cosPhi + reatancia * senPhi);

    return (deltaV / tensao) * 100;
  }
}
