// REV: 1.0.0
// CHANGELOG:
// [1.0.0] - 2026-04
// - ADD: criação do enum.
/// Arquitetura construtiva do condutor.
///
/// Determina quais métodos de instalação são válidos (Tabela 33)
/// e quais combinações com [Isolacao] são permitidas (6.2.3).
///
/// Rastreabilidade: NBR 5410:2004 — Tabela 33, Seção 6.2.3.
enum Arquitetura {
  /// Condutor isolado individual — sem cobertura externa.
  /// Norma de fabricação PVC: ABNT NBR NM 247-3.
  /// Métodos válidos: A1, B1, B2, G.
  /// Isolações válidas: somente PVC.
  isolado,

  /// Cabo unipolar — condutor com isolação e cobertura.
  /// Normas: NBR 7288 / 8661 (PVC), NBR 7287 (XLPE), NBR 7286 (EPR).
  /// Métodos válidos: A1, B1, B2, C, D, F, G.
  /// Isolações válidas: PVC, XLPE, EPR.
  unipolar,

  /// Cabo multipolar — múltiplos condutores numa cobertura comum.
  /// Normas: NBR 7288 / 8661 (PVC), NBR 7287 (XLPE), NBR 7286 (EPR).
  /// Métodos válidos: A1, A2, B1, B2, C, D, E.
  /// Isolações válidas: PVC, XLPE, EPR.
  multipolar;
}
