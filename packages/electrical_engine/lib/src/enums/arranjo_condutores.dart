// REV: 1.0.0
// CHANGELOG:
// [1.0.0] - 2026-04
// - ADD: criação do enum.
/// Arranjo geométrico dos cabos unipolares ao ar livre.
///
/// Relevante apenas para os métodos F e G. Para métodos A1–E o campo
/// correspondente na entrada deve ser null.
///
/// Os valores correspondem diretamente às colunas das Tabelas 38 e 39
/// da NBR 5410 — a nomenclatura é intencional para rastreabilidade direta.
///
/// Rastreabilidade: NBR 5410:2004 — Tabelas 38 e 39 (colunas literais).
enum ArranjoCondutores {
  // ── Método F — cabos justapostos (touching) ──────────────────────────────

  /// Dois cabos unipolares justapostos.
  /// Coluna da tabela: F-2c-just.
  /// Método: F.
  justaposto2c,

  /// Três cabos unipolares em formação trifólio (triângulo).
  /// Coluna da tabela: F-3c-trifólio.
  /// Método: F.
  trifolio,

  /// Três cabos unipolares no mesmo plano horizontal, justapostos.
  /// Coluna da tabela: F-3c-plano-H.
  /// Nota: plano vertical justaposto usa a mesma coluna da tabela.
  /// Método: F.
  planoJustaposto,

  // ── Método G — cabos espaçados (spaced) ──────────────────────────────────

  /// Três cabos unipolares espaçados em plano horizontal.
  /// Espaçamento mínimo: 1 × diâmetro externo entre cabos adjacentes.
  /// Coluna da tabela: G-3c-espac-H.
  /// Método: G.
  espacadoHorizontal,

  /// Três cabos unipolares espaçados em plano vertical.
  /// Espaçamento mínimo: 1 × diâmetro externo entre cabos adjacentes.
  /// Coluna da tabela: G-3c-espac-V.
  /// Método: G.
  espacadoVertical;

  /// Indica se o arranjo é do método F (justapostos).
  bool get isMetodoF =>
      this == ArranjoCondutores.justaposto2c ||
      this == ArranjoCondutores.trifolio ||
      this == ArranjoCondutores.planoJustaposto;

  /// Indica se o arranjo é do método G (espaçados).
  bool get isMetodoG =>
      this == ArranjoCondutores.espacadoHorizontal ||
      this == ArranjoCondutores.espacadoVertical;

  /// Número de condutores carregados implícito no arranjo.
  /// justaposto2c → 2 condutores | demais → 3 condutores.
  int get condutoresCarregados =>
      this == ArranjoCondutores.justaposto2c ? 2 : 3;
}
