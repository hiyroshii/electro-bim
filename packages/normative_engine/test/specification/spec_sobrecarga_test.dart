// REV: 1.0.0
// CHANGELOG:
// [1.0.0] - 2026-05
// - ADD: testes de sobrecarga IB ≤ In ≤ Iz (SOBRE_001, SOBRE_002).

import 'package:test/test.dart';
import '../test_helpers.dart';

// ignore: implementation_imports
import 'package:normative_engine/src/specification/protecao/spec_sobrecarga.dart';

SpecSobrecarga _spec({
  required final double ib,
  required final double inDisjuntor,
  required final double izFinal,
}) =>
    SpecSobrecarga(ib: ib, inDisjuntor: inDisjuntor, izFinal: izFinal);

List<String> _codigos(final SpecSobrecarga spec) =>
    spec.verificar(entradaPadrao()).map((final v) => v.codigo).toList();

void main() {
  // ── Conforme ──────────────────────────────────────────────────────────────

  group('Conforme —', () {
    test('IB = In = Iz → sem violação', () {
      expect(
        _codigos(_spec(ib: 16.0, inDisjuntor: 16.0, izFinal: 16.0)),
        isEmpty,
      );
    });

    test('IB < In < Iz → sem violação', () {
      expect(
        _codigos(_spec(ib: 10.0, inDisjuntor: 16.0, izFinal: 24.0)),
        isEmpty,
      );
    });

    test('IB = In, In < Iz → sem violação', () {
      expect(
        _codigos(_spec(ib: 16.0, inDisjuntor: 16.0, izFinal: 24.0)),
        isEmpty,
      );
    });

    test('IB < In, In = Iz → sem violação', () {
      expect(
        _codigos(_spec(ib: 10.0, inDisjuntor: 24.0, izFinal: 24.0)),
        isEmpty,
      );
    });
  });

  // ── SOBRE_001: IB > In ────────────────────────────────────────────────────

  group('SOBRE_001 — disjuntor subdimensionado (IB > In) —', () {
    test('IB > In → SOBRE_001', () {
      expect(
        _codigos(_spec(ib: 20.0, inDisjuntor: 16.0, izFinal: 24.0)),
        contains('SOBRE_001'),
      );
    });

    test('SOBRE_001 tem referência 5.3.4.1', () {
      final violacoes = _spec(ib: 20.0, inDisjuntor: 16.0, izFinal: 24.0)
          .verificar(entradaPadrao());
      expect(violacoes.first.referencia, contains('5.3.4.1'));
    });

    test('IB apenas marginalmente maior que In → SOBRE_001', () {
      expect(
        _codigos(_spec(ib: 16.1, inDisjuntor: 16.0, izFinal: 24.0)),
        contains('SOBRE_001'),
      );
    });
  });

  // ── SOBRE_002: In > Iz ────────────────────────────────────────────────────

  group('SOBRE_002 — disjuntor superdimensionado (In > Iz) —', () {
    test('In > Iz → SOBRE_002', () {
      expect(
        _codigos(_spec(ib: 10.0, inDisjuntor: 32.0, izFinal: 24.0)),
        contains('SOBRE_002'),
      );
    });

    test('SOBRE_002 tem referência 5.3.4.1', () {
      final violacoes = _spec(ib: 10.0, inDisjuntor: 32.0, izFinal: 24.0)
          .verificar(entradaPadrao());
      final sobre002 = violacoes.firstWhere((final v) => v.codigo == 'SOBRE_002');
      expect(sobre002.referencia, contains('5.3.4.1'));
    });

    test('In apenas marginalmente maior que Iz → SOBRE_002', () {
      expect(
        _codigos(_spec(ib: 10.0, inDisjuntor: 24.1, izFinal: 24.0)),
        contains('SOBRE_002'),
      );
    });
  });

  // ── Ambas as violações simultâneas ────────────────────────────────────────

  group('Violações simultâneas —', () {
    test('IB > In e In > Iz → SOBRE_001 + SOBRE_002', () {
      final codigos =
          _codigos(_spec(ib: 40.0, inDisjuntor: 32.0, izFinal: 24.0));
      expect(codigos, containsAll(['SOBRE_001', 'SOBRE_002']));
      expect(codigos.length, equals(2));
    });
  });

  // ── Mensagens descritivas ─────────────────────────────────────────────────

  group('Mensagens —', () {
    test('SOBRE_001 menciona Ib e In', () {
      final v = _spec(ib: 20.0, inDisjuntor: 16.0, izFinal: 24.0)
          .verificar(entradaPadrao())
          .firstWhere((final v) => v.codigo == 'SOBRE_001');
      expect(v.descricao, contains('20.0'));
      expect(v.descricao, contains('16.0'));
    });

    test('SOBRE_002 menciona In e Iz', () {
      final v = _spec(ib: 10.0, inDisjuntor: 32.0, izFinal: 24.0)
          .verificar(entradaPadrao())
          .firstWhere((final v) => v.codigo == 'SOBRE_002');
      expect(v.descricao, contains('32.0'));
      expect(v.descricao, contains('24.0'));
    });
  });
}
