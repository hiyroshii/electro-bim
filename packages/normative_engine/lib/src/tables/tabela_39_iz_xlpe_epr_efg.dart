// REV: 1.0.1
// CHANGELOG:
// [1.0.1] - 2026-05
// - FIX: const Map → final Map — double não pode ser chave em const map no Dart.
// [1.0.0] - 2026-04
// - ADD: ampacidade EPR/XLPE métodos E/F/G, cobre e alumínio (Tabela 39).

import '../enums/metodo_instalacao.dart';
import '../enums/arranjo_condutores.dart';

/// Tabela 39 — Capacidade de condução de corrente (A).
/// Isolação EPR ou XLPE — Métodos E, F, G.
///
/// Fonte normativa: doc/nbr5410/6_2_5_tabela39_amp_metodos_E_F_G_epr_xlpe.md
/// Rastreabilidade: NBR 5410:2004 — Tabela 39, Seção 6.2.5.2.2.
///
/// Condições de referência:
/// - Isolação: EPR ou XLPE — temperatura máxima no condutor: 90 °C.
/// - Temperatura de referência: 30 °C (ar).
/// - EPR e XLPE compartilham esta tabela (mesmas colunas na norma).
///
/// Chave: (MetodoInstalacao, int condutoresCarregados, ArranjoCondutores?)
/// - Método E: ArranjoCondutores null (cabo multipolar).
/// - Método F: ArranjoCondutores obrigatório.
/// - Método G: ArranjoCondutores obrigatório (espacado*).
/// Valor: Map<seção mm², Iz em A>

// ── Cobre ─────────────────────────────────────────────────────────────────

final Map<(MetodoInstalacao, int, ArranjoCondutores?), Map<double, double>>
    tabelaIzCobreXlpeEprEFG = {
  (MetodoInstalacao.e, 2, null): {
    0.5: 13, 0.75: 17, 1: 21, 1.5: 26, 2.5: 36, 4: 49, 6: 63,
    10: 86, 16: 115, 25: 149, 35: 185, 50: 225, 70: 289, 95: 352,
    120: 410, 150: 473, 185: 542, 240: 641, 300: 741, 400: 892,
    500: 1030, 630: 1196, 800: 1396, 1000: 1613,
  },
  (MetodoInstalacao.e, 3, null): {
    0.5: 12, 0.75: 15, 1: 18, 1.5: 23, 2.5: 32, 4: 42, 6: 54,
    10: 75, 16: 100, 25: 127, 35: 158, 50: 192, 70: 246, 95: 298,
    120: 346, 150: 399, 185: 456, 240: 538, 300: 621, 400: 745,
    500: 859, 630: 995, 800: 1159, 1000: 1336,
  },
  (MetodoInstalacao.f, 2, ArranjoCondutores.justaposto2c): {
    0.5: 13, 0.75: 17, 1: 21, 1.5: 27, 2.5: 37, 4: 50, 6: 65,
    10: 90, 16: 121, 25: 161, 35: 200, 50: 242, 70: 310, 95: 377,
    120: 437, 150: 504, 185: 575, 240: 679, 300: 783, 400: 940,
    500: 1083, 630: 1254, 800: 1460, 1000: 1683,
  },
  (MetodoInstalacao.f, 3, ArranjoCondutores.trifolio): {
    0.5: 10, 0.75: 13, 1: 16, 1.5: 21, 2.5: 29, 4: 40, 6: 53,
    10: 74, 16: 101, 25: 135, 35: 169, 50: 207, 70: 268, 95: 328,
    120: 383, 150: 444, 185: 510, 240: 607, 300: 703, 400: 823,
    500: 946, 630: 1088, 800: 1252, 1000: 1420,
  },
  (MetodoInstalacao.f, 3, ArranjoCondutores.planoJustaposto): {
    0.5: 10, 0.75: 14, 1: 17, 1.5: 22, 2.5: 30, 4: 42, 6: 55,
    10: 77, 16: 105, 25: 141, 35: 176, 50: 216, 70: 279, 95: 342,
    120: 400, 150: 464, 185: 533, 240: 634, 300: 736, 400: 868,
    500: 998, 630: 1151, 800: 1328, 1000: 1511,
  },
  (MetodoInstalacao.g, 3, ArranjoCondutores.espacadoHorizontal): {
    0.5: 15, 0.75: 19, 1: 23, 1.5: 30, 2.5: 41, 4: 56, 6: 73,
    10: 101, 16: 137, 25: 182, 35: 226, 50: 275, 70: 353, 95: 430,
    120: 500, 150: 577, 185: 661, 240: 781, 300: 902, 400: 1085,
    500: 1253, 630: 1454, 800: 1696, 1000: 1958,
  },
  (MetodoInstalacao.g, 3, ArranjoCondutores.espacadoVertical): {
    0.5: 12, 0.75: 16, 1: 19, 1.5: 25, 2.5: 35, 4: 48, 6: 63,
    10: 88, 16: 120, 25: 161, 35: 201, 50: 246, 70: 318, 95: 389,
    120: 454, 150: 527, 185: 605, 240: 719, 300: 833, 400: 1008,
    500: 1169, 630: 1362, 800: 1595, 1000: 1849,
  },
};

// ── Alumínio — seção mínima 16 mm² ────────────────────────────────────────

final Map<(MetodoInstalacao, int, ArranjoCondutores?), Map<double, double>>
    tabelaIzAluminioXlpeEprEFG = {
  (MetodoInstalacao.e, 2, null): {
    16: 91, 25: 108, 35: 135, 50: 164, 70: 211, 95: 257, 120: 300,
    150: 346, 185: 397, 240: 470, 300: 543, 400: 654, 500: 756,
    630: 879, 800: 1026, 1000: 1186,
  },
  (MetodoInstalacao.e, 3, null): {
    16: 77, 25: 97, 35: 120, 50: 146, 70: 187, 95: 227, 120: 263,
    150: 304, 185: 347, 240: 409, 300: 471, 400: 566, 500: 652,
    630: 755, 800: 879, 1000: 1012,
  },
  (MetodoInstalacao.f, 2, ArranjoCondutores.justaposto2c): {
    16: 90, 25: 121, 35: 150, 50: 184, 70: 237, 95: 289, 120: 337,
    150: 389, 185: 447, 240: 530, 300: 613, 400: 740, 500: 856,
    630: 996, 800: 1164, 1000: 1347,
  },
  (MetodoInstalacao.f, 3, ArranjoCondutores.trifolio): {
    16: 76, 25: 103, 35: 129, 50: 159, 70: 206, 95: 253, 120: 296,
    150: 343, 185: 395, 240: 471, 300: 547, 400: 663, 500: 770,
    630: 899, 800: 1056, 1000: 1226,
  },
  (MetodoInstalacao.f, 3, ArranjoCondutores.planoJustaposto): {
    16: 79, 25: 107, 35: 135, 50: 165, 70: 215, 95: 264, 120: 308,
    150: 358, 185: 413, 240: 492, 300: 571, 400: 694, 500: 806,
    630: 942, 800: 1106, 1000: 1285,
  },
  (MetodoInstalacao.g, 3, ArranjoCondutores.espacadoHorizontal): {
    16: 103, 25: 138, 35: 172, 50: 210, 70: 271, 95: 332, 120: 387,
    150: 448, 185: 515, 240: 611, 300: 708, 400: 856, 500: 991,
    630: 1154, 800: 1351, 1000: 1565,
  },
  (MetodoInstalacao.g, 3, ArranjoCondutores.espacadoVertical): {
    16: 90, 25: 122, 35: 153, 50: 188, 70: 244, 95: 300, 120: 351,
    150: 408, 185: 470, 240: 561, 300: 652, 400: 792, 500: 921,
    630: 1077, 800: 1266, 1000: 1472,
  },
};
