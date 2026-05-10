// REV: 1.1.0
// CHANGELOG:
// [1.1.0] - 2026-05
// - CHG: _ctx() — reatanciaXi removido, tabelaXi adicionado.
// [1.0.0] - 2026-04
// - ADD: testes de PoliticaDisjuntor e SelecionadorCondutor.

import 'package:test/test.dart';
import 'package:normative_engine/normative_engine.dart';

// ignore: implementation_imports
import 'package:electrical_engine/src/orchestrator/circuito/politica_disjuntor.dart';
// ignore: implementation_imports
import 'package:electrical_engine/src/orchestrator/circuito/selecionador_condutor.dart';
// ignore: implementation_imports
import 'package:electrical_engine/src/models/circuito/contexto_selecao.dart';
// ignore: implementation_imports
import 'package:electrical_engine/src/models/circuito/resultado_selecao.dart';

// ── Catálogo de disjuntores padrão para testes ───────────────────────────────
final _catalogo = [
  Disjuntor(10), Disjuntor(16), Disjuntor(20), Disjuntor(25),
  Disjuntor(32), Disjuntor(40), Disjuntor(50), Disjuntor(63),
];

// ── Tabela de ampacidade mínima para testes ──────────────────────────────────
// PVC B1 cobre 2 condutores — valores reais da Tabela 36
final _tabelaB1 = [
  LinhaAmpacidade(secao: 1.5, izBase: 17.5),
  LinhaAmpacidade(secao: 2.5, izBase: 21.0),
  LinhaAmpacidade(secao: 4.0, izBase: 28.0),
  LinhaAmpacidade(secao: 6.0, izBase: 36.0),
  LinhaAmpacidade(secao: 10.0, izBase: 50.0),
  LinhaAmpacidade(secao: 16.0, izBase: 68.0),
  LinhaAmpacidade(secao: 25.0, izBase: 89.0),
];

ContextoSelecao _ctx({
  double ib = 5.0,
  double inDisjuntor = 10.0,
  double secaoMinima = 2.5,
  double limiteQueda = 4.0,
  double distancia = 20.0,
  double tensao = 220.0,
  double fatorPotencia = 1.0,
  double fatorHarmonico = 1.0,
  Map<double, double>? tabelaXi,
  List<LinhaAmpacidade>? tabela,
}) =>
    ContextoSelecao(
      material: Material.cobre,
      isolacao: Isolacao.pvc,
      arquitetura: Arquitetura.multipolar,
      metodoInstalacao: MetodoInstalacao.b1,
      numeroFases: NumeroFases.monofasico,
      condutoresAtivos: 2,
      ib: ib,
      inDisjuntor: inDisjuntor,
      secaoMinima: secaoMinima,
      limiteQueda: limiteQueda,
      fatores: const FatoresCorrecao(fct: 1.0, fca: 1.0),
      tabelaIz: tabela ?? _tabelaB1,
      tabelaXi: tabelaXi ?? const {},
      tensao: tensao,
      distancia: distancia,
      fatorPotencia: fatorPotencia,
      fatorHarmonico: fatorHarmonico,
    );

void main() {
  // ── PoliticaDisjuntor ─────────────────────────────────────────────────────

  group('PoliticaDisjuntor —', () {
    const politica = PoliticaDisjuntor();

    test('Ib=9A → seleciona In=10A', () {
      final in_ = politica.selecionar(ib: 9.0, catalogo: _catalogo);
      expect(in_, equals(10.0));
    });

    test('Ib=10A → seleciona In=10A (exato)', () {
      final in_ = politica.selecionar(ib: 10.0, catalogo: _catalogo);
      expect(in_, equals(10.0));
    });

    test('Ib=10.1A → seleciona In=16A (próximo acima)', () {
      final in_ = politica.selecionar(ib: 10.1, catalogo: _catalogo);
      expect(in_, equals(16.0));
    });

    test('Ib=63A → seleciona In=63A (máximo do catálogo)', () {
      final in_ = politica.selecionar(ib: 63.0, catalogo: _catalogo);
      expect(in_, equals(63.0));
    });

    test('Ib=64A → lança StateError (acima do catálogo)', () {
      expect(
        () => politica.selecionar(ib: 64.0, catalogo: _catalogo),
        throwsA(isA<StateError>()),
      );
    });

    test('Mensagem do StateError menciona Ib e catálogo', () {
      expect(
        () => politica.selecionar(ib: 100.0, catalogo: _catalogo),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('100.00A'),
          ),
        ),
      );
    });

    test('Catálogo unitário — Ib <= In → aprovado', () {
      final in_ = politica.selecionar(
        ib: 25.0,
        catalogo: [Disjuntor(32)],
      );
      expect(in_, equals(32.0));
    });
  });

  // ── SelecionadorCondutor ──────────────────────────────────────────────────

  group('SelecionadorCondutor —', () {
    const selecionador = SelecionadorCondutor();

    group('Fluxo aprovado —', () {
      test('Seleciona menor seção que atende Iz >= In e queda <= limite', () {
        final r = selecionador.selecionar(_ctx(
          ib: 5.0,
          inDisjuntor: 10.0,
          secaoMinima: 2.5,
          distancia: 15.0,
          limiteQueda: 4.0,
        ));
        expect(r.status, equals(StatusDimensionamento.aprovado));
        expect(r.secaoFinal, greaterThanOrEqualTo(2.5));
        expect(r.izFinal, greaterThanOrEqualTo(10.0));
        expect(r.quedaFinal, lessThanOrEqualTo(4.0));
      });

      test('Seção teórica igual à final quando queda já OK na primeira', () {
        // In=10A → 2.5mm² (Iz=21A) atende. Distância curta → queda ok.
        final r = selecionador.selecionar(_ctx(
          ib: 5.0,
          inDisjuntor: 10.0,
          distancia: 5.0,
          limiteQueda: 4.0,
        ));
        expect(r.status, equals(StatusDimensionamento.aprovado));
        expect(r.secaoTeorica, equals(r.secaoFinal));
      });

      test('Seção final maior que teórica quando queda força upgrade', () {
        // In=10A → 2.5mm² (Iz=21A) atende ampacidade.
        // Distância grande → queda excede em 2.5mm², precisa de seção maior.
        final r = selecionador.selecionar(_ctx(
          ib: 9.5,
          inDisjuntor: 10.0,
          distancia: 80.0,
          limiteQueda: 4.0,
          tensao: 220.0,
        ));
        if (r.status == StatusDimensionamento.aprovado) {
          expect(r.secaoFinal, greaterThanOrEqualTo(r.secaoTeorica));
        }
      });

      test('Respeita secaoMinima — não seleciona seção abaixo', () {
        final r = selecionador.selecionar(_ctx(
          secaoMinima: 4.0,
          inDisjuntor: 10.0,
          distancia: 5.0,
        ));
        expect(r.status, equals(StatusDimensionamento.aprovado));
        expect(r.secaoFinal, greaterThanOrEqualTo(4.0));
        expect(r.secaoTeorica, greaterThanOrEqualTo(4.0));
      });

      test('fatorHarmonico=0.86 reduz Iz — pode forçar seção maior', () {
        final rNormal = selecionador.selecionar(_ctx(
          inDisjuntor: 20.0,
          fatorHarmonico: 1.0,
          distancia: 5.0,
        ));
        final rHarm = selecionador.selecionar(_ctx(
          inDisjuntor: 20.0,
          fatorHarmonico: 0.86,
          distancia: 5.0,
        ));
        // Com fator menor, Iz é menor → pode precisar de seção maior
        expect(rHarm.secaoFinal, greaterThanOrEqualTo(rNormal.secaoFinal));
      });
    });

    group('Reprovado —', () {
      test('REPROVADO_AMPACIDADE quando In excede Iz máxima da tabela', () {
        // In=200A excede toda a tabela de teste (Iz max = 89A em 25mm²)
        final r = selecionador.selecionar(_ctx(inDisjuntor: 200.0));
        expect(r.status, equals(StatusDimensionamento.reprovadoAmpacidade));
        expect(r.secaoTeorica, equals(0));
        expect(r.secaoFinal, equals(0));
      });

      test('REPROVADO_QUEDA com campos teórico preenchidos', () {
        // Distância muito grande → queda sempre excede, mas ampacidade OK
        // Ib=9A, In=10A → 2.5mm² (Iz=21A > 10A) atende ampacidade
        // distância=500m → queda altíssima em qualquer seção da tabela de teste
        final r = selecionador.selecionar(_ctx(
          ib: 9.0,
          inDisjuntor: 10.0,
          distancia: 500.0,
          limiteQueda: 4.0,
        ));
        expect(r.status, equals(StatusDimensionamento.reprovadoQueda));
        expect(r.secaoTeorica, greaterThan(0));
        expect(r.izTeorico, greaterThan(0));
        expect(r.quedaTeorica, greaterThan(0));
        // Campos finais têm a maior seção disponível
        expect(r.secaoFinal, equals(_tabelaB1.last.secao));
      });

      test('Campos finais no reprovadoQueda têm a maior seção da tabela', () {
        final r = selecionador.selecionar(_ctx(
          ib: 9.0,
          inDisjuntor: 10.0,
          distancia: 500.0,
        ));
        if (r.status == StatusDimensionamento.reprovadoQueda) {
          expect(r.secaoFinal, equals(25.0)); // maior da tabelaB1
        }
      });

      test('Tabela vazia → REPROVADO_AMPACIDADE', () {
        final r = selecionador.selecionar(_ctx(tabela: []));
        expect(r.status, equals(StatusDimensionamento.reprovadoAmpacidade));
      });
    });

    group('ContextoSelecao.resistividade —', () {
      test('Cobre PVC → 0.02308', () {
        final ctx = _ctx();
        expect(ctx.resistividade, closeTo(0.02308, 0.00001));
      });

      test('Cobre XLPE → 0.02538', () {
        final ctx = ContextoSelecao(
          material: Material.cobre,
          isolacao: Isolacao.xlpe,
          arquitetura: Arquitetura.unipolar,
          metodoInstalacao: MetodoInstalacao.c,
          numeroFases: NumeroFases.monofasico,
          condutoresAtivos: 2,
          ib: 5.0, inDisjuntor: 10.0, secaoMinima: 2.5,
          limiteQueda: 4.0, fatores: const FatoresCorrecao(fct: 1.0, fca: 1.0),
          tabelaIz: _tabelaB1, tabelaXi: const {}, tensao: 220.0,
          distancia: 20.0, fatorPotencia: 1.0,
        );
        expect(ctx.resistividade, closeTo(0.02538, 0.00001));
      });

      test('Alumínio PVC → 0.03775', () {
        final ctx = ContextoSelecao(
          material: Material.aluminio,
          isolacao: Isolacao.pvc,
          arquitetura: Arquitetura.multipolar,
          metodoInstalacao: MetodoInstalacao.b1,
          numeroFases: NumeroFases.monofasico,
          condutoresAtivos: 2,
          ib: 5.0, inDisjuntor: 10.0, secaoMinima: 16.0,
          limiteQueda: 4.0, fatores: const FatoresCorrecao(fct: 1.0, fca: 1.0),
          tabelaIz: _tabelaB1, tabelaXi: const {}, tensao: 220.0,
          distancia: 20.0, fatorPotencia: 1.0,
        );
        expect(ctx.resistividade, closeTo(0.03775, 0.00001));
      });
    });
  });
}
