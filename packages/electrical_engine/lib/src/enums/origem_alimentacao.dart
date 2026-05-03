// REV: 1.0.0
// CHANGELOG:
// [1.0.0] - 2026-04
// - ADD: enum OrigemAlimentacao extraído de spec_queda_tensao.dart para src/enums/.

/// Origem da alimentação — determina o limite de queda para alimentadores.
///
/// Rastreabilidade: NBR 5410:2004 — 6.2.7.1.
enum OrigemAlimentacao {
  /// Trafo ou gerador próprio da instalação.
  /// Limite de queda: 7%.
  trafoProprio,

  /// Ponto de entrega da concessionária.
  /// Limite de queda: 5%.
  pontoEntrega,
}
