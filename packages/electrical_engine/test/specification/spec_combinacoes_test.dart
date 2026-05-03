// REV: 1.0.0
// CHANGELOG:
// [1.0.0] - 2026-04
// - ADD: testes de combinações válidas iso × arq × método × arranjo × tensão.

import 'package:test/test.dart';
import 'package:normative_engine/normative_engine.dart';
import '../test_helpers.dart';

// ignore: implementation_imports
import 'package:normative_engine/src/specification/spec_combinacoes.dart';

void main() {
  const spec = SpecCombinacoes();

  // ── Isolacao × Arquitetura ────────────────────────────────────────────────

  group('Isolacao × Arquitetura —', () {
    test('PVC aceita ISOLADO', () {
      final e = entradaPadrao(
        isolacao: Isolacao.pvc,
        arquitetura: Arquitetura.isolado,
        metodo: MetodoInstalacao.b1,
      );
      expect(_combinacaoViolada(spec, e), isFalse);
    });

    test('PVC aceita UNIPOLAR', () {
      final e = entradaPadrao(
        isolacao: Isolacao.pvc,
        arquitetura: Arquitetura.unipolar,
        metodo: MetodoInstalacao.c,
      );
      expect(_combinacaoViolada(spec, e), isFalse);
    });

    test('PVC aceita MULTIPOLAR', () {
      final e = entradaPadrao(
        isolacao: Isolacao.pvc,
        arquitetura: Arquitetura.multipolar,
        metodo: MetodoInstalacao.b1,
      );
      expect(_combinacaoViolada(spec, e), isFalse);
    });

    test('XLPE não aceita ISOLADO — COMB_001', () {
      final e = entradaPadrao(
        isolacao: Isolacao.xlpe,
        arquitetura: Arquitetura.isolado,
        metodo: MetodoInstalacao.b1,
      );
      final violacoes = spec.verificar(e);
      expect(_temCodigo(violacoes, 'COMB_001'), isTrue);
    });

    test('EPR não aceita ISOLADO — COMB_001', () {
      final e = entradaPadrao(
        isolacao: Isolacao.epr,
        arquitetura: Arquitetura.isolado,
        metodo: MetodoInstalacao.b1,
      );
      final violacoes = spec.verificar(e);
      expect(_temCodigo(violacoes, 'COMB_001'), isTrue);
    });

    test('XLPE aceita UNIPOLAR', () {
      final e = entradaPadrao(
        isolacao: Isolacao.xlpe,
        arquitetura: Arquitetura.unipolar,
        metodo: MetodoInstalacao.c,
      );
      expect(_combinacaoViolada(spec, e), isFalse);
    });
  });

  // ── Arquitetura × MetodoInstalacao ────────────────────────────────────────

  group('Arquitetura × Método —', () {
    test('MULTIPOLAR aceita A1 — exceção método 51', () {
      final e = entradaPadrao(
        arquitetura: Arquitetura.multipolar,
        metodo: MetodoInstalacao.a1,
      );
      expect(_arqMetViolada(spec, e), isFalse);
    });

    test('MULTIPOLAR aceita B1 — exceção método 43', () {
      final e = entradaPadrao(
        arquitetura: Arquitetura.multipolar,
        metodo: MetodoInstalacao.b1,
      );
      expect(_arqMetViolada(spec, e), isFalse);
    });

    test('ISOLADO aceita B2 — exceção método 26', () {
      final e = entradaPadrao(
        isolacao: Isolacao.pvc,
        arquitetura: Arquitetura.isolado,
        metodo: MetodoInstalacao.b2,
      );
      expect(_arqMetViolada(spec, e), isFalse);
    });

    test('UNIPOLAR aceita B2 — exceção métodos 23/25/27', () {
      final e = entradaPadrao(
        arquitetura: Arquitetura.unipolar,
        metodo: MetodoInstalacao.b2,
      );
      expect(_arqMetViolada(spec, e), isFalse);
    });

    test('UNIPOLAR não aceita E — COMB_002', () {
      final e = entradaPadrao(
        arquitetura: Arquitetura.unipolar,
        metodo: MetodoInstalacao.e,
      );
      final violacoes = spec.verificar(e);
      expect(_temCodigo(violacoes, 'COMB_002'), isTrue);
    });

    test('MULTIPOLAR não aceita F — COMB_002', () {
      final e = entradaPadrao(
        arquitetura: Arquitetura.multipolar,
        metodo: MetodoInstalacao.f,
      );
      final violacoes = spec.verificar(e);
      expect(_temCodigo(violacoes, 'COMB_002'), isTrue);
    });

    test('MULTIPOLAR não aceita E com arranjo — COMB_002 e COMB_004', () {
      final e = entradaPadrao(
        arquitetura: Arquitetura.multipolar,
        metodo: MetodoInstalacao.e,
        arranjo: ArranjoCondutores.trifolio, // E não aceita arranjo
      );
      final violacoes = spec.verificar(e);
      expect(_temCodigo(violacoes, 'COMB_004'), isTrue);
    });

    test('ISOLADO não aceita C — COMB_002', () {
      final e = entradaPadrao(
        isolacao: Isolacao.pvc,
        arquitetura: Arquitetura.isolado,
        metodo: MetodoInstalacao.c,
      );
      final violacoes = spec.verificar(e);
      expect(_temCodigo(violacoes, 'COMB_002'), isTrue);
    });

    test('ISOLADO aceita G', () {
      final e = entradaPadrao(
        isolacao: Isolacao.pvc,
        arquitetura: Arquitetura.isolado,
        metodo: MetodoInstalacao.g,
        arranjo: ArranjoCondutores.espacadoHorizontal,
      );
      expect(_arqMetViolada(spec, e), isFalse);
    });

    test('MULTIPOLAR não aceita G — COMB_002', () {
      final e = entradaPadrao(
        arquitetura: Arquitetura.multipolar,
        metodo: MetodoInstalacao.g,
        arranjo: ArranjoCondutores.espacadoHorizontal,
      );
      final violacoes = spec.verificar(e);
      expect(_temCodigo(violacoes, 'COMB_002'), isTrue);
    });
  });

  // ── ArranjoCondutores ─────────────────────────────────────────────────────

  group('ArranjoCondutores —', () {
    test('Método F sem arranjo — COMB_003', () {
      final e = entradaPadrao(
        arquitetura: Arquitetura.unipolar,
        metodo: MetodoInstalacao.f,
        arranjo: null,
      );
      final violacoes = spec.verificar(e);
      expect(_temCodigo(violacoes, 'COMB_003'), isTrue);
    });

    test('Método G sem arranjo — COMB_003', () {
      final e = entradaPadrao(
        isolacao: Isolacao.pvc,
        arquitetura: Arquitetura.isolado,
        metodo: MetodoInstalacao.g,
        arranjo: null,
      );
      final violacoes = spec.verificar(e);
      expect(_temCodigo(violacoes, 'COMB_003'), isTrue);
    });

    test('Método F com trifolio — válido', () {
      final e = entradaPadrao(
        arquitetura: Arquitetura.unipolar,
        metodo: MetodoInstalacao.f,
        arranjo: ArranjoCondutores.trifolio,
      );
      expect(_arranjoViolado(spec, e), isFalse);
    });

    test('Método G com arranjo de F — COMB_005', () {
      final e = entradaPadrao(
        arquitetura: Arquitetura.unipolar,
        metodo: MetodoInstalacao.g,
        arranjo: ArranjoCondutores.trifolio,
      );
      final violacoes = spec.verificar(e);
      expect(_temCodigo(violacoes, 'COMB_005'), isTrue);
    });

    test('Método B1 com arranjo informado — COMB_004', () {
      final e = entradaPadrao(
        metodo: MetodoInstalacao.b1,
        arranjo: ArranjoCondutores.trifolio,
      );
      final violacoes = spec.verificar(e);
      expect(_temCodigo(violacoes, 'COMB_004'), isTrue);
    });
  });

  // ── Tensao × NumeroFases ──────────────────────────────────────────────────

  group('Tensao × NumeroFases —', () {
    test('V127 aceita monofásico', () {
      final e = entradaPadrao(
        tensao: Tensao.v127,
        numeroFases: NumeroFases.monofasico,
      );
      expect(_tensaoFasesViolada(spec, e), isFalse);
    });

    test('V127 não aceita trifásico — COMB_006', () {
      final e = entradaPadrao(
        tensao: Tensao.v127,
        numeroFases: NumeroFases.trifasico,
      );
      final violacoes = spec.verificar(e);
      expect(_temCodigo(violacoes, 'COMB_006'), isTrue);
    });

    test('V380 aceita trifásico', () {
      final e = entradaPadrao(
        tensao: Tensao.v380,
        numeroFases: NumeroFases.trifasico,
      );
      expect(_tensaoFasesViolada(spec, e), isFalse);
    });

    test('V380 não aceita monofásico — COMB_006', () {
      final e = entradaPadrao(
        tensao: Tensao.v380,
        numeroFases: NumeroFases.monofasico,
      );
      final violacoes = spec.verificar(e);
      expect(_temCodigo(violacoes, 'COMB_006'), isTrue);
    });

    test('V220 aceita bifásico', () {
      final e = entradaPadrao(
        tensao: Tensao.v220,
        numeroFases: NumeroFases.bifasico,
      );
      expect(_tensaoFasesViolada(spec, e), isFalse);
    });

    test('Acumula múltiplas violações independentes', () {
      final e = entradaPadrao(
        tensao: Tensao.v127,
        numeroFases: NumeroFases.trifasico,
        isolacao: Isolacao.xlpe,
        arquitetura: Arquitetura.isolado,
        metodo: MetodoInstalacao.e,
      );
      final violacoes = spec.verificar(e);
      expect(violacoes.length, greaterThanOrEqualTo(3));
    });
  });
}

// ── Helpers ───────────────────────────────────────────────────────────────

bool _temCodigo(List<Violacao> v, String codigo) =>
    v.any((vi) => vi.codigo == codigo);

bool _combinacaoViolada(SpecCombinacoes spec, EntradaNormativa e) =>
    spec.verificar(e).any((v) => v.codigo == 'COMB_001');

bool _arqMetViolada(SpecCombinacoes spec, EntradaNormativa e) =>
    spec.verificar(e).any((v) => v.codigo == 'COMB_002');

bool _arranjoViolado(SpecCombinacoes spec, EntradaNormativa e) =>
    spec.verificar(e).any((v) =>
        v.codigo == 'COMB_003' ||
        v.codigo == 'COMB_004' ||
        v.codigo == 'COMB_005');

bool _tensaoFasesViolada(SpecCombinacoes spec, EntradaNormativa e) =>
    spec.verificar(e).any((v) => v.codigo == 'COMB_006');
