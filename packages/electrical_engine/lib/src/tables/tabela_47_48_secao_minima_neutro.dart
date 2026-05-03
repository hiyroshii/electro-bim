// REV: 1.0.1
// CHANGELOG:
// [1.0.1] - 2026-05
// - FIX: const Map → final Map — double não pode ser chave em const map no Dart.
// [1.0.0] - 2026-04
// - ADD: seção mínima dos condutores de fase (Tabela 47).
// - ADD: seção reduzida do condutor neutro (Tabela 48).

import '../enums/material.dart';
import '../enums/tag_circuito.dart';

/// Tabela 47 — Seção mínima dos condutores de fase.
///
/// Fonte normativa: doc/nbr5410/6_2_6_condutores_fase_neutro.md
/// Rastreabilidade: NBR 5410:2004 — Tabela 47, Seção 6.2.6.1.1.
///
/// Chave: (TagCircuito, Material) → seção mínima em mm².
///
/// Notas normativas:
/// - Circuitos de força incluem tomadas (TUG e TUE).
/// - Alumínio mínimo de 16 mm² em todos os casos (reforçado por 6.2.3.8).
/// - Sinalização/controle fora do escopo do engine de dimensionamento.
final Map<(TagCircuito, Material), double> tabelaSecaoMinima = {
  // Iluminação
  (TagCircuito.il, Material.cobre): 1.5,
  (TagCircuito.il, Material.aluminio): 16.0,
  // Tomada de uso geral (força)
  (TagCircuito.tug, Material.cobre): 2.5,
  (TagCircuito.tug, Material.aluminio): 16.0,
  // Tomada de uso específico (força)
  (TagCircuito.tue, Material.cobre): 2.5,
  (TagCircuito.tue, Material.aluminio): 16.0,
  // Alimentadores — seção mínima determinada pelo cálculo (ampacidade + ΔV)
  // Piso normativo explícito da Tab. 47 não se aplica a MED/QDG/QD
  // para instalações fixas com cabos isolados → resultado do cálculo prevalece.
  // Registrado como 0,0 para não bloquear seções calculadas.
  (TagCircuito.med, Material.cobre): 0.0,
  (TagCircuito.med, Material.aluminio): 16.0,
  (TagCircuito.qdg, Material.cobre): 0.0,
  (TagCircuito.qdg, Material.aluminio): 16.0,
  (TagCircuito.qd, Material.cobre): 0.0,
  (TagCircuito.qd, Material.aluminio): 16.0,
};

/// Tabela 48 — Seção reduzida do condutor neutro.
///
/// Fonte normativa: doc/nbr5410/6_2_6_condutores_fase_neutro.md
/// Rastreabilidade: NBR 5410:2004 — Tabela 48, Seção 6.2.6.2.6.
///
/// Aplicável apenas quando as três condições forem atendidas (6.2.6.2.6):
/// a) Circuito equilibrado em serviço normal.
/// b) Taxa de 3ª harmônica ≤ 15%.
/// c) Neutro protegido contra sobrecorrentes (5.3.2.2).
///
/// Para fases ≤ 25 mm²: neutro = fases (sem redução permitida).
/// Fase e neutro devem ser do mesmo material.
///
/// Chave: seção das fases (mm²) → seção mínima do neutro (mm²).
final Map<double, double> tabelaNeutroReduzido = {
  35.0: 25.0,
  50.0: 25.0,
  70.0: 35.0,
  95.0: 50.0,
  120.0: 70.0,
  150.0: 70.0,
  185.0: 95.0,
  240.0: 120.0,
  300.0: 150.0,
  400.0: 185.0,
};
