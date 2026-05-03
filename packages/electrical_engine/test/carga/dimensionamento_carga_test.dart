// REV: 1.0.0
// CHANGELOG:
// [1.0.0] - 2026-04
// - ADD: testes do GeradorPontosComodo, ValidadorComodo, AgregadorCircuitos
//        e DimensionamentoCargaService.

import 'package:normative_engine/normative_engine.dart';
import 'package:test/test.dart';

// ignore: implementation_imports
import 'package:electrical_engine/src/orchestrator/carga/gerador_pontos_comodo.dart';
// ignore: implementation_imports
import 'package:electrical_engine/src/orchestrator/carga/validador_comodo.dart';
// ignore: implementation_imports
import 'package:electrical_engine/src/orchestrator/carga/agregador_circuitos.dart';
// ignore: implementation_imports
import 'package:electrical_engine/src/orchestrator/carga/dimensionamento_carga_service.dart';
// ignore: implementation_imports
import 'package:electrical_engine/src/models/carga/comodo.dart';
// ignore: implementation_imports
import 'package:electrical_engine/src/models/carga/entrada_carga.dart';
// ignore: implementation_imports
import 'package:electrical_engine/src/models/carga/relatorio_carga.dart';

// ── Helpers ───────────────────────────────────────────────────────────────

Comodo _comodoVazio({
  String id = 'COM-001',
  RegraTomadasComodo regra = RegraTomadasComodo.porPerimetro,
  double areaM2 = 20.0,
  double perimetroM = 18.0,
  List<PontoUtilizacao> tug = const [],
  List<PontoUtilizacao> il = const [],
}) =>
    Comodo(
      id: id,
      idTipo: 'sala',
      label: 'Sala',
      regraTomadasComodo: regra,
      areaM2: areaM2,
      perimetroM: perimetroM,
      pontosTug: tug,
      pontosIl: il,
    );

PontoUtilizacao _tug(String id, {double va = 100}) =>
    PontoUtilizacao(idCircuito: id, tag: TagCircuito.tug, potenciaVA: va);

PontoUtilizacao _il(String id, {double va = 100}) =>
    PontoUtilizacao(idCircuito: id, tag: TagCircuito.il, potenciaVA: va);

void main() {
  // ── GeradorPontosComodo ───────────────────────────────────────────────────

  group('GeradorPontosComodo —', () {
    final gerador = GeradorPontosComodo();

    test('Perímetro 18m → 4 TUGs (ceil(18/5) = 4)', () {
      final r = gerador.gerar(_comodoVazio(perimetroM: 18.0));
      expect(r.tug.length, equals(4));
    });

    test('Perímetro 15m → 3 TUGs (15/5 = 3 exato)', () {
      final r = gerador.gerar(_comodoVazio(perimetroM: 15.0));
      expect(r.tug.length, equals(3));
    });

    test('Perímetro 3m → 1 TUG mínimo', () {
      final r = gerador.gerar(_comodoVazio(perimetroM: 3.0));
      expect(r.tug.length, equals(1));
    });

    test('Sempre gera 1 IL para porPerimetro', () {
      final r = gerador.gerar(_comodoVazio(perimetroM: 20.0));
      expect(r.il.length, equals(1));
    });

    test('Regra minimoFixo → 2 TUGs independente do perímetro', () {
      final r = gerador.gerar(_comodoVazio(
        regra: RegraTomadasComodo.minimoFixo,
        perimetroM: 3.0,
      ));
      expect(r.tug.length, equals(2));
      expect(r.il.length, equals(1));
    });

    test('Regra custom → listas vazias', () {
      final r = gerador.gerar(_comodoVazio(regra: RegraTomadasComodo.custom));
      expect(r.tug, isEmpty);
      expect(r.il, isEmpty);
    });

    test('Pontos TUG têm tag correta', () {
      final r = gerador.gerar(_comodoVazio());
      expect(r.tug.every((p) => p.tag == TagCircuito.tug), isTrue);
    });

    test('Pontos IL têm tag correta', () {
      final r = gerador.gerar(_comodoVazio());
      expect(r.il.every((p) => p.tag == TagCircuito.il), isTrue);
    });
  });

  // ── ValidadorComodo ───────────────────────────────────────────────────────

  group('ValidadorComodo —', () {
    const validador = ValidadorComodo();

    test('Cômodo com TUGs e ILs suficientes → aprovado', () {
      final comodo = _comodoVazio(
        perimetroM: 10.0, // exige 2 TUGs
        tug: [_tug('C-1'), _tug('C-2')],
        il: [_il('C-3')],
      );
      final r = validador.validar(comodo);
      expect(r.status, equals(StatusPrevisao.aprovado));
    });

    test('TUGs insuficientes → reprovadoNorma', () {
      final comodo = _comodoVazio(
        perimetroM: 18.0, // exige 4 TUGs
        tug: [_tug('C-1'), _tug('C-2')], // só 2
        il: [_il('C-3')],
      );
      final r = validador.validar(comodo);
      expect(r.status, equals(StatusPrevisao.reprovadoNorma));
    });

    test('Sem IL → reprovadoNorma', () {
      final comodo = _comodoVazio(
        perimetroM: 10.0,
        tug: [_tug('C-1'), _tug('C-2')],
        il: [], // sem IL
      );
      final r = validador.validar(comodo);
      expect(r.status, equals(StatusPrevisao.reprovadoNorma));
    });

    test('VA total calculado corretamente', () {
      final comodo = _comodoVazio(
        perimetroM: 10.0,
        tug: [_tug('C-1', va: 200), _tug('C-2', va: 300)],
        il: [_il('C-3', va: 100)],
      );
      final r = validador.validar(comodo);
      expect(r.vaTotalComodo, equals(600.0));
    });

    test('tugTotal e ilTotal no relatório', () {
      final comodo = _comodoVazio(
        perimetroM: 10.0,
        tug: [_tug('C-1'), _tug('C-2')],
        il: [_il('C-3')],
      );
      final r = validador.validar(comodo);
      expect(r.tugTotal, equals(2));
      expect(r.ilTotal, equals(1));
    });

    test('Regra custom — sem mínimos → sempre aprovado', () {
      final comodo = _comodoVazio(
        regra: RegraTomadasComodo.custom,
        tug: [], il: [],
      );
      final r = validador.validar(comodo);
      expect(r.status, equals(StatusPrevisao.aprovado));
    });
  });

  // ── AgregadorCircuitos ────────────────────────────────────────────────────

  group('AgregadorCircuitos —', () {
    const agregador = AgregadorCircuitos();

    test('Pontos com mesmo idCircuito são agrupados', () {
      final comodos = [
        _comodoVazio(tug: [_tug('C-1'), _tug('C-1')], il: []),
      ];
      final r = agregador.agregar(comodos);
      expect(r.where((c) => c.idCircuito == 'C-1').length, equals(1));
    });

    test('Potências somadas corretamente no mesmo circuito', () {
      final comodos = [
        _comodoVazio(
          tug: [_tug('C-1', va: 300), _tug('C-1', va: 400)],
          il: [],
        ),
      ];
      final r = agregador.agregar(comodos);
      final c1 = r.firstWhere((c) => c.idCircuito == 'C-1');
      expect(c1.potenciaVA, equals(700.0));
    });

    test('TUG dentro de 1500VA → aprovado', () {
      final comodos = [
        _comodoVazio(
          tug: [_tug('C-1', va: 1500)],
          il: [],
        ),
      ];
      final r = agregador.agregar(comodos);
      expect(r.first.status, equals(StatusCircuito.aprovado));
    });

    test('TUG acima de 1500VA → reprovado', () {
      final comodos = [
        _comodoVazio(
          tug: [_tug('C-1', va: 800), _tug('C-1', va: 800)],
          il: [],
        ),
      ];
      final r = agregador.agregar(comodos);
      expect(r.first.status, equals(StatusCircuito.reprovado));
    });

    test('IL acima de 600VA → reprovado', () {
      final comodos = [
        _comodoVazio(
          tug: [],
          il: [_il('C-2', va: 400), _il('C-2', va: 400)],
        ),
      ];
      final r = agregador.agregar(comodos);
      expect(r.first.status, equals(StatusCircuito.reprovado));
    });

    test('Circuitos de múltiplos cômodos agregados corretamente', () {
      final comodos = [
        _comodoVazio(id: 'COM-1', tug: [_tug('C-1')], il: []),
        _comodoVazio(id: 'COM-2', tug: [_tug('C-1'), _tug('C-2')], il: []),
      ];
      final r = agregador.agregar(comodos);
      final c1 = r.firstWhere((c) => c.idCircuito == 'C-1');
      expect(c1.potenciaVA, equals(200.0)); // 2 pontos × 100VA
    });
  });

  // ── DimensionamentoCargaService ───────────────────────────────────────────

  group('DimensionamentoCargaService —', () {
    final servico = DimensionamentoCargaService();

    test('criarComodoComSugestoes gera pontos automaticamente', () {
      final comodo = servico.criarComodoComSugestoes(
        idTipo: 'sala',
        label: 'Sala de Estar',
        regraTomadasComodo: RegraTomadasComodo.porPerimetro,
        areaM2: 20.0,
        perimetroM: 18.0,
      );
      expect(comodo.pontosTug.length, equals(4));
      expect(comodo.pontosIl.length, equals(1));
    });

    test('criarComodoCustom retorna cômodo sem pontos', () {
      final comodo = servico.criarComodoCustom(
        label: 'Área Técnica',
        areaM2: 5.0,
        perimetroM: 9.0,
      );
      expect(comodo.pontosTug, isEmpty);
      expect(comodo.pontosIl, isEmpty);
    });

    test('processar retorna RelatorioCarga com todos os cômodos', () {
      final comodo = servico.criarComodoComSugestoes(
        idTipo: 'sala',
        label: 'Sala',
        regraTomadasComodo: RegraTomadasComodo.porPerimetro,
        areaM2: 20.0,
        perimetroM: 18.0,
      );
      final r = servico.processar(EntradaCarga(comodos: [comodo]));
      expect(r.previsoesPorComodo.length, equals(1));
    });

    test('Status OK quando cômodos aprovados', () {
      final comodo = servico.criarComodoComSugestoes(
        idTipo: 'sala',
        label: 'Sala',
        regraTomadasComodo: RegraTomadasComodo.porPerimetro,
        areaM2: 20.0,
        perimetroM: 18.0,
      );
      final r = servico.processar(EntradaCarga(comodos: [comodo]));
      expect(r.status, equals(StatusRelatorio.ok));
    });

    test('VA total é soma de todos os cômodos', () {
      final c1 = servico.criarComodoComSugestoes(
        idTipo: 'sala', label: 'Sala',
        regraTomadasComodo: RegraTomadasComodo.porPerimetro,
        areaM2: 20.0, perimetroM: 10.0, // 2 TUGs + 1 IL = 300VA
      );
      final c2 = servico.criarComodoComSugestoes(
        idTipo: 'quarto', label: 'Quarto',
        regraTomadasComodo: RegraTomadasComodo.porPerimetro,
        areaM2: 12.0, perimetroM: 14.0, // 3 TUGs + 1 IL = 400VA
      );
      final r = servico.processar(EntradaCarga(comodos: [c1, c2]));
      expect(r.vaTotalProjeto, greaterThan(0));
    });

    test('Status REPROVADO quando cômodo tem TUGs insuficientes', () {
      final comodoVazio = _comodoVazio(
        perimetroM: 18.0, // exige 4 TUGs
        tug: [_tug('C-1')], // só 1
        il: [_il('C-2')],
      );
      final r = servico.processar(EntradaCarga(comodos: [comodoVazio]));
      expect(r.status, equals(StatusRelatorio.reprovado));
    });

    test('Lista de circuitos no relatório', () {
      final comodo = servico.criarComodoComSugestoes(
        idTipo: 'sala', label: 'Sala',
        regraTomadasComodo: RegraTomadasComodo.porPerimetro,
        areaM2: 20.0, perimetroM: 18.0,
      );
      final r = servico.processar(EntradaCarga(comodos: [comodo]));
      expect(r.circuitos, isNotEmpty);
    });
  });
}
