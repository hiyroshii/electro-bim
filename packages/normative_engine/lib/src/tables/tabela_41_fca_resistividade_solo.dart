// REV: 1.0.1
// CHANGELOG:
// [1.0.1] - 2026-05
// - FIX: const Map → final Map — double não pode ser chave em const map no Dart.
// [1.0.0] - 2026-04
// - ADD: fatores de correção por resistividade térmica do solo (Tabela 41).

/// Tabela 41 — Fatores de correção para linhas subterrâneas em solo com
/// resistividade diferente de 2,5 K.m/W.
///
/// Fonte normativa: doc/nbr5410/6_2_5_tabela41_fct_resistividade_solo.md
/// Rastreabilidade: NBR 5410:2004 — Tabela 41, Seção 6.2.5.4.
///
/// Aplicável apenas ao Método D (subterrâneo).
/// Referência: 2,5 K.m/W → fator 1,00.
/// Aplicável a cabos em eletrodutos enterrados a profundidade de até 0,8 m.
///
/// Chave: resistividade em K.m/W.
/// Valor: fator de correção.
final Map<double, double> fcaResistividadeSolo = {
  1.0: 1.18,
  1.5: 1.10,
  2.0: 1.05,
  2.5: 1.00,
  3.0: 0.96,
};
