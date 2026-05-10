// REV: 1.0.0
// CHANGELOG:
// [1.0.0] - 2026-04
// - ADD: criação do enum.
/// Método de referência de instalação conforme NBR 5410.
///
/// Define as condições de troca térmica usadas nas tabelas de ampacidade
/// (Tabelas 36 a 39). Cada método corresponde a uma ou mais maneiras físicas
/// de instalar descritas na Tabela 33.
///
/// Os métodos físicos numerados (1–75A da Tabela 33) são uma camada de UX
/// opcional não implementada no engine — o usuário seleciona o método de
/// referência diretamente.
///
/// Rastreabilidade: NBR 5410:2004 — Tabela 33, Seção 6.2.5.1.2.
enum MetodoInstalacao {
  /// Condutores isolados ou unipolares em eletroduto embutido em
  /// parede termicamente isolante. Cabo multipolar também via método 51.
  /// Arquiteturas válidas: ISOLADO, UNIPOLAR, MULTIPOLAR.
  /// Referência física: parede com condutância interna ≥ 10 W/m².K.
  a1,

  /// Cabo multipolar em eletroduto embutido em parede termicamente isolante.
  /// Arquiteturas válidas: MULTIPOLAR exclusivo.
  a2,

  /// Condutores isolados ou unipolares em eletroduto aparente ou embutido
  /// em alvenaria. MULTIPOLAR aceito via método 43 (canaleta ventilada).
  /// Arquiteturas válidas: ISOLADO, UNIPOLAR, MULTIPOLAR.
  /// Referência física: eletroduto sobre parede de madeira, dist < 0,3 × Ø.
  b1,

  /// Cabo multipolar em eletroduto aparente ou embutido em alvenaria.
  /// ISOLADO aceito via método 26. UNIPOLAR aceito via métodos 23, 25, 27.
  /// Arquiteturas válidas: ISOLADO, UNIPOLAR, MULTIPOLAR.
  b2,

  /// Cabos sobre parede, teto, bandeja não-perfurada ou embutidos
  /// diretamente em alvenaria.
  /// Arquiteturas válidas: UNIPOLAR, MULTIPOLAR.
  c,

  /// Cabo em eletroduto ou diretamente enterrado.
  /// Único método com instalação subterrânea — usa temperatura do solo
  /// como referência (20 °C) e FCA das Tabelas 44/45.
  /// Arquiteturas válidas: UNIPOLAR, MULTIPOLAR.
  d,

  /// Cabo multipolar ao ar livre em bandeja perfurada, leito,
  /// suportes ou suspenso.
  /// Arquiteturas válidas: MULTIPOLAR exclusivo.
  /// Referência física: distância de superfícies ≥ 0,3 × Ø externo.
  e,

  /// Cabos unipolares justapostos ao ar livre.
  /// Arquiteturas válidas: UNIPOLAR exclusivo.
  /// Requer [ArranjoCondutores] não-nulo na entrada.
  /// Referência física: distância de superfícies ≥ 1 × Ø.
  f,

  /// Cabos unipolares ou condutores isolados espaçados ao ar livre
  /// sobre isoladores.
  /// Arquiteturas válidas: ISOLADO, UNIPOLAR.
  /// Requer [ArranjoCondutores] espacado na entrada.
  /// Referência física: espaçamento entre cabos ≥ 1 × Ø externo.
  g;

  /// Indica se o método é de instalação subterrânea.
  /// Apenas D é enterrado — determina uso de temperatura do solo
  /// e FCA das Tabelas 44/45.
  /// Rastreabilidade: NBR 5410:2004 — 6.2.5.3.2, 6.2.5.4.
  bool get isSolo => this == MetodoInstalacao.d;

  /// Indica se o método é ao ar livre (bandejas, leitos, espaçados).
  /// Rastreabilidade: NBR 5410:2004 — definições E, F e G na Tab. 33.
  bool get isArLivre =>
      this == MetodoInstalacao.e ||
      this == MetodoInstalacao.f ||
      this == MetodoInstalacao.g;

  /// Indica se o método usa as tabelas E/F/G (38 e 39).
  /// Caso contrário usa as tabelas A1–D (36 e 37).
  bool get usaTabelaEfg => isArLivre;
}
