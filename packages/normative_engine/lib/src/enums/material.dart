// REV: 1.0.0
// CHANGELOG:
// [1.0.0] - 2026-04
// - ADD: criação do enum.
/// Material do condutor.
///
/// Determina qual subconjunto de valores usar nas tabelas de ampacidade
/// e quais restrições normativas se aplicam.
///
/// Rastreabilidade: NBR 5410:2004 — 6.2.3.7, 6.2.3.8, Tabelas 36–39.
enum Material {
  /// Condutor de cobre.
  /// Sem restrições de seção mínima por material (aplica-se Tabela 47).
  /// Norma de referência para cabos nus: ABNT NBR 6524.
  cobre,

  /// Condutor de alumínio.
  /// Sujeito a restrições severas de uso (6.2.3.8):
  /// - Industrial: seção ≥ 16 mm², fonte AT/própria, BA5.
  /// - Comercial BD1: seção ≥ 50 mm², BA5.
  /// - BD4: PROIBIDO em qualquer circunstância.
  /// Tabelas 36–39 iniciam em 16 mm² para alumínio.
  aluminio;

  /// Seção mínima absoluta por material independente de tag ou arquitetura.
  /// Para alumínio em instalações industriais.
  /// Rastreabilidade: NBR 5410:2004 — 6.2.3.8.1.
  double? get secaoMinimaIndustrial => switch (this) {
        Material.cobre => null,
        Material.aluminio => 16.0,
      };

  /// Seção mínima absoluta para alumínio em instalações comerciais BD1.
  /// Rastreabilidade: NBR 5410:2004 — 6.2.3.8.2.
  double? get secaoMinimaComercial => switch (this) {
        Material.cobre => null,
        Material.aluminio => 50.0,
      };
}
