// REV: 2.0.0
// CHANGELOG:
// [2.0.0] - 2026-05
// - ADD: comercial e industrial — necessários para SpecAluminio (Fase 2).
// [1.0.0] - 2026-05
// - ADD: criação do enum EscopoProjeto.

/// Escopo normativo do projeto elétrico.
///
/// Determina o conjunto de regras NBR 5410:2004 aplicável
/// e o conjunto de specs filtradas por [ISpecification.aplicavelA].
///
/// Rastreabilidade: NBR 5410:2004 — Seções 8 e 9.
enum EscopoProjeto {
  /// Instalações de uso pessoal — residências e similares.
  /// Rastreabilidade: NBR 5410:2004 — 9.1.
  residencial,

  /// Instalações comerciais — escritórios, lojas, serviços.
  /// Rastreabilidade: NBR 5410:2004 — 9.2.
  comercial,

  /// Instalações industriais — com fonte AT ou geradores próprios.
  /// Rastreabilidade: NBR 5410:2004 — 9.3.
  industrial,
}
