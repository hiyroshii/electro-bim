// REV: 1.3.0
// CHANGELOG:
// [1.3.0] - 2026-05
// - ADD: ib, inDisjuntor, izFinal em ResultadoNormativo — exigidos por S-3.
// [1.2.0] - 2026-05
// - ADD: testes de calcularSecaoNeutro e DISP_001 em verificarConformidade.
// [1.1.0] - 2026-05
// - ADD: teste de resolverDadosNormativos — tabelaXi populada por material.
// [1.0.0] - 2026-04
// - ADD: testes de integração do NormativeService (fluxo completo).

import 'package:test/test.dart';
import 'package:normative_engine/normative_engine.dart';
import '../test_helpers.dart';

// ignore: implementation_imports
import 'package:normative_engine/src/orchestrator/normative_service.dart';


NormativeService _criarService({
  final OrigemAlimentacao origem = OrigemAlimentacao.pontoEntrega,
  final ContextoInstalacao contexto = ContextoInstalacao.industrial,
}) =>
    NormativeService(
      origemAlimentacao: origem,
      contextoInstalacao: contexto,
    );

const _paramsUnico = ParamsAgrupamento(numCircuitos: 1);

/// ResultadoNormativo com IB/In/Iz válidos para S-3 (sem violação de sobrecarga).
ResultadoNormativo _resultadoValido({
  final double ib = 10.0,
  final double inDisjuntor = 16.0,
  final double izFinal = 24.0,
  final double secaoFase = 2.5,
  final double secaoNeutro = 2.5,
  final double quedaPercent = 3.5,
}) =>
    ResultadoNormativo(
      ib: ib,
      inDisjuntor: inDisjuntor,
      izFinal: izFinal,
      secaoFase: secaoFase,
      secaoNeutro: secaoNeutro,
      quedaPercent: quedaPercent,
    );

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
      );
      expect(service.verificarConformidade(e), isNotEmpty);
    });

    test('Alumínio em BD4 — retorna violação', () {
      final service = _criarService(contexto: ContextoInstalacao.bd4);
      final e = entradaPadrao(material: Material.aluminio);
      final violacoes = service.verificarConformidade(e);
      expect(violacoes.any((final v) => v.codigo == 'ALU_001'), isTrue);
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

    test('tabelaXi cobre — populada com seções padrão', () {
      final service = _criarService();
      final e = entradaPadrao();
      final dados = service.resolverDadosNormativos(e, _paramsUnico);

      expect(dados.tabelaXi, isNotEmpty);
      expect(dados.tabelaXi.containsKey(2.5), isTrue);
      expect(dados.tabelaXi.containsKey(25.0), isTrue);
      expect(dados.tabelaXi[2.5], closeTo(0.000110, 0.000001));
    });

    test('tabelaXi alumínio — inicia em 16mm²', () {
      final service = _criarService();
      final e = entradaPadrao(material: Material.aluminio);
      final dados = service.resolverDadosNormativos(e, _paramsUnico);

      expect(dados.tabelaXi, isNotEmpty);
      expect(dados.tabelaXi.containsKey(16.0), isTrue);
      expect(dados.tabelaXi.containsKey(2.5), isFalse);
    });

    test('TUG cobre — seção mínima 2.5mm²', () {
      final service = _criarService();
      final e = entradaPadrao(
        
      );
      final dados = service.resolverDadosNormativos(e, _paramsUnico);
      expect(dados.secaoMinimaNormativa, equals(2.5));
    });

    test('IL cobre — seção mínima 1.5mm²', () {
      final service = _criarService();
      final e = entradaPadrao(
        tagCircuito: TagCircuito.il,
      );
      final dados = service.resolverDadosNormativos(e, _paramsUnico);
      expect(dados.secaoMinimaNormativa, equals(1.5));
    });
  });

  // ── auditar ───────────────────────────────────────────────────────────────

  group('auditar —', () {
    test('Resultado válido — sem violações', () {
      final service = _criarService();
      final e = entradaPadrao();
      expect(service.auditar(e, _resultadoValido()), isEmpty);
    });

    test('Seção abaixo do mínimo — SEC_001', () {
      final service = _criarService();
      final e = entradaPadrao();
      final resultado = _resultadoValido(secaoFase: 1.5, secaoNeutro: 1.5);
      final violacoes = service.auditar(e, resultado);
      expect(violacoes.any((final v) => v.codigo == 'SEC_001'), isTrue);
    });

    test('Queda excedida — QUEDA_001', () {
      final service = _criarService();
      final e = entradaPadrao();
      final resultado = _resultadoValido(quedaPercent: 4.5);
      final violacoes = service.auditar(e, resultado);
      expect(violacoes.any((final v) => v.codigo == 'QUEDA_001'), isTrue);
    });

    test('Neutro inferior à fase — NEUTRO_002', () {
      final service = _criarService();
      final e = entradaPadrao(
        
      );
      final resultado = _resultadoValido(secaoFase: 4.0);
      final violacoes = service.auditar(e, resultado);
      expect(violacoes.any((final v) => v.codigo == 'NEUTRO_002'), isTrue);
    });

    test('Múltiplas violações acumuladas na auditoria', () {
      final service = _criarService();
      final e = entradaPadrao(
        
      );
      final resultado = _resultadoValido(
        secaoFase: 1.5, // abaixo do mínimo (TUG = 2.5) → SEC_001
        secaoNeutro: 1.0, // neutro < fase → NEUTRO_002
        quedaPercent: 5.0, // acima do limite (4%) → QUEDA_001
      );
      final violacoes = service.auditar(e, resultado);
      expect(violacoes.length, greaterThanOrEqualTo(3));
    });

    test('Ib > In — SOBRE_001', () {
      final service = _criarService();
      final e = entradaPadrao();
      final resultado = _resultadoValido(ib: 20.0);
      final violacoes = service.auditar(e, resultado);
      expect(violacoes.any((final v) => v.codigo == 'SOBRE_001'), isTrue);
    });

    test('In > Iz — SOBRE_002', () {
      final service = _criarService();
      final e = entradaPadrao();
      final resultado = _resultadoValido(inDisjuntor: 32.0);
      final violacoes = service.auditar(e, resultado);
      expect(violacoes.any((final v) => v.codigo == 'SOBRE_002'), isTrue);
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
    });

    test('Entrada válida → dados → auditoria OK', () {
      final service = _criarService();
      final e = entradaPadrao(
        tagCircuito: TagCircuito.il,
      );

      expect(service.verificarConformidade(e), isEmpty);

      final dados = service.resolverDadosNormativos(e, _paramsUnico);
      expect(dados.tabelaIz, isNotEmpty);
      expect(dados.fatores.combinado, equals(1.0));

      expect(
        service.auditar(e, _resultadoValido(secaoFase: 1.5, secaoNeutro: 1.5)),
        isEmpty,
      );
    });
  });

  // ── calcularSecaoNeutro ───────────────────────────────────────────────────

  group('calcularSecaoNeutro —', () {
    test('Monofásico → neutro = fase', () {
      final service = _criarService();
      final e = entradaPadrao();
      expect(service.calcularSecaoNeutro(2.5, e), equals(2.5));
    });

    test('Trifásico harm ≤ 15% fase ≤ 25mm² → neutro = fase', () {
      final service = _criarService();
      final e = entradaPadrao(
        numeroFases: NumeroFases.trifasico,
      );
      expect(service.calcularSecaoNeutro(16.0, e), equals(16.0));
    });

    test('Trifásico harm ≤ 15% fase 35mm² → neutro = 25mm² (Tab. 48)', () {
      final service = _criarService();
      final e = entradaPadrao(
        numeroFases: NumeroFases.trifasico,
      );
      expect(service.calcularSecaoNeutro(35.0, e), equals(25.0));
    });

    test('Trifásico harm > 15% fase 35mm² → neutro = 35mm² (sem redução)', () {
      final service = _criarService();
      final e = entradaPadrao(
        numeroFases: NumeroFases.trifasico,
        harmonicasAcima15pct: true,
      );
      expect(service.calcularSecaoNeutro(35.0, e), equals(35.0));
    });
  });

  // ── verificarConformidade — DISP_001 ─────────────────────────────────────

  group('verificarConformidade — DISP_001 —', () {
    test('Trifásico + dispositivoMultipolar=true → sem DISP_001', () {
      final service = _criarService();
      final e = entradaPadrao(
        numeroFases: NumeroFases.trifasico,
      );
      final violacoes = service.verificarConformidade(e);
      expect(violacoes.any((final v) => v.codigo == 'DISP_001'), isFalse);
    });

    test('Trifásico + dispositivoMultipolar=false → DISP_001', () {
      final service = _criarService();
      final e = entradaPadrao(
        numeroFases: NumeroFases.trifasico,
        dispositivoMultipolar: false,
      );
      final violacoes = service.verificarConformidade(e);
      expect(violacoes.any((final v) => v.codigo == 'DISP_001'), isTrue);
    });
  });
}
