// REV: 1.0.0
// CHANGELOG:
// [1.0.0] - 2026-05
// - ADD: testes do cálculo da seção mínima do condutor neutro (6.2.6.2).

import 'package:test/test.dart';
import 'package:normative_engine/normative_engine.dart';

// ignore: implementation_imports
import 'package:normative_engine/src/procedure/proc_secao_neutro.dart';

void main() {
  const proc = ProcSecaoNeutro();

  // ── Monofásico ────────────────────────────────────────────────────────────

  group('Monofásico —', () {
    test('Neutro = fase independente de harmônicas', () {
      expect(
        proc.resolver((2.5, NumeroFases.monofasico, false)),
        equals(2.5),
      );
    });

    test('Fase 35mm² monofásico → neutro = 35mm² (sem redução)', () {
      expect(
        proc.resolver((35.0, NumeroFases.monofasico, false)),
        equals(35.0),
      );
    });
  });

  // ── Bifásico/trifásico com harmônicas > 15% ───────────────────────────────

  group('Harmônicas > 15% —', () {
    test('Bifásico harm>15% — neutro = fase', () {
      expect(
        proc.resolver((2.5, NumeroFases.bifasico, true)),
        equals(2.5),
      );
    });

    test('Trifásico harm>15% — neutro = fase (sem redução)', () {
      expect(
        proc.resolver((50.0, NumeroFases.trifasico, true)),
        equals(50.0),
      );
    });
  });

  // ── Trifásico harm ≤ 15% e fase ≤ 25 mm² ─────────────────────────────────

  group('Trifásico harm ≤ 15% — fase ≤ 25mm² —', () {
    test('2,5mm² → neutro = 2,5mm²', () {
      expect(
        proc.resolver((2.5, NumeroFases.trifasico, false)),
        equals(2.5),
      );
    });

    test('16mm² → neutro = 16mm²', () {
      expect(
        proc.resolver((16.0, NumeroFases.trifasico, false)),
        equals(16.0),
      );
    });

    test('25mm² → neutro = 25mm² (piso sem redução)', () {
      expect(
        proc.resolver((25.0, NumeroFases.trifasico, false)),
        equals(25.0),
      );
    });
  });

  // ── Trifásico harm ≤ 15% e fase > 25 mm² (Tabela 48) ────────────────────

  group('Trifásico harm ≤ 15% — fase > 25mm² — Tabela 48 —', () {
    test('35mm² → neutro = 25mm²', () {
      expect(proc.resolver((35.0, NumeroFases.trifasico, false)), equals(25.0));
    });

    test('50mm² → neutro = 25mm²', () {
      expect(proc.resolver((50.0, NumeroFases.trifasico, false)), equals(25.0));
    });

    test('70mm² → neutro = 35mm²', () {
      expect(proc.resolver((70.0, NumeroFases.trifasico, false)), equals(35.0));
    });

    test('95mm² → neutro = 50mm²', () {
      expect(proc.resolver((95.0, NumeroFases.trifasico, false)), equals(50.0));
    });

    test('240mm² → neutro = 120mm²', () {
      expect(
        proc.resolver((240.0, NumeroFases.trifasico, false)),
        equals(120.0),
      );
    });

    test('Seção não mapeada na Tab. 48 → fallback = fase', () {
      // 30mm² não está na Tabela 48 (valores são 35, 50, 70…)
      expect(
        proc.resolver((30.0, NumeroFases.trifasico, false)),
        equals(30.0),
      );
    });
  });

  // ── Bifásico harm ≤ 15% ───────────────────────────────────────────────────

  group('Bifásico harm ≤ 15% —', () {
    test('Bifásico 10mm² → neutro = 10mm² (fase ≤ 25)', () {
      expect(
        proc.resolver((10.0, NumeroFases.bifasico, false)),
        equals(10.0),
      );
    });

    test('Bifásico 35mm² — aplica Tab. 48 → neutro = 25mm²', () {
      expect(
        proc.resolver((35.0, NumeroFases.bifasico, false)),
        equals(25.0),
      );
    });
  });
}
