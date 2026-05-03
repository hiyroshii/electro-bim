// REV: 1.6.0
// CHANGELOG:
// [1.6.0] - 02 05 2026
// - ADD: SnapType.grid — snap em grade de referência
//
// [1.5.0] - 01 05 2026
// - ADD: midpoint, nearest e intersection para suporte ao SnapService real
//
// [1.0.0] - 29 04 2026
// - ADD: SnapType enum com none e endpoint

/// Define o tipo de ponto geométrico onde o snap foi ancorado.
enum SnapType {
  /// Nenhum snap aplicado; o cursor está em movimento livre.
  none,

  /// Snap ancorado nas extremidades de uma linha ou polilinha.
  endpoint,

  /// Snap ancorado no centro exato de um segmento.
  midpoint,

  /// Snap ancorado em qualquer ponto ao longo de uma linha (projeção).
  nearest,

  /// Snap ancorado no cruzamento de duas ou mais entidades.
  intersection,

  /// Snap ancorado na grade de referência.
  grid,
}