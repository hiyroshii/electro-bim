// REV: 1.2.0
// CHANGELOG:
// [1.2.0] - 2026-05
// - ADD: testes de COMB_007 (faixas de tensão no conduto) e COMB_008 (multipolar exclusivo).
// [1.1.0] - 2026-05
// - ADD: testes de temperatura admissível por isolação (TEMP_001).
// [1.0.0] - 2026-04
// - ADD: testes de combinações válidas iso × arq × método × arranjo × tensão.

import 'package:test/test.dart';
import 'package:normative_engine/normative_engine.dart';
import '../test_helpers.dart';

// ignore: implementation_imports
import 'package:normative_engine/src/specification/condutor/spec_combinacoes.dart';

void main() {
  const spec = SpecCombinacoes();

  // ── Isolacao × Arquitetura ────────────────────────────────────────────────

  group('Isolacao × Arquitetura —', () {
    test('PVC aceita ISOLADO', () {
      final e = entradaPadrao(
        arquitetura: Arquitetura.isolado,
      );
      expect(_combinacaoViolada(spec, e), isFalse);
    });

    test('PVC aceita UNIPOLAR', () {
      final e = entradaPadrao(
        arquitetura: Arquitetura.unipolar,
        metodo: MetodoInstalacao.c,
      );
      expect(_combinacaoViolada(spec, e), isFalse);
    });

    test('PVC aceita MULTIPOLAR', () {
      final e = entradaPadrao(
        
      );
      expect(_combinacaoViolada(spec, e), isFalse);
    });

    test('XLPE não aceita ISOLADO — COMB_001', () {
      final e = entradaPadrao(
        isolacao: Isolacao.xlpe,
        arquitetura: Arquitetura.isolado,
      );
      final violacoes = spec.verificar(e);
      expect(_temCodigo(violacoes, 'COMB_001'), isTrue);
    });

    test('EPR não aceita ISOLADO — COMB_001', () {
      final e = entradaPadrao(
        isolacao: Isolacao.epr,
        arquitetura: Arquitetura.isolado,
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
        metodo: MetodoInstalacao.a1,
      );
      expect(_arqMetViolada(spec, e), isFalse);
    });

    test('MULTIPOLAR aceita B1 — exceção método 43', () {
      final e = entradaPadrao(
        
      );
      expect(_arqMetViolada(spec, e), isFalse);
    });

    test('ISOLADO aceita B2 — exceção método 26', () {
      final e = entradaPadrao(
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
        metodo: MetodoInstalacao.f,
      );
      final violacoes = spec.verificar(e);
      expect(_temCodigo(violacoes, 'COMB_002'), isTrue);
    });

    test('MULTIPOLAR não aceita E com arranjo — COMB_002 e COMB_004', () {
      final e = entradaPadrao(
        metodo: MetodoInstalacao.e,
        arranjo: ArranjoCondutores.trifolio, // E não aceita arranjo
      );
      final violacoes = spec.verificar(e);
      expect(_temCodigo(violacoes, 'COMB_004'), isTrue);
    });

    test('ISOLADO não aceita C — COMB_002', () {
      final e = entradaPadrao(
        arquitetura: Arquitetura.isolado,
        metodo: MetodoInstalacao.c,
      );
      final violacoes = spec.verificar(e);
      expect(_temCodigo(violacoes, 'COMB_002'), isTrue);
    });

    test('ISOLADO aceita G', () {
      final e = entradaPadrao(
        arquitetura: Arquitetura.isolado,
        metodo: MetodoInstalacao.g,
        arranjo: ArranjoCondutores.espacadoHorizontal,
      );
      expect(_arqMetViolada(spec, e), isFalse);
    });

    test('MULTIPOLAR não aceita G — COMB_002', () {
      final e = entradaPadrao(
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
      );
      final violacoes = spec.verificar(e);
      expect(_temCodigo(violacoes, 'COMB_003'), isTrue);
    });

    test('Método G sem arranjo — COMB_003', () {
      final e = entradaPadrao(
        arquitetura: Arquitetura.isolado,
        metodo: MetodoInstalacao.g,
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
      );
      final violacoes = spec.verificar(e);
      expect(_temCodigo(violacoes, 'COMB_006'), isTrue);
    });

    test('V220 aceita bifásico', () {
      final e = entradaPadrao(
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

  // ── Temperatura admissível ────────────────────────────────────────────────

  group('Temperatura admissível —', () {
    test('PVC em 30°C (referência) — sem violação', () {
      final e = entradaPadrao();
      expect(_tempViolada(spec, e), isFalse);
    });

    test('PVC em 60°C — limite válido', () {
      final e = entradaPadrao(temperatura: 60);
      expect(_tempViolada(spec, e), isFalse);
    });

    test('PVC em 65°C — inadmissível — TEMP_001', () {
      final e = entradaPadrao(temperatura: 65);
      final violacoes = spec.verificar(e);
      expect(_temCodigo(violacoes, 'TEMP_001'), isTrue);
    });

    test('PVC em 80°C — inadmissível — TEMP_001', () {
      final e = entradaPadrao(temperatura: 80);
      final violacoes = spec.verificar(e);
      expect(_temCodigo(violacoes, 'TEMP_001'), isTrue);
    });

    test('XLPE em 80°C — válido (máximo da tabela)', () {
      final e = entradaPadrao(
        isolacao: Isolacao.xlpe,
        arquitetura: Arquitetura.unipolar,
        metodo: MetodoInstalacao.c,
        temperatura: 80,
      );
      expect(_tempViolada(spec, e), isFalse);
    });

    test('EPR em 75°C — válido', () {
      final e = entradaPadrao(
        isolacao: Isolacao.epr,
        arquitetura: Arquitetura.unipolar,
        metodo: MetodoInstalacao.c,
        temperatura: 75,
      );
      expect(_tempViolada(spec, e), isFalse);
    });

    test('PVC em temperatura fora da tabela (22°C) — TEMP_001', () {
      final e = entradaPadrao(temperatura: 22);
      final violacoes = spec.verificar(e);
      expect(_temCodigo(violacoes, 'TEMP_001'), isTrue);
    });

    test('Método D usa tabela de solo — PVC 60°C válido', () {
      final e = entradaPadrao(
        arquitetura: Arquitetura.unipolar,
        metodo: MetodoInstalacao.d,
        temperatura: 60,
      );
      expect(_tempViolada(spec, e), isFalse);
    });

    test('Método D usa tabela de solo — PVC 65°C inadmissível — TEMP_001', () {
      final e = entradaPadrao(
        arquitetura: Arquitetura.unipolar,
        metodo: MetodoInstalacao.d,
        temperatura: 65,
      );
      final violacoes = spec.verificar(e);
      expect(_temCodigo(violacoes, 'TEMP_001'), isTrue);
    });
  });

  // ── COMB_007 — faixas de tensão no mesmo conduto ─────────────────────────

  group('COMB_007 — faixas de tensão no conduto —', () {
    test('Sem outrasCircuitosNoConduto (default) → sem violação', () {
      final e = entradaPadrao();
      expect(_temCodigo(spec.verificar(e), 'COMB_007'), isFalse);
    });

    test('outrasCircuitos: [faixaII], circuito faixaII → sem violação', () {
      final e = entradaPadrao(
        outrasCircuitosNoConduto: [FaixaTensao.faixaII],
      );
      expect(_temCodigo(spec.verificar(e), 'COMB_007'), isFalse);
    });

    test('outrasCircuitos: [faixaI], circuito faixaII → COMB_007', () {
      final e = entradaPadrao(
        outrasCircuitosNoConduto: [FaixaTensao.faixaI],
      );
      expect(_temCodigo(spec.verificar(e), 'COMB_007'), isTrue);
    });

    test('outrasCircuitos: [faixaII], circuito faixaI → COMB_007', () {
      final e = entradaPadrao(
        faixaTensao: FaixaTensao.faixaI,
        outrasCircuitosNoConduto: [FaixaTensao.faixaII],
      );
      expect(_temCodigo(spec.verificar(e), 'COMB_007'), isTrue);
    });

    test('Dois circuitos mesma faixaI → sem violação', () {
      final e = entradaPadrao(
        faixaTensao: FaixaTensao.faixaI,
        outrasCircuitosNoConduto: [FaixaTensao.faixaI],
      );
      expect(_temCodigo(spec.verificar(e), 'COMB_007'), isFalse);
    });

    test('COMB_007 — referência normativa correta', () {
      final e = entradaPadrao(
        outrasCircuitosNoConduto: [FaixaTensao.faixaI],
      );
      final v = spec.verificar(e).firstWhere((final v) => v.codigo == 'COMB_007');
      expect(v.referencia, contains('6.2.9.5'));
    });
  });

  // ── COMB_008 — multipolar exclusivo por circuito ──────────────────────────

  group('COMB_008 — multipolar exclusivo —', () {
    test('Multipolar + compartilhaCabo: false (default) → sem violação', () {
      final e = entradaPadrao(
        
      );
      expect(_temCodigo(spec.verificar(e), 'COMB_008'), isFalse);
    });

    test('Multipolar + compartilhaCabo: true → COMB_008', () {
      final e = entradaPadrao(
        compartilhaCaboMultipolar: true,
      );
      expect(_temCodigo(spec.verificar(e), 'COMB_008'), isTrue);
    });

    test('Unipolar + compartilhaCabo: true → sem violação', () {
      final e = entradaPadrao(
        arquitetura: Arquitetura.unipolar,
        metodo: MetodoInstalacao.c,
        compartilhaCaboMultipolar: true,
      );
      expect(_temCodigo(spec.verificar(e), 'COMB_008'), isFalse);
    });

    test('Isolado + compartilhaCabo: true → sem violação', () {
      final e = entradaPadrao(
        arquitetura: Arquitetura.isolado,
        compartilhaCaboMultipolar: true,
      );
      expect(_temCodigo(spec.verificar(e), 'COMB_008'), isFalse);
    });

    test('COMB_008 — referência normativa correta', () {
      final e = entradaPadrao(
        compartilhaCaboMultipolar: true,
      );
      final v = spec.verificar(e).firstWhere((final v) => v.codigo == 'COMB_008');
      expect(v.referencia, contains('6.2.10.1'));
    });
  });
}

// ── Helpers ───────────────────────────────────────────────────────────────

bool _temCodigo(final List<Violacao> v, final String codigo) =>
    v.any((final vi) => vi.codigo == codigo);

bool _combinacaoViolada(final SpecCombinacoes spec, final EntradaNormativa e) =>
    spec.verificar(e).any((final v) => v.codigo == 'COMB_001');

bool _arqMetViolada(final SpecCombinacoes spec, final EntradaNormativa e) =>
    spec.verificar(e).any((final v) => v.codigo == 'COMB_002');

bool _arranjoViolado(final SpecCombinacoes spec, final EntradaNormativa e) =>
    spec.verificar(e).any((final v) =>
        v.codigo == 'COMB_003' ||
        v.codigo == 'COMB_004' ||
        v.codigo == 'COMB_005',);

bool _tensaoFasesViolada(final SpecCombinacoes spec, final EntradaNormativa e) =>
    spec.verificar(e).any((final v) => v.codigo == 'COMB_006');

bool _tempViolada(final SpecCombinacoes spec, final EntradaNormativa e) =>
    spec.verificar(e).any((final v) => v.codigo == 'TEMP_001');
