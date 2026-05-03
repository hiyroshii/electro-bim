// REV: 1.0.0
// CHANGELOG:
// [1.0.0] - 2026-04
// - ADD: testes de integração do NormativeService (fluxo completo).

import 'package:test/test.dart';
import 'package:normative_engine/normative_engine.dart';
import '../test_helpers.dart';

// ignore: implementation_imports
import 'package:normative_engine/src/procedure/proc_ampacidade.dart';

NormativeService _criarService({
  OrigemAlimentacao origem = OrigemAlimentacao.pontoEntrega,
  ContextoInstalacao contexto = ContextoInstalacao.industrial,
}) =>
    NormativeService(
      origemAlimentacao: origem,
      contextoInstalacao: contexto,
    );

final _paramsUnico = const ParamsAgrupamento(numCircuitos: 1);

void main() {
  // ── verificarConformidade ─────────────────────────────────────────────────

  group('verificarConformidade —', () {
    test('Entrada válida — sem violações', () {
      final service = _criarService();
      final e = entradaPadrao();
      expect(service.verificarConformidade(e), isEmpty);
    });

    test('Combinação inválida — retorna violações', () {
      final service = _criarService();
      final e = entradaPadrao(
        isolacao: Isolacao.xlpe,
        arquitetura: Arquitetura.isolado,
        metodo: MetodoInstalacao.b1,
      );
      expect(service.verificarConformidade(e), isNotEmpty);
    });

    test('Alumínio em BD4 — retorna violação', () {
      final service = _criarService(contexto: ContextoInstalacao.bd4);
      final e = entradaPadrao(material: Material.aluminio);
      final violacoes = service.verificarConformidade(e);
      expect(violacoes.any((v) => v.codigo == 'ALU_001'), isTrue);
    });
  });

  // ── resolverDadosNormativos ───────────────────────────────────────────────

  group('resolverDadosNormativos —', () {
    test('Retorna DadosNormativos populados', () {
      final service = _criarService();
      final e = entradaPadrao();
      final dados = service.resolverDadosNormativos(e, _paramsUnico);

      expect(dados.tabelaIz, isNotEmpty);
      expect(dados.fatores.fct, equals(1.0));
      expect(dados.fatores.fca, equals(1.0));
      expect(dados.queda.limitePercent, equals(4.0));
      expect(dados.secaoMinimaNormativa, equals(2.5));
    });

    test('TUG cobre — seção mínima 2.5mm²', () {
      final service = _criarService();
      final e = entradaPadrao(
        tagCircuito: TagCircuito.tug,
        material: Material.cobre,
      );
      final dados = service.resolverDadosNormativos(e, _paramsUnico);
      expect(dados.secaoMinimaNormativa, equals(2.5));
    });

    test('IL cobre — seção mínima 1.5mm²', () {
      final service = _criarService();
      final e = entradaPadrao(
        tagCircuito: TagCircuito.il,
        material: Material.cobre,
      );
      final dados = service.resolverDadosNormativos(e, _paramsUnico);
      expect(dados.secaoMinimaNormativa, equals(1.5));
    });
  });

  // ── auditar ───────────────────────────────────────────────────────────────

  group('auditar —', () {
    test('Resultado válido — sem violações', () {
      final service = _criarService();
      final e = entradaPadrao(tagCircuito: TagCircuito.tug);
      final resultado = ResultadoNormativo(
        secaoFase: 2.5,
        secaoNeutro: 2.5,
        quedaPercent: 3.5,
      );
      expect(service.auditar(e, resultado), isEmpty);
    });

    test('Seção abaixo do mínimo — SEC_001', () {
      final service = _criarService();
      final e = entradaPadrao(tagCircuito: TagCircuito.tug);
      final resultado = ResultadoNormativo(
        secaoFase: 1.5,
        secaoNeutro: 1.5,
        quedaPercent: 3.5,
      );
      final violacoes = service.auditar(e, resultado);
      expect(violacoes.any((v) => v.codigo == 'SEC_001'), isTrue);
    });

    test('Queda excedida — QUEDA_001', () {
      final service = _criarService();
      final e = entradaPadrao(tagCircuito: TagCircuito.tug);
      final resultado = ResultadoNormativo(
        secaoFase: 2.5,
        secaoNeutro: 2.5,
        quedaPercent: 4.5,
      );
      final violacoes = service.auditar(e, resultado);
      expect(violacoes.any((v) => v.codigo == 'QUEDA_001'), isTrue);
    });

    test('Neutro inferior à fase — NEUTRO_002', () {
      final service = _criarService();
      final e = entradaPadrao(
        tagCircuito: TagCircuito.tug,
        numeroFases: NumeroFases.monofasico,
      );
      final resultado = ResultadoNormativo(
        secaoFase: 4.0,
        secaoNeutro: 2.5,
        quedaPercent: 3.0,
      );
      final violacoes = service.auditar(e, resultado);
      expect(violacoes.any((v) => v.codigo == 'NEUTRO_002'), isTrue);
    });

    test('Múltiplas violações acumuladas na auditoria', () {
      final service = _criarService();
      final e = entradaPadrao(
        tagCircuito: TagCircuito.tug,
        numeroFases: NumeroFases.monofasico,
      );
      final resultado = ResultadoNormativo(
        secaoFase: 1.5,   // abaixo do mínimo (TUG = 2.5)
        secaoNeutro: 1.0, // neutro < fase
        quedaPercent: 5.0, // acima do limite (4%)
      );
      final violacoes = service.auditar(e, resultado);
      expect(violacoes.length, greaterThanOrEqualTo(3));
    });
  });

  // ── Fluxo completo ────────────────────────────────────────────────────────

  group('Fluxo completo —', () {
    test('Entrada inválida não chega à auditoria', () {
      final service = _criarService();
      final e = entradaPadrao(
        isolacao: Isolacao.xlpe,
        arquitetura: Arquitetura.isolado,
      );
      final violacoesEntrada = service.verificarConformidade(e);
      expect(violacoesEntrada, isNotEmpty);
      // Não chama resolverDadosNormativos nem auditar
    });

    test('Entrada válida → dados → auditoria OK', () {
      final service = _criarService();
      final e = entradaPadrao(
        tagCircuito: TagCircuito.il,
        isolacao: Isolacao.pvc,
        arquitetura: Arquitetura.multipolar,
        metodo: MetodoInstalacao.b1,
        material: Material.cobre,
        temperatura: 30,
      );

      expect(service.verificarConformidade(e), isEmpty);

      final dados = service.resolverDadosNormativos(e, _paramsUnico);
      expect(dados.tabelaIz, isNotEmpty);
      expect(dados.fatores.combinado, equals(1.0));

      final resultado = ResultadoNormativo(
        secaoFase: 1.5,
        secaoNeutro: 1.5,
        quedaPercent: 3.0,
      );
      expect(service.auditar(e, resultado), isEmpty);
    });
  });
}
