// REV: 1.0.0
// CHANGELOG:
// [1.0.0] - 2026-05
// - ADD: conversão de potência de plaqueta (W) para aparente (VA) — TUE.

/// Converte a potência nominal de plaqueta (W) em potência aparente (VA)
/// para dimensionamento de circuitos TUE.
///
/// Separação explícita entre:
/// - TUG: potência estimada (100 VA × pontos, limite 1500 VA/circuito).
/// - TUE: potência de plaqueta fornecida pelo usuário, convertida via FP.
///
/// Rastreabilidade: NBR 5410:2004 — 9.1.2.3.
abstract final class CalcPotenciaTue {
  /// Retorna a potência aparente (VA) a partir da potência ativa de plaqueta.
  ///
  /// [potenciaW] Potência ativa nominal do equipamento (W).
  /// [fatorPotencia] Fator de potência (0 < FP ≤ 1.0).
  static double calcular({
    required double potenciaW,
    required double fatorPotencia,
  }) =>
      potenciaW / fatorPotencia;
}
