// REV: 1.0.0
// CHANGELOG:
// [1.0.0] - 2026-04
// - ADD: testes de FCT, FCA e seleção de tabela Iz.

import 'package:test/test.dart';
import 'package:normative_engine/normative_engine.dart';
import '../test_helpers.dart';

// ignore: implementation_imports
import 'package:normative_engine/src/procedure/proc_ampacidade.dart';

void main() {
  const proc = ProcAmpacidade();

  // ── FCT ───────────────────────────────────────────────────────────────────

  group('FCT —', () {
    test('PVC a 30°C — FCT = 1.0 (referência)', () {
      final e = entradaPadrao();
      final r = proc.resolver((e, const ParamsAgrupamento(numCircuitos: 1)));
      expect(r.fatores.fct, equals(1.0));
    });

    test('PVC a 40°C — FCT = 0.87', () {
      final e = entradaPadrao(temperatura: 40);
      final r = proc.resolver((e, const ParamsAgrupamento(numCircuitos: 1)));
      expect(r.fatores.fct, closeTo(0.87, 0.001));
    });

    test('XLPE a 30°C — FCT = 1.0 (referência)', () {
      final e = entradaPadrao(
        isolacao: Isolacao.xlpe,
        arquitetura: Arquitetura.unipolar,
        metodo: MetodoInstalacao.c,
      );
      final r = proc.resolver((e, const ParamsAgrupamento(numCircuitos: 1)));
      expect(r.fatores.fct, equals(1.0));
    });

    test('XLPE a 70°C — FCT = 0.58', () {
      final e = entradaPadrao(
        isolacao: Isolacao.xlpe,
        arquitetura: Arquitetura.unipolar,
        metodo: MetodoInstalacao.c,
        temperatura: 70,
      );
      final r = proc.resolver((e, const ParamsAgrupamento(numCircuitos: 1)));
      expect(r.fatores.fct, closeTo(0.58, 0.001));
    });

    test('EPR compartilha FCT com XLPE', () {
      final eXlpe = entradaPadrao(
        isolacao: Isolacao.xlpe,
        arquitetura: Arquitetura.unipolar,
        metodo: MetodoInstalacao.c,
        temperatura: 50,
      );
      final eEpr = entradaPadrao(
        isolacao: Isolacao.epr,
        arquitetura: Arquitetura.unipolar,
        metodo: MetodoInstalacao.c,
        temperatura: 50,
      );
      final rXlpe = proc.resolver((eXlpe, const ParamsAgrupamento(numCircuitos: 1)));
      final rEpr = proc.resolver((eEpr, const ParamsAgrupamento(numCircuitos: 1)));
      expect(rXlpe.fatores.fct, equals(rEpr.fatores.fct));
    });

    test('Método D usa FCT solo — PVC 20°C = 1.0', () {
      final e = entradaPadrao(
        metodo: MetodoInstalacao.d,
        temperatura: 20,
      );
      final r = proc.resolver((e, const ParamsAgrupamento(numCircuitos: 1)));
      expect(r.fatores.fct, equals(1.0));
    });

    test('Método D usa FCT solo — PVC 30°C = 0.89', () {
      final e = entradaPadrao(
        metodo: MetodoInstalacao.d,
      );
      final r = proc.resolver((e, const ParamsAgrupamento(numCircuitos: 1)));
      expect(r.fatores.fct, closeTo(0.89, 0.001));
    });
  });

  // ── FCA ───────────────────────────────────────────────────────────────────

  group('FCA —', () {
    test('1 circuito — FCA = 1.0', () {
      final e = entradaPadrao();
      final r = proc.resolver((e, const ParamsAgrupamento(numCircuitos: 1)));
      expect(r.fatores.fca, equals(1.0));
    });

    test('2 circuitos em feixe — FCA = 0.80', () {
      final e = entradaPadrao();
      final r = proc.resolver((e, const ParamsAgrupamento(numCircuitos: 2)));
      expect(r.fatores.fca, closeTo(0.80, 0.001));
    });

    test('3 circuitos em feixe — FCA = 0.70', () {
      final e = entradaPadrao();
      final r = proc.resolver((e, const ParamsAgrupamento(numCircuitos: 3)));
      expect(r.fatores.fca, closeTo(0.70, 0.001));
    });

    test('FCT × FCA combinado correto', () {
      final e = entradaPadrao(temperatura: 40);
      final r = proc.resolver((e, const ParamsAgrupamento(numCircuitos: 3)));
      expect(r.fatores.combinado, closeTo(0.87 * 0.70, 0.001));
    });
  });

  // ── Seleção de tabela ─────────────────────────────────────────────────────

  group('Seleção de tabela —', () {
    test('PVC B1 cobre — tabela não vazia', () {
      final e = entradaPadrao(
        
      );
      final r = proc.resolver((e, const ParamsAgrupamento(numCircuitos: 1)));
      expect(r.tabelaIz, isNotEmpty);
    });

    test('PVC B1 cobre 2 condutores — 1.5mm² = 17.5A', () {
      final e = entradaPadrao(
        
      );
      final r = proc.resolver((e, const ParamsAgrupamento(numCircuitos: 1)));
      final linha = r.tabelaIz.firstWhere((final l) => l.secao == 1.5);
      expect(linha.izBase, equals(17.5));
    });

    test('XLPE C cobre 3 condutores — 2.5mm² = 30A', () {
      final e = entradaPadrao(
        isolacao: Isolacao.xlpe,
        arquitetura: Arquitetura.unipolar,
        metodo: MetodoInstalacao.c,
        numeroFases: NumeroFases.trifasico,
      );
      final r = proc.resolver((e, const ParamsAgrupamento(numCircuitos: 1)));
      final linha = r.tabelaIz.firstWhere((final l) => l.secao == 2.5);
      expect(linha.izBase, equals(30));
    });

    test('Tabela retornada está ordenada por seção crescente', () {
      final e = entradaPadrao(
        metodo: MetodoInstalacao.c,
      );
      final r = proc.resolver((e, const ParamsAgrupamento(numCircuitos: 1)));
      final secoes = r.tabelaIz.map((final l) => l.secao).toList();
      for (var i = 1; i < secoes.length; i++) {
        expect(secoes[i], greaterThan(secoes[i - 1]));
      }
    });

    test('PVC F trifólio — usa tabela EFG', () {
      final e = entradaPadrao(
        arquitetura: Arquitetura.unipolar,
        metodo: MetodoInstalacao.f,
        arranjo: ArranjoCondutores.trifolio,
        numeroFases: NumeroFases.trifasico,
      );
      final r = proc.resolver((e, const ParamsAgrupamento(numCircuitos: 1)));
      expect(r.tabelaIz, isNotEmpty);
      final linha = r.tabelaIz.firstWhere((final l) => l.secao == 1.5);
      expect(linha.izBase, equals(17));
    });

    test('Alumínio inicia em 16mm²', () {
      final e = entradaPadrao(
        material: Material.aluminio,
      );
      final r = proc.resolver((e, const ParamsAgrupamento(numCircuitos: 1)));
      expect(r.tabelaIz.first.secao, equals(16.0));
    });
  });
}
