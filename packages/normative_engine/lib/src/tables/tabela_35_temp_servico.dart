// REV: 1.0.0
// CHANGELOG:
// [1.0.0] - 2026-04
// - ADD: temperaturas máximas de serviço por isolação (Tabela 35).

import '../domain/condutor/isolacao.dart';

/// Tabela 35 — Temperaturas máximas admissíveis nos condutores.
///
/// Fonte normativa: doc/nbr5410/6_2_5_capacidades_conducao.md
/// Rastreabilidade: NBR 5410:2004 — Tabela 35, Seção 6.2.5.1.1.
///
/// Temperatura máxima em serviço contínuo (°C) por tipo de isolação.
final Map<Isolacao, int> tabelaTempMaxServico = {
  Isolacao.pvc: 70,
  Isolacao.xlpe: 90,
  Isolacao.epr: 90,
};

/// Temperatura de referência das tabelas de ampacidade para instalações
/// não-subterrâneas (ar ambiente).
/// Rastreabilidade: NBR 5410:2004 — 6.2.5.3.2.
const int tempRefAr = 30;

/// Temperatura de referência das tabelas de ampacidade para instalações
/// subterrâneas (temperatura do solo — Método D).
/// Rastreabilidade: NBR 5410:2004 — 6.2.5.3.2.
const int tempRefSolo = 20;
