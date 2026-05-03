// REV: 1.0.2
// CHANGELOG:
// [1.0.2] - 2026-04
// - CHG: limites de queda corrigidos — terminal 4% (fixo), alimentador 1% (entrega)
//        ou 3% (trafo/gerador próprio). Total 5% ou 7% respectivamente.
// [1.0.1] - 2026-04
// - CHG: limites de queda corrigidos (parcialmente — revertido em 1.0.2).
// [1.0.0] - 2026-04
// - ADD: criação do enum.

/// Identificação do tipo do circuito dentro do projeto elétrico.
///
/// Determina:
/// - Limite de queda de tensão aplicável (6.2.7).
/// - Seção mínima normativa (Tabela 47).
///
/// Rastreabilidade: NBR 5410:2004 — 6.2.7.1, 6.2.7.2, Tabela 47.
enum TagCircuito {
  /// Medição — entrada da concessionária. Alimentador.
  med,

  /// Quadro de Distribuição Geral. Alimentador.
  qdg,

  /// Quadro de Distribuição. Alimentador.
  qd,

  /// Tomada de Uso Geral. Circuito terminal.
  tug,

  /// Tomada de Uso Específico. Circuito terminal.
  tue,

  /// Iluminação. Circuito terminal.
  il;

  /// Indica se o circuito é terminal (TUG, TUE, IL).
  /// Rastreabilidade: NBR 5410:2004 — 6.2.7.2.
  bool get isTerminal =>
      this == TagCircuito.tug ||
      this == TagCircuito.tue ||
      this == TagCircuito.il;

  /// Limite de queda de tensão para circuitos terminais (%).
  /// Fixo em 4% independente da origem da alimentação.
  /// Rastreabilidade: NBR 5410:2004 — 6.2.7.2.
  static const double limiteQuedaTerminal = 4.0;

  /// Limite de queda de tensão para alimentadores (MED, QDG, QD)
  /// quando alimentados pela rede da concessionária (%).
  /// Total: 1% (alimentador) + 4% (terminal) = 5%.
  /// Rastreabilidade: NBR 5410:2004 — 6.2.7.1.
  static const double limiteQuedaAlimentadorEntrega = 1.0;

  /// Limite de queda de tensão para alimentadores (MED, QDG, QD)
  /// quando alimentados por trafo ou gerador próprio (%).
  /// Total: 3% (alimentador) + 4% (terminal) = 7%.
  /// Aplicável em instalações comerciais, industriais e prediais com
  /// fonte própria.
  /// Rastreabilidade: NBR 5410:2004 — 6.2.7.1.
  static const double limiteQuedaAlimentadorProprio = 3.0;

  /// Queda total máxima com alimentação pela concessionária (%).
  /// Rastreabilidade: NBR 5410:2004 — 6.2.7.1.
  static const double limiteQuedaTotalEntrega = 5.0;

  /// Queda total máxima com trafo/gerador próprio (%).
  /// Rastreabilidade: NBR 5410:2004 — 6.2.7.1.
  static const double limiteQuedaTotalProprio = 7.0;
}
