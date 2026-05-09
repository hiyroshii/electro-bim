// REV: 1.0.0
// CHANGELOG:
// [1.0.0] - 2026-05
// - ADD: criação do enum EscopoProjeto.

/// Escopo normativo do projeto elétrico.
///
/// Determina o conjunto de regras NBR 5410:2004 aplicável.
/// Preparação para suporte a múltiplos escopos em fases futuras.
///
/// Rastreabilidade: NBR 5410:2004 — Seção 9 (residencial).
enum EscopoProjeto {
  /// Instalações de uso pessoal — residências e similares.
  /// Rastreabilidade: NBR 5410:2004 — 9.1.
  residencial,
}
