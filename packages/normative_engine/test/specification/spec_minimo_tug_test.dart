// REV: 1.0.0
// CHANGELOG:
// [1.0.0] - 2026-05
// - ADD: testes de piso mínimo de TUGs por cômodo (S-13).

import 'package:test/test.dart';
import 'package:normative_engine/normative_engine.dart';

const _residencial = PerfilInstalacao(escopo: EscopoProjeto.residencial);
const _comercial = PerfilInstalacao(escopo: EscopoProjeto.comercial);

bool _tug001(final List<Violacao> v) =>
    v.any((final e) => e.codigo == 'TUG_001');

void main() {
  const spec = SpecMinimoTUG();

  // ── aplicavelA ────────────────────────────────────────────────────────────

  group('aplicavelA —', () {
    test('Residencial → true', () => expect(spec.aplicavelA(_residencial), isTrue));
    test('Comercial → false', () => expect(spec.aplicavelA(_comercial), isFalse));
  });

  // ── Sala ──────────────────────────────────────────────────────────────────

  group('Sala —', () {
    test('10 m², 3 TUGs → válido (min = max(3, ceil(10/5)=2) = 3)', () {
      expect(
        spec.verificar((comodo: TipoComodo.sala, areaM2: 10.0, numTomadas: 3)),
        isEmpty,
      );
    });

    test('10 m², 2 TUGs → TUG_001 (min = 3)', () {
      expect(
        _tug001(spec.verificar((comodo: TipoComodo.sala, areaM2: 10.0, numTomadas: 2))),
        isTrue,
      );
    });

    test('20 m², 4 TUGs → válido (min = max(3, ceil(20/5)=4) = 4)', () {
      expect(
        spec.verificar((comodo: TipoComodo.sala, areaM2: 20.0, numTomadas: 4)),
        isEmpty,
      );
    });

    test('20 m², 3 TUGs → TUG_001 (min = 4)', () {
      expect(
        _tug001(spec.verificar((comodo: TipoComodo.sala, areaM2: 20.0, numTomadas: 3))),
        isTrue,
      );
    });

    test('Sala < 6 m², 1 TUG → válido (min = 1)', () {
      expect(
        spec.verificar((comodo: TipoComodo.sala, areaM2: 5.0, numTomadas: 1)),
        isEmpty,
      );
    });

    test('Sala < 6 m², 0 TUGs → TUG_001 (min = 1)', () {
      expect(
        _tug001(spec.verificar((comodo: TipoComodo.sala, areaM2: 5.0, numTomadas: 0))),
        isTrue,
      );
    });
  });

  // ── Quarto ────────────────────────────────────────────────────────────────

  group('Quarto —', () {
    test('10 m², 2 TUGs → válido (min = max(2, ceil(10/5)=2) = 2)', () {
      expect(
        spec.verificar((comodo: TipoComodo.quarto, areaM2: 10.0, numTomadas: 2)),
        isEmpty,
      );
    });

    test('10 m², 1 TUG → TUG_001 (min = 2)', () {
      expect(
        _tug001(spec.verificar((comodo: TipoComodo.quarto, areaM2: 10.0, numTomadas: 1))),
        isTrue,
      );
    });

    test('15 m², 3 TUGs → válido (min = max(2, ceil(15/5)=3) = 3)', () {
      expect(
        spec.verificar((comodo: TipoComodo.quarto, areaM2: 15.0, numTomadas: 3)),
        isEmpty,
      );
    });

    test('15 m², 2 TUGs → TUG_001 (min = 3)', () {
      expect(
        _tug001(spec.verificar((comodo: TipoComodo.quarto, areaM2: 15.0, numTomadas: 2))),
        isTrue,
      );
    });
  });

  // ── Cozinha ───────────────────────────────────────────────────────────────

  group('Cozinha —', () {
    test('7 m², 2 TUGs → válido (min = max(2, ceil(7/3.5)=2) = 2)', () {
      expect(
        spec.verificar((comodo: TipoComodo.cozinha, areaM2: 7.0, numTomadas: 2)),
        isEmpty,
      );
    });

    test('7 m², 1 TUG → TUG_001 (min = 2)', () {
      expect(
        _tug001(spec.verificar((comodo: TipoComodo.cozinha, areaM2: 7.0, numTomadas: 1))),
        isTrue,
      );
    });

    test('8 m², 3 TUGs → válido (min = max(2, ceil(8/3.5)=3) = 3)', () {
      expect(
        spec.verificar((comodo: TipoComodo.cozinha, areaM2: 8.0, numTomadas: 3)),
        isEmpty,
      );
    });

    test('8 m², 2 TUGs → TUG_001 (min = 3)', () {
      expect(
        _tug001(spec.verificar((comodo: TipoComodo.cozinha, areaM2: 8.0, numTomadas: 2))),
        isTrue,
      );
    });
  });

  // ── Banheiro ──────────────────────────────────────────────────────────────

  group('Banheiro —', () {
    test('Qualquer área, 1 TUG → válido (min = 1)', () {
      expect(
        spec.verificar((comodo: TipoComodo.banheiro, areaM2: 4.0, numTomadas: 1)),
        isEmpty,
      );
    });

    test('Qualquer área, 0 TUGs → TUG_001 (min = 1)', () {
      expect(
        _tug001(spec.verificar((comodo: TipoComodo.banheiro, areaM2: 4.0, numTomadas: 0))),
        isTrue,
      );
    });
  });

  // ── Área de serviço ───────────────────────────────────────────────────────

  group('Área de serviço —', () {
    test('5 m², 2 TUGs → válido (min = max(2, ceil(5/3.5)=2) = 2)', () {
      expect(
        spec.verificar((comodo: TipoComodo.areaServico, areaM2: 5.0, numTomadas: 2)),
        isEmpty,
      );
    });

    test('5 m², 1 TUG → TUG_001 (min = 2)', () {
      expect(
        _tug001(spec.verificar((comodo: TipoComodo.areaServico, areaM2: 5.0, numTomadas: 1))),
        isTrue,
      );
    });
  });

  // ── Corredor ──────────────────────────────────────────────────────────────

  group('Corredor —', () {
    test('2 m², 1 TUG → válido (area ≥ 1.5, min = 1)', () {
      expect(
        spec.verificar((comodo: TipoComodo.corredor, areaM2: 2.0, numTomadas: 1)),
        isEmpty,
      );
    });

    test('2 m², 0 TUGs → TUG_001 (min = 1)', () {
      expect(
        _tug001(spec.verificar((comodo: TipoComodo.corredor, areaM2: 2.0, numTomadas: 0))),
        isTrue,
      );
    });

    test('1 m², 0 TUGs → sem violação (area < 1.5, sem mínimo normativo)', () {
      expect(
        spec.verificar((comodo: TipoComodo.corredor, areaM2: 1.0, numTomadas: 0)),
        isEmpty,
      );
    });
  });

  // ── Garagem e Varanda ─────────────────────────────────────────────────────

  group('Garagem e Varanda —', () {
    test('Garagem, 1 TUG → válido (min = 1)', () {
      expect(
        spec.verificar((comodo: TipoComodo.garagem, areaM2: 20.0, numTomadas: 1)),
        isEmpty,
      );
    });

    test('Garagem, 0 TUGs → TUG_001 (min = 1)', () {
      expect(
        _tug001(spec.verificar((comodo: TipoComodo.garagem, areaM2: 20.0, numTomadas: 0))),
        isTrue,
      );
    });

    test('Varanda, 1 TUG → válido (min = 1)', () {
      expect(
        spec.verificar((comodo: TipoComodo.varanda, areaM2: 6.0, numTomadas: 1)),
        isEmpty,
      );
    });

    test('Varanda, 0 TUGs → TUG_001 (min = 1)', () {
      expect(
        _tug001(spec.verificar((comodo: TipoComodo.varanda, areaM2: 6.0, numTomadas: 0))),
        isTrue,
      );
    });
  });

  // ── Metadata da violação ──────────────────────────────────────────────────

  group('Violação TUG_001 —', () {
    test('Código correto', () {
      final v = spec.verificar((comodo: TipoComodo.sala, areaM2: 10.0, numTomadas: 1));
      expect(v.first.codigo, equals('TUG_001'));
    });

    test('Referência normativa 9.5.4.1.2', () {
      final v = spec.verificar((comodo: TipoComodo.sala, areaM2: 10.0, numTomadas: 1));
      expect(v.first.referencia, contains('9.5.4.1.2'));
    });

    test('Apenas uma violação por cômodo', () {
      final v = spec.verificar((comodo: TipoComodo.sala, areaM2: 20.0, numTomadas: 0));
      expect(v.length, equals(1));
    });
  });
}
