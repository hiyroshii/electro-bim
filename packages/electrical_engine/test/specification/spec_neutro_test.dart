// REV: 1.0.0
// CHANGELOG:
// [1.0.0] - 2026-04
// - ADD: testes das regras do condutor neutro (6.2.6.2).

import 'package:test/test.dart';
import 'package:normative_engine/normative_engine.dart';
import '../test_helpers.dart';

// ignore: implementation_imports
import 'package:normative_engine/src/specification/spec_neutro.dart';

void main() {
  // ── Monofásico ────────────────────────────────────────────────────────────

  group('Monofásico —', () {
    test('Neutro igual à fase — válido', () {
      final spec = SpecNeutro(secaoNeutro: 2.5, secaoFase: 2.5);
      final e = entradaPadrao(numeroFases: NumeroFases.monofasico);
      expect(spec.verificar(e), isEmpty);
    });

    test('Neutro menor que fase — NEUTRO_002', () {
      final spec = SpecNeutro(secaoNeutro: 1.5, secaoFase: 2.5);
      final e = entradaPadrao(numeroFases: NumeroFases.monofasico);
      final violacoes = spec.verificar(e);
      expect(violacoes.any((v) => v.codigo == 'NEUTRO_002'), isTrue);
    });
  });

  // ── Trifásico com harmônicas > 15% ────────────────────────────────────────

  group('Trifásico harm > 15% —', () {
    test('Neutro igual à fase — válido', () {
      final spec = SpecNeutro(secaoNeutro: 35.0, secaoFase: 35.0);
      final e = entradaPadrao(
        numeroFases: NumeroFases.trifasico,
        harmonicasAcima15pct: true,
      );
      expect(spec.verificar(e), isEmpty);
    });

    test('Neutro menor que fase — NEUTRO_003', () {
      final spec = SpecNeutro(secaoNeutro: 25.0, secaoFase: 35.0);
      final e = entradaPadrao(
        numeroFases: NumeroFases.trifasico,
        harmonicasAcima15pct: true,
      );
      final violacoes = spec.verificar(e);
      expect(violacoes.any((v) => v.codigo == 'NEUTRO_003'), isTrue);
    });
  });

  // ── Trifásico com harmônicas ≤ 15% — redução Tab. 48 ─────────────────────

  group('Trifásico harm ≤ 15% — Tabela 48 —', () {
    test('Fase 35mm², neutro 25mm² — válido (Tab. 48)', () {
      final spec = SpecNeutro(secaoNeutro: 25.0, secaoFase: 35.0);
      final e = entradaPadrao(
        numeroFases: NumeroFases.trifasico,
        harmonicasAcima15pct: false,
      );
      expect(spec.verificar(e), isEmpty);
    });

    test('Fase 95mm², neutro 35mm² — válido (Tab. 48)', () {
      final spec = SpecNeutro(secaoNeutro: 35.0, secaoFase: 95.0);
      final e = entradaPadrao(
        numeroFases: NumeroFases.trifasico,
        harmonicasAcima15pct: false,
      );
      expect(spec.verificar(e), isEmpty);
    });

    test('Fase 95mm², neutro 25mm² — NEUTRO_001', () {
      final spec = SpecNeutro(secaoNeutro: 25.0, secaoFase: 95.0);
      final e = entradaPadrao(
        numeroFases: NumeroFases.trifasico,
        harmonicasAcima15pct: false,
      );
      final violacoes = spec.verificar(e);
      expect(violacoes.any((v) => v.codigo == 'NEUTRO_001'), isTrue);
    });

    test('Fase ≤ 25mm², neutro deve ser igual à fase — NEUTRO_002', () {
      final spec = SpecNeutro(secaoNeutro: 1.5, secaoFase: 2.5);
      final e = entradaPadrao(
        numeroFases: NumeroFases.trifasico,
        harmonicasAcima15pct: false,
      );
      final violacoes = spec.verificar(e);
      expect(violacoes.any((v) => v.codigo == 'NEUTRO_002'), isTrue);
    });
  });
}
