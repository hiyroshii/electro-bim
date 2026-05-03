// REV: 1.0.1
// CHANGELOG:
// [1.0.1] - 2026-04
// - ADD: implementação completa de calcular() — mono e trifásico.
// - CHG: _raiz3 via sqrt(3) em vez de placeholder.
// [1.0.0] - 2026-04
// - ADD: scaffold de CalcCorrenteProjeto.

import 'dart:math';

/// Calcula a corrente de projeto (Ib) do circuito.
///
/// Monofásico/bifásico: Ib = P / (V × FP)
/// Trifásico:           Ib = P / (√3 × V × FP)
///
/// Matemática pura — sem conhecimento de norma.
/// Rastreabilidade: NBR 5410:2004 — 6.1.3.1.2.
abstract final class CalcCorrenteProjeto {
  static final double _raiz3 = sqrt(3);

  /// Calcula Ib (A).
  ///
  /// [potenciaVA]    — potência aparente (VA).
  /// [tensaoV]       — tensão nominal (V).
  /// [fatorPotencia] — FP entre 0,10 e 1,00.
  /// [isTrifasico]   — usa fator √3 se verdadeiro.
  static double calcular({
    required double potenciaVA,
    required double tensaoV,
    required double fatorPotencia,
    required bool isTrifasico,
  }) {
    assert(potenciaVA >= 0, 'potenciaVA deve ser >= 0');
    assert(tensaoV > 0, 'tensaoV deve ser > 0');
    assert(
      fatorPotencia >= 0.10 && fatorPotencia <= 1.00,
      'fatorPotencia deve estar entre 0,10 e 1,00',
    );

    if (potenciaVA == 0) return 0;

    final fator = isTrifasico ? _raiz3 * tensaoV : tensaoV;
    return potenciaVA / (fator * fatorPotencia);
  }
}
