// REV: 1.0.0
// CHANGELOG:
// [1.0.0] - 2026-05
// - ADD: testes de carga mínima residencial (P-6, T-13, T-14).

import 'package:test/test.dart';
import 'package:normative_engine/normative_engine.dart';

// ignore: implementation_imports
import 'package:normative_engine/src/tables/habitacao/tabela_carga_iluminacao.dart';
// ignore: implementation_imports
import 'package:normative_engine/src/tables/habitacao/tabela_potencia_tug.dart';

void main() {
  const proc = ProcCargaResidencial();

  // ── T-13: tabela_carga_iluminacao ─────────────────────────────────────────

  group('T-13 — carga IL por ponto —', () {
    test('Sala — 100 VA', () => expect(cargaIlPorPonto(TipoComodo.sala), equals(100.0)));
    test('Quarto — 100 VA', () => expect(cargaIlPorPonto(TipoComodo.quarto), equals(100.0)));
    test('Cozinha — 100 VA', () => expect(cargaIlPorPonto(TipoComodo.cozinha), equals(100.0)));
    test('Banheiro — 100 VA', () => expect(cargaIlPorPonto(TipoComodo.banheiro), equals(100.0)));
    test('Área de serviço — 100 VA', () => expect(cargaIlPorPonto(TipoComodo.areaServico), equals(100.0)));
    test('Corredor — 100 VA', () => expect(cargaIlPorPonto(TipoComodo.corredor), equals(100.0)));

    test('Todos os cômodos cobertos', () {
      for (final comodo in TipoComodo.values) {
        expect(
          () => cargaIlPorPonto(comodo),
          returnsNormally,
          reason: '$comodo ausente na T-13',
        );
      }
    });
  });

  // ── T-14: tabela_potencia_tug ─────────────────────────────────────────────

  group('T-14 — carga TUG por tomada —', () {
    test('Sala — 100 VA', () => expect(cargaTugPorPonto(TipoComodo.sala), equals(100.0)));
    test('Quarto — 100 VA', () => expect(cargaTugPorPonto(TipoComodo.quarto), equals(100.0)));
    test('Corredor — 100 VA', () => expect(cargaTugPorPonto(TipoComodo.corredor), equals(100.0)));
    test('Cozinha — 600 VA', () => expect(cargaTugPorPonto(TipoComodo.cozinha), equals(600.0)));
    test('Banheiro — 600 VA', () => expect(cargaTugPorPonto(TipoComodo.banheiro), equals(600.0)));
    test('Área de serviço — 600 VA', () => expect(cargaTugPorPonto(TipoComodo.areaServico), equals(600.0)));
    test('Garagem — 600 VA', () => expect(cargaTugPorPonto(TipoComodo.garagem), equals(600.0)));
    test('Varanda — 600 VA', () => expect(cargaTugPorPonto(TipoComodo.varanda), equals(600.0)));

    test('Todos os cômodos cobertos', () {
      for (final comodo in TipoComodo.values) {
        expect(
          () => cargaTugPorPonto(comodo),
          returnsNormally,
          reason: '$comodo ausente na T-14',
        );
      }
    });
  });

  // ── P-6 — IL ─────────────────────────────────────────────────────────────

  group('P-6 — IL —', () {
    test('Sala, 3 pontos → 300 VA', () {
      expect(
        proc.resolver((comodo: TipoComodo.sala, tag: TagCircuito.il, quantidade: 3)),
        equals(300.0),
      );
    });

    test('Quarto, 2 pontos → 200 VA', () {
      expect(
        proc.resolver((comodo: TipoComodo.quarto, tag: TagCircuito.il, quantidade: 2)),
        equals(200.0),
      );
    });

    test('Corredor, 1 ponto → 100 VA', () {
      expect(
        proc.resolver((comodo: TipoComodo.corredor, tag: TagCircuito.il, quantidade: 1)),
        equals(100.0),
      );
    });

    test('Cozinha, 2 pontos → 200 VA', () {
      expect(
        proc.resolver((comodo: TipoComodo.cozinha, tag: TagCircuito.il, quantidade: 2)),
        equals(200.0),
      );
    });

    test('Banheiro, 1 ponto → 100 VA', () {
      expect(
        proc.resolver((comodo: TipoComodo.banheiro, tag: TagCircuito.il, quantidade: 1)),
        equals(100.0),
      );
    });
  });

  // ── P-6 — TUG ────────────────────────────────────────────────────────────

  group('P-6 — TUG —', () {
    test('Sala, 4 tomadas → 400 VA', () {
      expect(
        proc.resolver((comodo: TipoComodo.sala, tag: TagCircuito.tug, quantidade: 4)),
        equals(400.0),
      );
    });

    test('Quarto, 2 tomadas → 200 VA', () {
      expect(
        proc.resolver((comodo: TipoComodo.quarto, tag: TagCircuito.tug, quantidade: 2)),
        equals(200.0),
      );
    });

    test('Cozinha, 3 tomadas → 1800 VA', () {
      expect(
        proc.resolver((comodo: TipoComodo.cozinha, tag: TagCircuito.tug, quantidade: 3)),
        equals(1800.0),
      );
    });

    test('Banheiro, 1 tomada → 600 VA', () {
      expect(
        proc.resolver((comodo: TipoComodo.banheiro, tag: TagCircuito.tug, quantidade: 1)),
        equals(600.0),
      );
    });

    test('Área de serviço, 2 tomadas → 1200 VA', () {
      expect(
        proc.resolver((comodo: TipoComodo.areaServico, tag: TagCircuito.tug, quantidade: 2)),
        equals(1200.0),
      );
    });

    test('Garagem, 1 tomada → 600 VA', () {
      expect(
        proc.resolver((comodo: TipoComodo.garagem, tag: TagCircuito.tug, quantidade: 1)),
        equals(600.0),
      );
    });

    test('Varanda, 1 tomada → 600 VA', () {
      expect(
        proc.resolver((comodo: TipoComodo.varanda, tag: TagCircuito.tug, quantidade: 1)),
        equals(600.0),
      );
    });
  });

  // ── P-6 — alimentadores e TUE ────────────────────────────────────────────

  group('P-6 — alimentadores e TUE —', () {
    test('QDG → 0 VA (sem piso por ponto)', () {
      expect(
        proc.resolver((comodo: TipoComodo.sala, tag: TagCircuito.qdg, quantidade: 1)),
        equals(0.0),
      );
    });

    test('QD → 0 VA', () {
      expect(
        proc.resolver((comodo: TipoComodo.sala, tag: TagCircuito.qd, quantidade: 1)),
        equals(0.0),
      );
    });

    test('MED → 0 VA', () {
      expect(
        proc.resolver((comodo: TipoComodo.sala, tag: TagCircuito.med, quantidade: 1)),
        equals(0.0),
      );
    });

    test('TUE → 0 VA (potência declarada pelo projetista)', () {
      expect(
        proc.resolver((comodo: TipoComodo.cozinha, tag: TagCircuito.tue, quantidade: 1)),
        equals(0.0),
      );
    });
  });
}
