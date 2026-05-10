// REV: 1.0.0
// CHANGELOG:
// [1.0.0] - 2026-05
// - ADD: enum CodigoInfluencia — famílias BA e BD (Fase 2).

/// Códigos de influências externas conforme NBR 5410:2004 — Seção 4.2.6.
///
/// Cada código identifica uma condição de influência externa classificada.
/// Usado em [PerfilInstalacao] para compor o contexto normativo de um projeto.
///
/// Rastreabilidade: NBR 5410:2004 — Tab. 1-24 (4.2.6).
enum CodigoInfluencia {
  // ── BA — Competência das pessoas ────────────────────────────────────────────

  /// Pessoas instruídas — conhecem os riscos mas não são habilitadas.
  /// Rastreabilidade: NBR 5410:2004 — Tab. 15 (BA3).
  ba3,

  /// Pessoas habilitadas — eletricistas qualificados.
  /// Rastreabilidade: NBR 5410:2004 — Tab. 15 (BA4).
  ba4,

  /// Pessoas especialmente habilitadas — engenheiros e técnicos.
  /// Rastreabilidade: NBR 5410:2004 — Tab. 15 (BA5).
  ba5,

  // ── BD — Materiais processados ───────────────────────────────────────────────

  /// Local sem risco de incêndio (materiais não inflamáveis).
  /// Rastreabilidade: NBR 5410:2004 — Tab. 18 (BD1).
  bd1,

  /// Local com risco de incêndio (materiais combustíveis).
  /// Rastreabilidade: NBR 5410:2004 — Tab. 18 (BD2).
  bd2,

  /// Local com risco de explosão — pó combustível.
  /// Rastreabilidade: NBR 5410:2004 — Tab. 18 (BD3).
  bd3,

  /// Local com risco de explosão — gases ou vapores inflamáveis.
  /// Rastreabilidade: NBR 5410:2004 — Tab. 18 (BD4).
  bd4,
}
