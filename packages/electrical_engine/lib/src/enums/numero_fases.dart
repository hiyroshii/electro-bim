// REV: 1.0.0
// CHANGELOG:
// [1.0.0] - 2026-04
// - ADD: criação do enum.
/// Número de fases do circuito.
///
/// Determina:
/// - Constante de cálculo de Ib (fator √3 para trifásico).
/// - Número de condutores carregados (Tabela 46).
/// - Regras do condutor neutro (6.2.6.2).
///
/// Rastreabilidade: NBR 5410:2004 — 6.2.5.6, Tabela 46.
enum NumeroFases {
  /// Circuito monofásico — 1 fase + neutro.
  /// Condutores carregados: 2.
  /// Fator Ib: tensão de fase (V).
  monofasico,

  /// Circuito bifásico — 2 fases + neutro.
  /// Condutores carregados: 3 (com neutro) ou 2 (sem neutro).
  /// Fator Ib: tensão de fase (V).
  bifasico,

  /// Circuito trifásico — 3 fases (+ neutro opcional).
  /// Condutores carregados: 3 (sem neutro) ou 3/4 (com neutro).
  /// Fator Ib: tensão × √3.
  trifasico;

  /// Indica se o circuito é trifásico.
  /// Trifásico usa fator √3 no cálculo de Ib.
  bool get isTrifasico => this == NumeroFases.trifasico;

  /// Número base de condutores carregados sem neutro.
  /// Rastreabilidade: NBR 5410:2004 — Tabela 46.
  int get condutoresCarregadosBase => switch (this) {
        NumeroFases.monofasico => 2,
        NumeroFases.bifasico => 2,
        NumeroFases.trifasico => 3,
      };

  /// Número de condutores carregados com neutro presente.
  /// Para trifásico com neutro e harmônicas ≤ 15%: 3.
  /// Para trifásico com neutro e harmônicas > 15%: 4 (ver 6.2.5.6.1).
  /// Rastreabilidade: NBR 5410:2004 — Tabela 46, 6.2.5.6.1.
  int condutoresCarregadosComNeutro({required bool harmonicasAcima15}) =>
      switch (this) {
        NumeroFases.monofasico => 2,
        NumeroFases.bifasico => 3,
        NumeroFases.trifasico => harmonicasAcima15 ? 4 : 3,
      };

  /// Fator aplicado à ampacidade quando há 4 condutores carregados.
  /// Rastreabilidade: NBR 5410:2004 — 6.2.5.6.1.
  static const double fatorQuatroCondutores = 0.86;
}
