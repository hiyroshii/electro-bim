// REV: 1.0.0
// CHANGELOG:
// [1.0.0] - 2026-04
// - ADD: testes de restrições de uso do alumínio (6.2.3.8).

import 'package:test/test.dart';
import 'package:normative_engine/normative_engine.dart';
import '../test_helpers.dart';

// ignore: implementation_imports
import 'package:normative_engine/src/specification/spec_aluminio.dart';

void main() {
  // ── BD4 ───────────────────────────────────────────────────────────────────

  group('BD4 —', () {
    test('Alumínio em BD4 — ALU_001', () {
      final spec = const SpecAluminio(contexto: ContextoInstalacao.bd4);
      final e = entradaPadrao(material: Material.aluminio);
      final violacoes = spec.verificar(e);
      expect(violacoes.any((v) => v.codigo == 'ALU_001'), isTrue);
    });

    test('Cobre em BD4 — sem violação', () {
      final spec = const SpecAluminio(contexto: ContextoInstalacao.bd4);
      final e = entradaPadrao(material: Material.cobre);
      expect(spec.verificar(e), isEmpty);
    });

    test('BD4 para na primeira violação — não verifica seção', () {
      final spec = SpecAluminio(
        contexto: ContextoInstalacao.bd4,
        secaoCalculada: 2.5,
      );
      final e = entradaPadrao(material: Material.aluminio);
      final violacoes = spec.verificar(e);
      expect(violacoes.length, equals(1));
      expect(violacoes.first.codigo, equals('ALU_001'));
    });
  });

  // ── Industrial ────────────────────────────────────────────────────────────

  group('Industrial —', () {
    test('Alumínio 16mm² em industrial — válido', () {
      final spec = SpecAluminio(
        contexto: ContextoInstalacao.industrial,
        secaoCalculada: 16.0,
      );
      final e = entradaPadrao(material: Material.aluminio);
      expect(spec.verificar(e), isEmpty);
    });

    test('Alumínio 10mm² em industrial — ALU_002', () {
      final spec = SpecAluminio(
        contexto: ContextoInstalacao.industrial,
        secaoCalculada: 10.0,
      );
      final e = entradaPadrao(material: Material.aluminio);
      final violacoes = spec.verificar(e);
      expect(violacoes.any((v) => v.codigo == 'ALU_002'), isTrue);
    });

    test('Alumínio 50mm² em industrial — válido', () {
      final spec = SpecAluminio(
        contexto: ContextoInstalacao.industrial,
        secaoCalculada: 50.0,
      );
      final e = entradaPadrao(material: Material.aluminio);
      expect(spec.verificar(e), isEmpty);
    });
  });

  // ── Comercial BD1 ─────────────────────────────────────────────────────────

  group('Comercial BD1 —', () {
    test('Alumínio 50mm² em comercial BD1 — válido', () {
      final spec = SpecAluminio(
        contexto: ContextoInstalacao.comercialBd1,
        secaoCalculada: 50.0,
      );
      final e = entradaPadrao(material: Material.aluminio);
      expect(spec.verificar(e), isEmpty);
    });

    test('Alumínio 35mm² em comercial BD1 — ALU_002', () {
      final spec = SpecAluminio(
        contexto: ContextoInstalacao.comercialBd1,
        secaoCalculada: 35.0,
      );
      final e = entradaPadrao(material: Material.aluminio);
      final violacoes = spec.verificar(e);
      expect(violacoes.any((v) => v.codigo == 'ALU_002'), isTrue);
    });

    test('Cobre em comercial BD1 — sem violação independente de seção', () {
      final spec = SpecAluminio(
        contexto: ContextoInstalacao.comercialBd1,
        secaoCalculada: 1.5,
      );
      final e = entradaPadrao(material: Material.cobre);
      expect(spec.verificar(e), isEmpty);
    });
  });
}
