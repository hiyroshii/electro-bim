// REV: 1.0.0
// CHANGELOG:
// [1.0.0] - 2026-05
// - ADD: contrato IVerification — Fase 2.

/// Contrato de uma verificação de campo (ensaio).
///
/// Cada implementação verifica uma medição de campo [M] contra o projeto [P]
/// e retorna o resultado do ensaio [R].
///
/// Implementações planejadas:
/// - [VerifyContinuidadePe]          — V-1
/// - [VerifyResistenciaIsolamento]   — V-2
/// - [VerifySeccionamentoAutomatico] — V-3
/// - [VerifyDr]                      — V-4
/// - [VerifyResistenciaAterramento]  — V-5
///
/// Rastreabilidade: ARCHITECTURE.md — Seção 2.
abstract interface class IVerification<M, P, R> {
  /// Verifica a medição [medicao] contra o projeto [projeto].
  R ensaiar(final M medicao, final P projeto);
}
