// REV: 1.0.0
// CHANGELOG:
// [1.0.0] - 2026-05
// - ADD: testes de piso mínimo de pontos IL por cômodo (S-12).

import 'package:test/test.dart';
import 'package:normative_engine/normative_engine.dart';

const _residencial = PerfilInstalacao(escopo: EscopoProjeto.residencial);
const _industrial = PerfilInstalacao(escopo: EscopoProjeto.industrial);

void main() {
  const spec = SpecMinimoIL();

  // ── aplicavelA ────────────────────────────────────────────────────────────

  group('aplicavelA —', () {
    test('Residencial → true', () {
      expect(spec.aplicavelA(_residencial), isTrue);
    });

    test('Industrial → false', () {
      expect(spec.aplicavelA(_industrial), isFalse);
    });
  });

  // ── Conforme ──────────────────────────────────────────────────────────────

  group('Conforme —', () {
    test('4 m², 1 ponto → válido (min = 1)', () {
      expect(
        spec.verificar((comodo: TipoComodo.sala, areaM2: 4.0, numPontos: 1)),
        isEmpty,
      );
    });

    test('8 m², 2 pontos → válido (min = 2)', () {
      expect(
        spec.verificar((comodo: TipoComodo.quarto, areaM2: 8.0, numPontos: 2)),
        isEmpty,
      );
    });

    test('8 m², 3 pontos → válido (acima do mínimo)', () {
      expect(
        spec.verificar((comodo: TipoComodo.cozinha, areaM2: 8.0, numPontos: 3)),
        isEmpty,
      );
    });

    test('3 m², 1 ponto → válido (min = max(1, ceil(3/4)=1) = 1)', () {
      expect(
        spec.verificar((comodo: TipoComodo.banheiro, areaM2: 3.0, numPontos: 1)),
        isEmpty,
      );
    });

    test('16 m², 4 pontos → válido (min = ceil(16/4) = 4)', () {
      expect(
        spec.verificar((comodo: TipoComodo.sala, areaM2: 16.0, numPontos: 4)),
        isEmpty,
      );
    });

    test('5 m², 2 pontos → válido (min = ceil(5/4) = 2)', () {
      expect(
        spec.verificar((comodo: TipoComodo.quarto, areaM2: 5.0, numPontos: 2)),
        isEmpty,
      );
    });
  });

  // ── IL_001 ────────────────────────────────────────────────────────────────

  group('IL_001 —', () {
    test('4 m², 0 pontos → IL_001 (min = 1)', () {
      final v = spec.verificar((comodo: TipoComodo.sala, areaM2: 4.0, numPontos: 0));
      expect(v.any((final e) => e.codigo == 'IL_001'), isTrue);
    });

    test('8 m², 1 ponto → IL_001 (min = 2)', () {
      final v = spec.verificar((comodo: TipoComodo.quarto, areaM2: 8.0, numPontos: 1));
      expect(v.any((final e) => e.codigo == 'IL_001'), isTrue);
    });

    test('16 m², 3 pontos → IL_001 (min = 4)', () {
      final v = spec.verificar((comodo: TipoComodo.sala, areaM2: 16.0, numPontos: 3));
      expect(v.any((final e) => e.codigo == 'IL_001'), isTrue);
    });

    test('5 m², 1 ponto → IL_001 (min = 2)', () {
      final v = spec.verificar((comodo: TipoComodo.cozinha, areaM2: 5.0, numPontos: 1));
      expect(v.any((final e) => e.codigo == 'IL_001'), isTrue);
    });

    test('IL_001 tem referência 9.5.4.1.1', () {
      final v = spec.verificar((comodo: TipoComodo.sala, areaM2: 8.0, numPontos: 1));
      expect(v.first.referencia, contains('9.5.4.1.1'));
    });

    test('IL_001 — apenas uma violação por cômodo', () {
      final v = spec.verificar((comodo: TipoComodo.sala, areaM2: 16.0, numPontos: 0));
      expect(v.length, equals(1));
    });
  });

  // ── Fórmula ceil(area/4) ──────────────────────────────────────────────────

  group('Fórmula —', () {
    test('1 m² → min = 1 (max(1, ceil(0.25)) = 1)', () {
      expect(
        spec.verificar((comodo: TipoComodo.corredor, areaM2: 1.0, numPontos: 1)),
        isEmpty,
      );
    });

    test('12 m² → min = 3 (ceil(12/4) = 3)', () {
      expect(
        spec.verificar((comodo: TipoComodo.sala, areaM2: 12.0, numPontos: 3)),
        isEmpty,
      );
      expect(
        spec.verificar((comodo: TipoComodo.sala, areaM2: 12.0, numPontos: 2))
            .any((final e) => e.codigo == 'IL_001'),
        isTrue,
      );
    });

    test('20 m² → min = 5 (ceil(20/4) = 5)', () {
      expect(
        spec.verificar((comodo: TipoComodo.sala, areaM2: 20.0, numPontos: 5)),
        isEmpty,
      );
      expect(
        spec.verificar((comodo: TipoComodo.sala, areaM2: 20.0, numPontos: 4))
            .any((final e) => e.codigo == 'IL_001'),
        isTrue,
      );
    });
  });
}
