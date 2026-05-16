// REV: 1.0.0
// CHANGELOG:
// [1.0.0] - 2026-05
// - ADD: testes de circuito exclusivo para TUEs com Ib > 10 A (S-9).

import 'package:test/test.dart';
import 'package:normative_engine/normative_engine.dart';

const _residencial = PerfilInstalacao(escopo: EscopoProjeto.residencial);
const _comercial = PerfilInstalacao(escopo: EscopoProjeto.comercial);

void main() {
  const spec = SpecCircuitoIndependente();

  // ── aplicavelA ────────────────────────────────────────────────────────────

  group('aplicavelA —', () {
    test('Residencial → true', () => expect(spec.aplicavelA(_residencial), isTrue));
    test('Comercial → false', () => expect(spec.aplicavelA(_comercial), isFalse));
  });

  // ── Não TUE — spec não se aplica ──────────────────────────────────────────

  group('Não TUE —', () {
    test('TUG Ib=12A, não exclusivo → sem violação', () {
      expect(
        spec.verificar((tag: TagCircuito.tug, ibCircuito: 12.0, circuitoExclusivo: false)),
        isEmpty,
      );
    });

    test('IL Ib=15A, não exclusivo → sem violação', () {
      expect(
        spec.verificar((tag: TagCircuito.il, ibCircuito: 15.0, circuitoExclusivo: false)),
        isEmpty,
      );
    });
  });

  // ── TUE com Ib ≤ 10 A — sem exigência ────────────────────────────────────

  group('TUE Ib ≤ 10 A —', () {
    test('Ib=8A, não exclusivo → sem violação', () {
      expect(
        spec.verificar((tag: TagCircuito.tue, ibCircuito: 8.0, circuitoExclusivo: false)),
        isEmpty,
      );
    });

    test('Ib=10A exato, não exclusivo → sem violação (limite inclusivo)', () {
      expect(
        spec.verificar((tag: TagCircuito.tue, ibCircuito: 10.0, circuitoExclusivo: false)),
        isEmpty,
      );
    });
  });

  // ── TUE com Ib > 10 A e circuito exclusivo — conforme ────────────────────

  group('TUE Ib > 10 A, exclusivo —', () {
    test('Ib=12A, exclusivo → sem violação', () {
      expect(
        spec.verificar((tag: TagCircuito.tue, ibCircuito: 12.0, circuitoExclusivo: true)),
        isEmpty,
      );
    });
  });

  // ── TUE com Ib > 10 A sem exclusividade — CIRC_001 ───────────────────────

  group('TUE Ib > 10 A, não exclusivo —', () {
    test('Ib=10.1A → CIRC_001', () {
      final v = spec.verificar((tag: TagCircuito.tue, ibCircuito: 10.1, circuitoExclusivo: false));
      expect(v.any((final Violacao e) => e.codigo == 'CIRC_001'), isTrue);
    });

    test('Ib=20A → CIRC_001', () {
      final v = spec.verificar((tag: TagCircuito.tue, ibCircuito: 20.0, circuitoExclusivo: false));
      expect(v.any((final Violacao e) => e.codigo == 'CIRC_001'), isTrue);
    });

    test('Apenas uma violação', () {
      final v = spec.verificar((tag: TagCircuito.tue, ibCircuito: 15.0, circuitoExclusivo: false));
      expect(v.length, equals(1));
    });
  });

  // ── Metadata da violação ──────────────────────────────────────────────────

  group('Violação CIRC_001 —', () {
    late List<Violacao> v;
    setUp(() {
      v = spec.verificar((tag: TagCircuito.tue, ibCircuito: 12.0, circuitoExclusivo: false));
    });

    test('Código correto', () => expect(v.first.codigo, equals('CIRC_001')));
    test(
      'Referência 9.5.3.1',
      () => expect(v.first.referencia, contains('9.5.3.1')),
    );
  });
}
