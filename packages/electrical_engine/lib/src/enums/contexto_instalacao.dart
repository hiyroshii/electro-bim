// REV: 1.0.0
// CHANGELOG:
// [1.0.0] - 2026-04
// - ADD: enum ContextoInstalacao extraído de spec_aluminio.dart para src/enums/.

/// Contexto de instalação para verificação de restrições de alumínio.
///
/// Rastreabilidade: NBR 5410:2004 — 6.2.3.8.
enum ContextoInstalacao {
  /// Instalação industrial com fonte AT ou própria, manutenção por BA5.
  /// Alumínio permitido com seção ≥ 16 mm².
  industrial,

  /// Instalação comercial em local exclusivamente BD1, manutenção por BA5.
  /// Alumínio permitido com seção ≥ 50 mm².
  comercialBd1,

  /// Local de instalação classificado como BD4.
  /// Alumínio proibido em qualquer circunstância.
  bd4,
}
