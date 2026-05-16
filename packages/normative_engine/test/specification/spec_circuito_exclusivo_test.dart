// REV: 1.0.0
// CHANGELOG:
// [1.0.0] - 2026-05
// - ADD: testes de circuito exclusivo para TUGs em áreas molhadas (S-10).

import 'package:test/test.dart';
import 'package:normative_engine/normative_engine.dart';

const _residencial = PerfilInstalacao(escopo: EscopoProjeto.residencial);
const _industrial = PerfilInstalacao(escopo: EscopoProjeto.industrial);

void main() {
  const spec = SpecCircuitoExclusivo();

  // ── aplicavelA ────────────────────────────────────────────────────────────

  group('aplicavelA —', () {
    test('Residencial → true', () => expect(spec.aplicavelA(_residencial), isTrue));
    test('Industrial → false', () => expect(spec.aplicavelA(_industrial), isFalse));
  });

  // ── Não TUG — spec não se aplica ─────────────────────────────────────────

  group('Não TUG —', () {
    test('IL em cozinha, não exclusivo → sem violação', () {
      expect(
        spec.verificar((comodo: TipoComodo.cozinha, tag: TagCircuito.il, circuitoExclusivo: false)),
        isEmpty,
      );
    });

    test('TUE em areaServico, não exclusivo → sem violação', () {
      expect(
        spec.verificar((comodo: TipoComodo.areaServico, tag: TagCircuito.tue, circuitoExclusivo: false)),
        isEmpty,
      );
    });
  });

  // ── TUG em área seca — sem exigência ─────────────────────────────────────

  group('TUG área seca —', () {
    test('Sala, não exclusivo → sem violação', () {
      expect(
        spec.verificar((comodo: TipoComodo.sala, tag: TagCircuito.tug, circuitoExclusivo: false)),
        isEmpty,
      );
    });

    test('Quarto, não exclusivo → sem violação', () {
      expect(
        spec.verificar((comodo: TipoComodo.quarto, tag: TagCircuito.tug, circuitoExclusivo: false)),
        isEmpty,
      );
    });

    test('Banheiro, não exclusivo → sem violação (não listado em 9.5.3.2)', () {
      expect(
        spec.verificar((comodo: TipoComodo.banheiro, tag: TagCircuito.tug, circuitoExclusivo: false)),
        isEmpty,
      );
    });

    test('Garagem, não exclusivo → sem violação', () {
      expect(
        spec.verificar((comodo: TipoComodo.garagem, tag: TagCircuito.tug, circuitoExclusivo: false)),
        isEmpty,
      );
    });
  });

  // ── TUG em área molhada com circuito exclusivo — conforme ─────────────────

  group('TUG área molhada, exclusivo —', () {
    test('Cozinha, exclusivo → sem violação', () {
      expect(
        spec.verificar((comodo: TipoComodo.cozinha, tag: TagCircuito.tug, circuitoExclusivo: true)),
        isEmpty,
      );
    });

    test('Área de serviço, exclusivo → sem violação', () {
      expect(
        spec.verificar((comodo: TipoComodo.areaServico, tag: TagCircuito.tug, circuitoExclusivo: true)),
        isEmpty,
      );
    });
  });

  // ── TUG em área molhada sem exclusividade — CIRC_002 ─────────────────────

  group('TUG área molhada, não exclusivo —', () {
    test('Cozinha → CIRC_002', () {
      final v = spec.verificar((comodo: TipoComodo.cozinha, tag: TagCircuito.tug, circuitoExclusivo: false));
      expect(v.any((final Violacao e) => e.codigo == 'CIRC_002'), isTrue);
    });

    test('Área de serviço → CIRC_002', () {
      final v = spec.verificar((comodo: TipoComodo.areaServico, tag: TagCircuito.tug, circuitoExclusivo: false));
      expect(v.any((final Violacao e) => e.codigo == 'CIRC_002'), isTrue);
    });

    test('Apenas uma violação', () {
      final v = spec.verificar((comodo: TipoComodo.cozinha, tag: TagCircuito.tug, circuitoExclusivo: false));
      expect(v.length, equals(1));
    });
  });

  // ── Metadata da violação ──────────────────────────────────────────────────

  group('Violação CIRC_002 —', () {
    late List<Violacao> v;
    setUp(() {
      v = spec.verificar((comodo: TipoComodo.cozinha, tag: TagCircuito.tug, circuitoExclusivo: false));
    });

    test('Código correto', () => expect(v.first.codigo, equals('CIRC_002')));
    test(
      'Referência 9.5.3.2',
      () => expect(v.first.referencia, contains('9.5.3.2')),
    );
  });
}
