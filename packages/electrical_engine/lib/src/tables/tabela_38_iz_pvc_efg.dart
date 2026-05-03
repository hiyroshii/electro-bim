// REV: 1.0.1
// CHANGELOG:
// [1.0.1] - 2026-05
// - FIX: const Map → final Map — double não pode ser chave em const map no Dart.
// [1.0.0] - 2026-04
// - ADD: ampacidade PVC métodos E/F/G, cobre e alumínio (Tabela 38).

import '../enums/metodo_instalacao.dart';
import '../enums/arranjo_condutores.dart';

/// Tabela 38 — Capacidade de condução de corrente (A).
/// Isolação PVC — Métodos E, F, G.
///
/// Fonte normativa: doc/nbr5410/6_2_5_tabela38_amp_metodos_E_F_G_pvc.md
/// Rastreabilidade: NBR 5410:2004 — Tabela 38, Seção 6.2.5.2.2.
///
/// Condições de referência:
/// - Isolação: PVC — temperatura máxima no condutor: 70 °C.
/// - Temperatura de referência: 30 °C (ar).
///
/// Chave: (MetodoInstalacao, int condutoresCarregados, ArranjoCondutores?)
/// - Método E: ArranjoCondutores null (cabo multipolar).
/// - Método F: ArranjoCondutores obrigatório.
/// - Método G: ArranjoCondutores obrigatório (espacado*).
/// Valor: Map<seção mm², Iz em A>

// ── Cobre ─────────────────────────────────────────────────────────────────

final Map<(MetodoInstalacao, int, ArranjoCondutores?), Map<double, double>>
    tabelaIzCobrePvcEFG = {
  (MetodoInstalacao.e, 2, null): {
    0.5: 11, 0.75: 14, 1: 17, 1.5: 22, 2.5: 30, 4: 40, 6: 51,
    10: 70, 16: 94, 25: 119, 35: 148, 50: 180, 70: 232, 95: 282,
    120: 328, 150: 379, 185: 434, 240: 514, 300: 593, 400: 715,
    500: 826, 630: 958, 800: 1118, 1000: 1292,
  },
  (MetodoInstalacao.e, 3, null): {
    0.5: 9, 0.75: 12, 1: 14, 1.5: 18.5, 2.5: 25, 4: 34, 6: 43,
    10: 60, 16: 80, 25: 101, 35: 126, 50: 153, 70: 196, 95: 238,
    120: 276, 150: 319, 185: 364, 240: 430, 300: 497, 400: 597,
    500: 689, 630: 798, 800: 930, 1000: 1073,
  },
  (MetodoInstalacao.f, 2, ArranjoCondutores.justaposto2c): {
    0.5: 11, 0.75: 14, 1: 17, 1.5: 22, 2.5: 31, 4: 41, 6: 53,
    10: 73, 16: 99, 25: 131, 35: 162, 50: 196, 70: 251, 95: 304,
    120: 352, 150: 406, 185: 463, 240: 546, 300: 629, 400: 754,
    500: 868, 630: 1005, 800: 1169, 1000: 1346,
  },
  (MetodoInstalacao.f, 3, ArranjoCondutores.trifolio): {
    0.5: 8, 0.75: 11, 1: 13, 1.5: 17, 2.5: 24, 4: 33, 6: 43,
    10: 60, 16: 82, 25: 110, 35: 137, 50: 167, 70: 216, 95: 264,
    120: 308, 150: 356, 185: 409, 240: 485, 300: 561, 400: 656,
    500: 749, 630: 855, 800: 971, 1000: 1079,
  },
  (MetodoInstalacao.f, 3, ArranjoCondutores.planoJustaposto): {
    0.5: 9, 0.75: 11, 1: 14, 1.5: 18, 2.5: 25, 4: 34, 6: 45,
    10: 63, 16: 85, 25: 114, 35: 143, 50: 174, 70: 225, 95: 275,
    120: 321, 150: 372, 185: 427, 240: 507, 300: 587, 400: 689,
    500: 789, 630: 905, 800: 1119, 1000: 1296,
  },
  (MetodoInstalacao.g, 3, ArranjoCondutores.espacadoHorizontal): {
    0.5: 12, 0.75: 16, 1: 19, 1.5: 24, 2.5: 34, 4: 45, 6: 59,
    10: 81, 16: 110, 25: 146, 35: 181, 50: 219, 70: 281, 95: 341,
    120: 396, 150: 456, 185: 521, 240: 615, 300: 709, 400: 852,
    500: 982, 630: 1138, 800: 1325, 1000: 1528,
  },
  (MetodoInstalacao.g, 3, ArranjoCondutores.espacadoVertical): {
    0.5: 10, 0.75: 13, 1: 16, 1.5: 21, 2.5: 29, 4: 39, 6: 51,
    10: 71, 16: 97, 25: 130, 35: 162, 50: 197, 70: 254, 95: 311,
    120: 362, 150: 419, 185: 480, 240: 569, 300: 659, 400: 795,
    500: 920, 630: 1070, 800: 1251, 1000: 1448,
  },
};

// ── Alumínio — seção mínima 16 mm² ────────────────────────────────────────

final Map<(MetodoInstalacao, int, ArranjoCondutores?), Map<double, double>>
    tabelaIzAluminioPvcEFG = {
  (MetodoInstalacao.e, 2, null): {
    16: 73, 25: 89, 35: 111, 50: 135, 70: 173, 95: 210, 120: 244,
    150: 282, 185: 322, 240: 380, 300: 439, 400: 528, 500: 608,
    630: 705, 800: 822, 1000: 948,
  },
  (MetodoInstalacao.e, 3, null): {
    16: 61, 25: 78, 35: 96, 50: 117, 70: 150, 95: 183, 120: 212,
    150: 245, 185: 280, 240: 330, 300: 381, 400: 458, 500: 528,
    630: 613, 800: 714, 1000: 823,
  },
  (MetodoInstalacao.f, 2, ArranjoCondutores.justaposto2c): {
    16: 73, 25: 98, 35: 122, 50: 149, 70: 192, 95: 235, 120: 273,
    150: 316, 185: 363, 240: 430, 300: 497, 400: 600, 500: 694,
    630: 808, 800: 944, 1000: 1092,
  },
  (MetodoInstalacao.f, 3, ArranjoCondutores.trifolio): {
    16: 62, 25: 84, 35: 105, 50: 128, 70: 166, 95: 203, 120: 237,
    150: 274, 185: 315, 240: 375, 300: 434, 400: 526, 500: 610,
    630: 711, 800: 832, 1000: 965,
  },
  (MetodoInstalacao.f, 3, ArranjoCondutores.planoJustaposto): {
    16: 65, 25: 87, 35: 109, 50: 133, 70: 173, 95: 212, 120: 247,
    150: 287, 185: 330, 240: 392, 300: 455, 400: 552, 500: 640,
    630: 640, 800: 875, 1000: 1015,
  },
  (MetodoInstalacao.g, 3, ArranjoCondutores.espacadoHorizontal): {
    16: 84, 25: 112, 35: 139, 50: 169, 70: 217, 95: 265, 120: 308,
    150: 356, 185: 407, 240: 482, 300: 557, 400: 671, 500: 775,
    630: 775, 800: 1050, 1000: 1213,
  },
  (MetodoInstalacao.g, 3, ArranjoCondutores.espacadoVertical): {
    16: 73, 25: 99, 35: 124, 50: 152, 70: 196, 95: 241, 120: 282,
    150: 327, 185: 376, 240: 447, 300: 519, 400: 629, 500: 730,
    630: 730, 800: 1000, 1000: 1161,
  },
};
