// REV: 1.0.1
// CHANGELOG:
// [1.0.1] - 2026-05
// - FIX: const Map → final Map — double não pode ser chave em const map no Dart.
// [1.0.0] - 2026-04
// - ADD: FCA agrupamento feixe/camada única (Tabela 42).
// - ADD: FCA agrupamento múltiplas camadas (Tabela 43).
// - ADD: FCA agrupamento cabos diretamente enterrados (Tabela 44).
// - ADD: FCA agrupamento linhas em eletrodutos enterrados (Tabela 45).

/// Tabelas 42 a 45 — Fatores de correção de agrupamento (FCA).
///
/// Fonte normativa: doc/nbr5410/6_2_5_tabelas42_45_agrupamento.md
/// Rastreabilidade: NBR 5410:2004 — Tabelas 42–45, Seção 6.2.5.5.
///
/// Condutores com corrente de projeto ≤ 30% da ampacidade corrigida
/// podem ser desconsiderados na contagem de agrupamento (6.2.5.5.2).
///
/// Para grupos não-semelhantes: F = 1 / √n (6.2.5.5.5.b).
library;


// ══════════════════════════════════════════════════════════════════════════
// TABELA 42 — Agrupamento em feixe ou camada única
// ══════════════════════════════════════════════════════════════════════════
//
// Chave: número de circuitos agrupados.
// Intervalos 9–11, 12–15, 16–19, ≥20 representados pelos limites inferiores.
// O consumidor deve mapear o número real ao intervalo correto.

/// Ref. 1 — Em feixe: ao ar livre, sobre superfície, embutidos ou em conduto
/// fechado. Tabelas 36–39 (Métodos A–F).
/// Rastreabilidade: NBR 5410:2004 — Tabela 42, linha 1.
final Map<int, double> fcaFeixe = {
  1: 1.00, 2: 0.80, 3: 0.70, 4: 0.65, 5: 0.60,
  6: 0.57, 7: 0.54, 8: 0.52, 9: 0.50,
  12: 0.45, 16: 0.41, 20: 0.38,
};

/// Ref. 2 — Camada única sobre parede, piso, bandeja não-perfurada ou
/// prateleira. Tabelas 36–37 (Método C).
/// Rastreabilidade: NBR 5410:2004 — Tabela 42, linha 2.
final Map<int, double> fcaCamadaUnicaParede = {
  1: 1.00, 2: 0.85, 3: 0.79, 4: 0.75, 5: 0.73,
  6: 0.72, 7: 0.72, 8: 0.71, 9: 0.70,
};

/// Ref. 3 — Camada única no teto. Tabelas 36–37 (Método C).
/// Rastreabilidade: NBR 5410:2004 — Tabela 42, linha 3.
final Map<int, double> fcaCamadaUnicaTeto = {
  1: 0.95, 2: 0.81, 3: 0.72, 4: 0.68, 5: 0.66,
  6: 0.64, 7: 0.63, 8: 0.62, 9: 0.61,
};

/// Ref. 4 — Camada única em bandeja perfurada. Tabelas 38–39 (Métodos E, F).
/// Rastreabilidade: NBR 5410:2004 — Tabela 42, linha 4.
final Map<int, double> fcaBandejaPerfurada = {
  1: 1.00, 2: 0.88, 3: 0.82, 4: 0.77, 5: 0.75,
  6: 0.73, 7: 0.73, 8: 0.72, 9: 0.72,
};

/// Ref. 5 — Camada única sobre leito / suporte. Tabelas 38–39 (Métodos E, F).
/// Rastreabilidade: NBR 5410:2004 — Tabela 42, linha 5.
final Map<int, double> fcaLeito = {
  1: 1.00, 2: 0.87, 3: 0.82, 4: 0.80, 5: 0.80,
  6: 0.79, 7: 0.79, 8: 0.78, 9: 0.78,
};

// ══════════════════════════════════════════════════════════════════════════
// TABELA 43 — Agrupamento em múltiplas camadas
// ══════════════════════════════════════════════════════════════════════════
//
// Métodos C (Tab. 36–37), E e F (Tab. 38–39).
// Chave: (int camadas, int circuitos) → double fator.
// Intervalos representados pelos limites inferiores (2, 3, 4, 6, 9).
// Rastreabilidade: NBR 5410:2004 — Tabela 43.

final Map<(int, int), double> fcaMultiplasCamadas = {
  (2, 2): 0.68, (2, 3): 0.62, (2, 4): 0.60, (2, 6): 0.58, (2, 9): 0.56,
  (3, 2): 0.62, (3, 3): 0.57, (3, 4): 0.55, (3, 6): 0.53, (3, 9): 0.51,
  (4, 2): 0.60, (4, 3): 0.55, (4, 4): 0.52, (4, 6): 0.51, (4, 9): 0.49,
  (6, 2): 0.58, (6, 3): 0.53, (6, 4): 0.51, (6, 6): 0.49, (6, 9): 0.48,
  (9, 2): 0.56, (9, 3): 0.51, (9, 4): 0.49, (9, 6): 0.48, (9, 9): 0.46,
};

// ══════════════════════════════════════════════════════════════════════════
// TABELA 44 — Agrupamento cabos diretamente enterrados
// ══════════════════════════════════════════════════════════════════════════
//
// Profundidade: 0,7 m — Resistividade do solo: 2,5 K.m/W.
// Chave: (int circuitos, double espaçamento_m).
// Espaçamento 0,0 = nulo (justapostos).
// Espaçamento -1.0 = 1 diâmetro de cabo (representação interna).
// Rastreabilidade: NBR 5410:2004 — Tabela 44.

final Map<(int, double), double> fcaEnterradoDireto = {
  // (circuitos, espaçamento_m) → fator
  // espaçamento -1.0 representa "1 diâmetro de cabo"
  (2, 0.0): 0.75, (2, -1.0): 0.80, (2, 0.125): 0.85, (2, 0.25): 0.90, (2, 0.5): 0.90,
  (3, 0.0): 0.65, (3, -1.0): 0.70, (3, 0.125): 0.75, (3, 0.25): 0.80, (3, 0.5): 0.85,
  (4, 0.0): 0.60, (4, -1.0): 0.60, (4, 0.125): 0.70, (4, 0.25): 0.75, (4, 0.5): 0.80,
  (5, 0.0): 0.55, (5, -1.0): 0.55, (5, 0.125): 0.65, (5, 0.25): 0.70, (5, 0.5): 0.80,
  (6, 0.0): 0.50, (6, -1.0): 0.55, (6, 0.125): 0.60, (6, 0.25): 0.70, (6, 0.5): 0.80,
};

// ══════════════════════════════════════════════════════════════════════════
// TABELA 45 — Agrupamento linhas em eletrodutos enterrados
// ══════════════════════════════════════════════════════════════════════════
//
// Profundidade: 0,7 m — Resistividade do solo: 2,5 K.m/W.
// Chave: (int circuitos, double espaçamento_m, bool multipolares).
// multipolares = true → cabo multipolar (um por eletroduto).
// multipolares = false → isolados/unipolares (um por eletroduto).
// Rastreabilidade: NBR 5410:2004 — Tabela 45.

final Map<(int, double, bool), double> fcaEletrodutosEnterrados = {
  // Cabos multipolares — um por eletroduto
  (2, 0.0, true): 0.85, (2, 0.25, true): 0.90, (2, 0.5, true): 0.95, (2, 1.0, true): 0.95,
  (3, 0.0, true): 0.75, (3, 0.25, true): 0.85, (3, 0.5, true): 0.90, (3, 1.0, true): 0.95,
  (4, 0.0, true): 0.70, (4, 0.25, true): 0.80, (4, 0.5, true): 0.85, (4, 1.0, true): 0.90,
  (5, 0.0, true): 0.65, (5, 0.25, true): 0.80, (5, 0.5, true): 0.85, (5, 1.0, true): 0.90,
  (6, 0.0, true): 0.60, (6, 0.25, true): 0.80, (6, 0.5, true): 0.80, (6, 1.0, true): 0.80,
  // Isolados / unipolares — um por eletroduto
  (2, 0.0, false): 0.80, (2, 0.25, false): 0.90, (2, 0.5, false): 0.90, (2, 1.0, false): 0.95,
  (3, 0.0, false): 0.70, (3, 0.25, false): 0.80, (3, 0.5, false): 0.85, (3, 1.0, false): 0.90,
  (4, 0.0, false): 0.65, (4, 0.25, false): 0.75, (4, 0.5, false): 0.80, (4, 1.0, false): 0.90,
  (5, 0.0, false): 0.60, (5, 0.25, false): 0.70, (5, 0.5, false): 0.80, (5, 1.0, false): 0.90,
  (6, 0.0, false): 0.60, (6, 0.25, false): 0.70, (6, 0.5, false): 0.80, (6, 1.0, false): 0.90,
};
