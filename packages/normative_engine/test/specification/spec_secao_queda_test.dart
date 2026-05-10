// REV: 1.0.0
// CHANGELOG:
// [1.0.0] - 2026-04
// - ADD: testes de seção mínima (Tabela 47) e queda de tensão (6.2.7).

import 'package:test/test.dart';
import 'package:normative_engine/normative_engine.dart';
import '../test_helpers.dart';

// ignore: implementation_imports
import 'package:normative_engine/src/specification/spec_secao_minima.dart';
// ignore: implementation_imports
import 'package:normative_engine/src/specification/spec_queda_tensao.dart';

void main() {
  // ── SpecSecaoMinima ───────────────────────────────────────────────────────

  group('SpecSecaoMinima —', () {
    test('TUG cobre 2.5mm² — válido', () {
      const spec = SpecSecaoMinima(secaoCalculada: 2.5);
      final e = entradaPadrao(
        
      );
      expect(spec.verificar(e), isEmpty);
    });

    test('TUG cobre 1.5mm² — SEC_001', () {
      const spec = SpecSecaoMinima(secaoCalculada: 1.5);
      final e = entradaPadrao(
        
      );
      final violacoes = spec.verificar(e);
      expect(violacoes.any((final v) => v.codigo == 'SEC_001'), isTrue);
    });

    test('IL cobre 1.5mm² — válido', () {
      const spec = SpecSecaoMinima(secaoCalculada: 1.5);
      final e = entradaPadrao(
        tagCircuito: TagCircuito.il,
      );
      expect(spec.verificar(e), isEmpty);
    });

    test('IL cobre 1.0mm² — SEC_001', () {
      const spec = SpecSecaoMinima(secaoCalculada: 1.0);
      final e = entradaPadrao(
        tagCircuito: TagCircuito.il,
      );
      final violacoes = spec.verificar(e);
      expect(violacoes.any((final v) => v.codigo == 'SEC_001'), isTrue);
    });

    test('TUG alumínio 16mm² — válido', () {
      const spec = SpecSecaoMinima(secaoCalculada: 16.0);
      final e = entradaPadrao(
        material: Material.aluminio,
      );
      expect(spec.verificar(e), isEmpty);
    });

    test('TUG alumínio 10mm² — SEC_001', () {
      const spec = SpecSecaoMinima(secaoCalculada: 10.0);
      final e = entradaPadrao(
        material: Material.aluminio,
      );
      final violacoes = spec.verificar(e);
      expect(violacoes.any((final v) => v.codigo == 'SEC_001'), isTrue);
    });

    test('Alimentador cobre — sem piso explícito, qualquer seção', () {
      const spec = SpecSecaoMinima(secaoCalculada: 1.0);
      final e = entradaPadrao(
        tagCircuito: TagCircuito.qdg,
      );
      expect(spec.verificar(e), isEmpty);
    });
  });

  // ── SpecQuedaTensao ───────────────────────────────────────────────────────

  group('SpecQuedaTensao —', () {
    test('Terminal 3.9% — válido (limite 4%)', () {
      const spec = SpecQuedaTensao(
        quedaCalculadaPercent: 3.9,
        origemAlimentacao: OrigemAlimentacao.pontoEntrega,
      );
      final e = entradaPadrao();
      expect(spec.verificar(e), isEmpty);
    });

    test('Terminal 4.1% — QUEDA_001', () {
      const spec = SpecQuedaTensao(
        quedaCalculadaPercent: 4.1,
        origemAlimentacao: OrigemAlimentacao.pontoEntrega,
      );
      final e = entradaPadrao();
      final violacoes = spec.verificar(e);
      expect(violacoes.any((final v) => v.codigo == 'QUEDA_001'), isTrue);
    });

    test('Alimentador entrega 0,9% — válido (limite 1%)', () {
      const spec = SpecQuedaTensao(
        quedaCalculadaPercent: 0.9,
        origemAlimentacao: OrigemAlimentacao.pontoEntrega,
      );
      final e = entradaPadrao(tagCircuito: TagCircuito.qdg);
      expect(spec.verificar(e), isEmpty);
    });

    test('Alimentador entrega 1,1% — QUEDA_001 (excede 1%)', () {
      const spec = SpecQuedaTensao(
        quedaCalculadaPercent: 1.1,
        origemAlimentacao: OrigemAlimentacao.pontoEntrega,
      );
      final e = entradaPadrao(tagCircuito: TagCircuito.qdg);
      final violacoes = spec.verificar(e);
      expect(violacoes.any((final v) => v.codigo == 'QUEDA_001'), isTrue);
    });

    test('Alimentador próprio 2,9% — válido (limite 3%)', () {
      const spec = SpecQuedaTensao(
        quedaCalculadaPercent: 2.9,
        origemAlimentacao: OrigemAlimentacao.trafoProprio,
      );
      final e = entradaPadrao(tagCircuito: TagCircuito.qdg);
      expect(spec.verificar(e), isEmpty);
    });

    test('Alimentador próprio 3,1% — QUEDA_001 (excede 3%)', () {
      const spec = SpecQuedaTensao(
        quedaCalculadaPercent: 3.1,
        origemAlimentacao: OrigemAlimentacao.trafoProprio,
      );
      final e = entradaPadrao(tagCircuito: TagCircuito.qdg);
      final violacoes = spec.verificar(e);
      expect(violacoes.any((final v) => v.codigo == 'QUEDA_001'), isTrue);
    });

    test('IL usa limite terminal (4%) independente da origem', () {
      const spec = SpecQuedaTensao(
        quedaCalculadaPercent: 4.1,
        origemAlimentacao: OrigemAlimentacao.trafoProprio,
      );
      final e = entradaPadrao(tagCircuito: TagCircuito.il);
      final violacoes = spec.verificar(e);
      expect(violacoes.any((final v) => v.codigo == 'QUEDA_001'), isTrue);
    });
  });
}
