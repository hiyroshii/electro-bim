// REV: 1.0.0
// CHANGELOG:
// [1.0.0] - 2026-05
// - ADD: testes de dispositivo multipolar para circuitos multifásicos (DISP_001).

import 'package:test/test.dart';
import 'package:normative_engine/normative_engine.dart';
import '../test_helpers.dart';

// ignore: implementation_imports
import 'package:normative_engine/src/specification/spec_dispositivo_multipolar.dart';

bool _disp001Presente(final EntradaNormativa e) =>
    const SpecDispositivoMultipolar()
        .verificar(e)
        .any((final v) => v.codigo == 'DISP_001');

void main() {
  const spec = SpecDispositivoMultipolar();

  // ── Monofásico — nunca viola ───────────────────────────────────────────────

  group('Monofásico —', () {
    test('Monofásico + dispositivoMultipolar=true → sem violação', () {
      final e = entradaPadrao(
        
      );
      expect(spec.verificar(e), isEmpty);
    });

    test('Monofásico + dispositivoMultipolar=false → sem violação', () {
      final e = entradaPadrao(
        dispositivoMultipolar: false,
      );
      expect(spec.verificar(e), isEmpty);
    });
  });

  // ── Bifásico ──────────────────────────────────────────────────────────────

  group('Bifásico —', () {
    test('Bifásico + multipolar=true → sem violação', () {
      final e = entradaPadrao(
        numeroFases: NumeroFases.bifasico,
      );
      expect(_disp001Presente(e), isFalse);
    });

    test('Bifásico + multipolar=false → DISP_001', () {
      final e = entradaPadrao(
        numeroFases: NumeroFases.bifasico,
        dispositivoMultipolar: false,
      );
      expect(_disp001Presente(e), isTrue);
    });
  });

  // ── Trifásico ─────────────────────────────────────────────────────────────

  group('Trifásico —', () {
    test('Trifásico + multipolar=true → sem violação', () {
      final e = entradaPadrao(
        numeroFases: NumeroFases.trifasico,
      );
      expect(_disp001Presente(e), isFalse);
    });

    test('Trifásico + multipolar=false → DISP_001', () {
      final e = entradaPadrao(
        numeroFases: NumeroFases.trifasico,
        dispositivoMultipolar: false,
      );
      expect(_disp001Presente(e), isTrue);
    });

    test('DISP_001 tem código correto', () {
      final e = entradaPadrao(
        numeroFases: NumeroFases.trifasico,
        dispositivoMultipolar: false,
      );
      final violacoes = spec.verificar(e);
      expect(violacoes.length, equals(1));
      expect(violacoes.first.codigo, equals('DISP_001'));
    });

    test('DISP_001 referência normativa — 9.5.4', () {
      final e = entradaPadrao(
        numeroFases: NumeroFases.trifasico,
        dispositivoMultipolar: false,
      );
      final violacoes = spec.verificar(e);
      expect(violacoes.first.referencia, contains('9.5.4'));
    });
  });

  // ── Default — dispositivoMultipolar=true nunca viola ─────────────────────

  group('Default —', () {
    test('Trifásico com default (true) → sem DISP_001', () {
      final e = entradaPadrao(
        numeroFases: NumeroFases.trifasico,
      );
      expect(_disp001Presente(e), isFalse);
    });
  });
}
