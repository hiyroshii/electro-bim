// REV: 1.0.1
// CHANGELOG:
// [1.0.1] - 2026-05
// - FIX: const Map → final Map — double não pode ser chave em const map no Dart.
// [1.0.0] - 2026-04
// - ADD: fatores de correção de temperatura FCT (Tabela 40).

import '../enums/isolacao.dart';

/// Tabela 40 — Fatores de correção de temperatura (FCT).
///
/// Fonte normativa: doc/nbr5410/6_2_5_tabela40_fct_temperatura.md
/// Rastreabilidade: NBR 5410:2004 — Tabela 40, Seção 6.2.5.3.
///
/// Temperaturas de referência:
/// - Instalações não-subterrâneas (ar): 30 °C.
/// - Instalações subterrâneas (solo — Método D): 20 °C.
///
/// null = temperatura não admissível para essa isolação.
/// Distingue "fator zero" de "condição proibida" — ver spec_combinacoes.
///
/// Rastreabilidade: EPR usa os mesmos fatores de XLPE (colunas idênticas
/// na norma — mesma temperatura máxima de serviço de 90 °C).

// ── Instalações não-subterrâneas — referência 30 °C ──────────────────────

final Map<Isolacao, Map<int, double?>> fctAr = {
  Isolacao.pvc: {
    10: 1.22, 15: 1.17, 20: 1.12, 25: 1.06, 30: 1.00,
    35: 0.94, 40: 0.87, 45: 0.79, 50: 0.71, 55: 0.61, 60: 0.50,
    65: null, 70: null, 75: null, 80: null,
  },
  Isolacao.xlpe: {
    10: 1.15, 15: 1.12, 20: 1.08, 25: 1.04, 30: 1.00,
    35: 0.96, 40: 0.91, 45: 0.87, 50: 0.82, 55: 0.76, 60: 0.71,
    65: 0.65, 70: 0.58, 75: 0.50, 80: 0.41,
  },
  Isolacao.epr: {
    10: 1.15, 15: 1.12, 20: 1.08, 25: 1.04, 30: 1.00,
    35: 0.96, 40: 0.91, 45: 0.87, 50: 0.82, 55: 0.76, 60: 0.71,
    65: 0.65, 70: 0.58, 75: 0.50, 80: 0.41,
  },
};

// ── Instalações subterrâneas (solo) — referência 20 °C ───────────────────

final Map<Isolacao, Map<int, double?>> fctSolo = {
  Isolacao.pvc: {
    10: 1.10, 15: 1.05, 20: 1.00, 25: 0.95, 30: 0.89,
    35: 0.84, 40: 0.77, 45: 0.71, 50: 0.63, 55: 0.55, 60: 0.45,
    65: null, 70: null, 75: null, 80: null,
  },
  Isolacao.xlpe: {
    10: 1.07, 15: 1.04, 20: 1.00, 25: 0.96, 30: 0.93,
    35: 0.89, 40: 0.85, 45: 0.80, 50: 0.76, 55: 0.71, 60: 0.65,
    65: 0.60, 70: 0.53, 75: 0.46, 80: 0.38,
  },
  Isolacao.epr: {
    10: 1.07, 15: 1.04, 20: 1.00, 25: 0.96, 30: 0.93,
    35: 0.89, 40: 0.85, 45: 0.80, 50: 0.76, 55: 0.71, 60: 0.65,
    65: 0.60, 70: 0.53, 75: 0.46, 80: 0.38,
  },
};
