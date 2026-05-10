// REV: 1.0.0
// CHANGELOG:
// [1.0.0] - 2026-05
// - ADD: tabela de reatâncias Xi por seção e material (Ω/m a 50 Hz).

import '../domain/condutor/material.dart';

/// Tabela Xi — Reatância indutiva de condutores (Ω/m) a 50 Hz.
///
/// Rastreabilidade: NBR 5410:2004 — 6.2.7.4; IEC 60364-5-52 Tabela B.52.16.
///
/// Condições de referência:
/// - Frequência: 50 Hz.
/// - Instalação em eletroduto ou cabo multipolar (geometria fechada).
/// - Valores em Ω/m por condutor.
///
/// A reatância depende principalmente da geometria do cabo (diâmetro),
/// não do material. Os valores de alumínio coincidem com os de cobre para
/// as mesmas seções — a distinção na chave preserva rastreabilidade e
/// permite eventual ajuste futuro por norma específica de produto.
///
/// Chave: (seção mm², Material)
/// Valor: Xi em Ω/m

final Map<(double, Material), double> tabelaXi = {
  // ── Cobre ─────────────────────────────────────────────────────────────────
  (0.5,    Material.cobre): 0.000130,
  (0.75,   Material.cobre): 0.000125,
  (1.0,    Material.cobre): 0.000120,
  (1.5,    Material.cobre): 0.000115,
  (2.5,    Material.cobre): 0.000110,
  (4.0,    Material.cobre): 0.000107,
  (6.0,    Material.cobre): 0.000100,
  (10.0,   Material.cobre): 0.000094,
  (16.0,   Material.cobre): 0.000090,
  (25.0,   Material.cobre): 0.000086,
  (35.0,   Material.cobre): 0.000083,
  (50.0,   Material.cobre): 0.000080,
  (70.0,   Material.cobre): 0.000080,
  (95.0,   Material.cobre): 0.000078,
  (120.0,  Material.cobre): 0.000077,
  (150.0,  Material.cobre): 0.000077,
  (185.0,  Material.cobre): 0.000076,
  (240.0,  Material.cobre): 0.000075,
  (300.0,  Material.cobre): 0.000075,
  (400.0,  Material.cobre): 0.000074,
  (500.0,  Material.cobre): 0.000074,
  (630.0,  Material.cobre): 0.000073,
  (800.0,  Material.cobre): 0.000073,
  (1000.0, Material.cobre): 0.000072,

  // ── Alumínio ──────────────────────────────────────────────────────────────
  // Tabelas de alumínio iniciam em 16 mm² (mínimo normativo).
  (16.0,   Material.aluminio): 0.000090,
  (25.0,   Material.aluminio): 0.000086,
  (35.0,   Material.aluminio): 0.000083,
  (50.0,   Material.aluminio): 0.000080,
  (70.0,   Material.aluminio): 0.000080,
  (95.0,   Material.aluminio): 0.000078,
  (120.0,  Material.aluminio): 0.000077,
  (150.0,  Material.aluminio): 0.000077,
  (185.0,  Material.aluminio): 0.000076,
  (240.0,  Material.aluminio): 0.000075,
  (300.0,  Material.aluminio): 0.000075,
  (400.0,  Material.aluminio): 0.000074,
  (500.0,  Material.aluminio): 0.000074,
  (630.0,  Material.aluminio): 0.000073,
  (800.0,  Material.aluminio): 0.000073,
  (1000.0, Material.aluminio): 0.000072,
};
