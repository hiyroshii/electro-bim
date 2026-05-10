// REV: 1.0.0
// CHANGELOG:
// [1.0.0] - 2026-04
// - ADD: criação do enum.
/// Tipo de isolação do condutor.
///
/// Determina:
/// - Temperatura máxima de serviço contínuo (Tabela 35)
/// - Qual tabela de ampacidade usar (36/37 para A1–D, 38/39 para E/F/G)
/// - Qual coluna de FCT aplicar (Tabela 40)
/// - Temperatura de referência das tabelas base (30°C ar / 20°C solo)
///
/// Decisão de design: EPR e XLPE compartilham as mesmas tabelas de
/// ampacidade (37 e 39) e os mesmos fatores FCT — a norma usa colunas
/// idênticas para ambos. A distinção é preservada no enum para rastreabilidade
/// e para o relatório, mas o lookup sempre usa [chaveTabela].
///
/// Rastreabilidade: NBR 5410:2004 — Tabela 35, Tabela 40, Seção 6.2.5.
enum Isolacao {
  /// Policloreto de vinila.
  /// Temperatura máxima de serviço: 70 °C.
  /// Tabelas de ampacidade: 36 (A1–D) e 38 (E/F/G).
  /// FCT referência ar: 30 °C | solo: 20 °C.
  pvc,

  /// Polietileno reticulado.
  /// Temperatura máxima de serviço: 90 °C.
  /// Tabelas de ampacidade: 37 (A1–D) e 39 (E/F/G).
  /// FCT referência ar: 30 °C | solo: 20 °C.
  xlpe,

  /// Borracha etileno-propileno.
  /// Temperatura máxima de serviço: 90 °C.
  /// Compartilha tabelas e FCT com XLPE.
  epr;

  /// Temperatura máxima admissível em serviço contínuo (°C).
  /// Rastreabilidade: NBR 5410:2004 — Tabela 35.
  int get tempMaxServico => switch (this) {
        Isolacao.pvc => 70,
        Isolacao.xlpe || Isolacao.epr => 90,
      };

  /// Temperatura de referência para instalações não-subterrâneas (°C).
  /// Rastreabilidade: NBR 5410:2004 — 6.2.5.3.2.
  static const int tempRefAr = 30;

  /// Temperatura de referência para linhas enterradas — temperatura do solo (°C).
  /// Rastreabilidade: NBR 5410:2004 — 6.2.5.3.2.
  static const int tempRefSolo = 20;

  /// Chave usada no lookup das tabelas de ampacidade e FCT.
  /// EPR e XLPE retornam a mesma chave — compartilham tabelas.
  /// Rastreabilidade: NBR 5410:2004 — Tabelas 37, 39, 40.
  String get chaveTabela => switch (this) {
        Isolacao.pvc => 'PVC',
        Isolacao.xlpe || Isolacao.epr => 'XLPE_EPR',
      };

  /// Indica se a isolação usa as tabelas de PVC.
  bool get isPvc => this == Isolacao.pvc;
}
