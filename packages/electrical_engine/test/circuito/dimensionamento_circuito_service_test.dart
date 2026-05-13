// REV: 1.1.0
// CHANGELOG:
// [1.1.0] - 2026-05
// - ADD: verificação de secaoNeutro e DISP_001 no serviço de dimensionamento.
// [1.0.0] - 2026-04
// - ADD: testes de integração do DimensionamentoCircuitoService.

import 'package:test/test.dart';
import 'package:normative_engine/normative_engine.dart';

// ignore: implementation_imports
import 'package:electrical_engine/src/orchestrator/circuito/dimensionamento_circuito_service.dart';
// ignore: implementation_imports
import 'package:electrical_engine/src/orchestrator/circuito/politica_disjuntor.dart';
// ignore: implementation_imports
import 'package:electrical_engine/src/models/circuito/entrada_dimensionamento.dart';
// ignore: implementation_imports
import 'package:electrical_engine/src/models/circuito/resultado_selecao.dart';

// ── Helpers ───────────────────────────────────────────────────────────────

final _catalogo = [
  Disjuntor(6),  Disjuntor(10), Disjuntor(16), Disjuntor(20),
  Disjuntor(25), Disjuntor(32), Disjuntor(40), Disjuntor(50), Disjuntor(63),
];

NormativeService _normative({
  OrigemAlimentacao origem = OrigemAlimentacao.pontoEntrega,
}) =>
    NormativeService(
      origemAlimentacao: origem,
      perfil: const PerfilInstalacao(escopo: EscopoProjeto.industrial),
    );

DimensionamentoCircuitoService _servico({
  OrigemAlimentacao origem = OrigemAlimentacao.pontoEntrega,
}) =>
    DimensionamentoCircuitoService(
      normative: _normative(origem: origem),
      catalogoDisjuntores: _catalogo,
    );

EntradaDimensionamento _entradaTug({
  String idCircuito = 'C-001',
  double potenciaVA = 600,
  double fatorPotencia = 1.0,
  double distancia = 15.0,
  int temperatura = 30,
}) =>
    EntradaDimensionamento(
      idCircuito: idCircuito,
      tagCircuito: TagCircuito.tug,
      potenciaVA: potenciaVA,
      fatorPotencia: fatorPotencia,
      tensao: Tensao.v220,
      numeroFases: NumeroFases.monofasico,
      isolacao: Isolacao.pvc,
      arquitetura: Arquitetura.multipolar,
      metodo: MetodoInstalacao.b1,
      material: Material.cobre,
      temperatura: temperatura,
      distancia: distancia,
      origemAlimentacao: OrigemAlimentacao.pontoEntrega,
      paramsAgrupamento: const ParamsAgrupamento(numCircuitos: 1),
    );

void main() {
  // ── Fluxo aprovado ────────────────────────────────────────────────────────

  group('Fluxo aprovado —', () {
    test('TUG padrão retorna relatório aprovado', () {
      final r = _servico().processar(_entradaTug());
      expect(r.status, equals(StatusDimensionamento.aprovado));
    });

    test('Seção final >= 2,5mm² para TUG (Tabela 47)', () {
      final r = _servico().processar(_entradaTug());
      expect(r.secaoFinal, greaterThanOrEqualTo(2.5));
    });

    test('Ib calculado está no relatório', () {
      // Ib = 600 / (220 × 1.0) = 2,727A
      final r = _servico().processar(_entradaTug(potenciaVA: 600));
      expect(r.ib, closeTo(600 / 220, 0.01));
    });

    test('In >= Ib no relatório', () {
      final r = _servico().processar(_entradaTug());
      expect(r.inDisjuntor, greaterThanOrEqualTo(r.ib));
    });

    test('Iz final >= In no relatório', () {
      final r = _servico().processar(_entradaTug());
      expect(r.izFinal, greaterThanOrEqualTo(r.inDisjuntor));
    });

    test('ΔV% final <= 4% (limite TUG)', () {
      final r = _servico().processar(_entradaTug());
      expect(r.selecao.quedaFinal, lessThanOrEqualTo(4.0));
    });

    test('Circuito longo força seção maior por queda', () {
      final rCurto = _servico().processar(_entradaTug(distancia: 10.0));
      final rLongo = _servico().processar(_entradaTug(distancia: 60.0));
      expect(rLongo.secaoFinal, greaterThanOrEqualTo(rCurto.secaoFinal));
    });

    test('FCT a 40°C reduz Iz — pode aumentar seção', () {
      final r30 = _servico().processar(_entradaTug(temperatura: 30));
      final r40 = _servico().processar(_entradaTug(temperatura: 40));
      // FCT(40°C, PVC) = 0,87 — Iz reduzida
      expect(r40.fatores.fct, closeTo(0.87, 0.01));
    });

    test('Campos teórico e final preenchidos no relatório', () {
      final r = _servico().processar(_entradaTug());
      expect(r.selecao.secaoTeorica, greaterThan(0));
      expect(r.selecao.secaoFinal, greaterThan(0));
      expect(r.selecao.izTeorico, greaterThan(0));
      expect(r.selecao.izFinal, greaterThan(0));
    });

    test('IL retorna seção >= 1,5mm²', () {
      final entrada = EntradaDimensionamento(
        idCircuito: 'C-002',
        tagCircuito: TagCircuito.il,
        potenciaVA: 300,
        fatorPotencia: 1.0,
        tensao: Tensao.v220,
        numeroFases: NumeroFases.monofasico,
        isolacao: Isolacao.pvc,
        arquitetura: Arquitetura.multipolar,
        metodo: MetodoInstalacao.b1,
        material: Material.cobre,
        temperatura: 30,
        distancia: 10.0,
        origemAlimentacao: OrigemAlimentacao.pontoEntrega,
          paramsAgrupamento: const ParamsAgrupamento(numCircuitos: 1),
      );
      final r = _servico().processar(entrada);
      expect(r.status, equals(StatusDimensionamento.aprovado));
      expect(r.secaoFinal, greaterThanOrEqualTo(1.5));
    });
  });

  // ── Entrada inválida ──────────────────────────────────────────────────────

  group('Entrada inválida —', () {
    test('XLPE + ISOLADO lança EntradaInvalidaException', () {
      final entrada = EntradaDimensionamento(
        idCircuito: 'C-003',
        tagCircuito: TagCircuito.tug,
        potenciaVA: 600,
        fatorPotencia: 1.0,
        tensao: Tensao.v220,
        numeroFases: NumeroFases.monofasico,
        isolacao: Isolacao.xlpe,
        arquitetura: Arquitetura.isolado, // inválido com XLPE
        metodo: MetodoInstalacao.b1,
        material: Material.cobre,
        temperatura: 30,
        distancia: 15.0,
        origemAlimentacao: OrigemAlimentacao.pontoEntrega,
          paramsAgrupamento: const ParamsAgrupamento(numCircuitos: 1),
      );
      expect(
        () => _servico().processar(entrada),
        throwsA(isA<EntradaInvalidaException>()),
      );
    });

    test('V127 trifásico lança EntradaInvalidaException', () {
      final entrada = EntradaDimensionamento(
        idCircuito: 'C-004',
        tagCircuito: TagCircuito.tug,
        potenciaVA: 600,
        fatorPotencia: 1.0,
        tensao: Tensao.v127,
        numeroFases: NumeroFases.trifasico, // inválido com V127
        isolacao: Isolacao.pvc,
        arquitetura: Arquitetura.multipolar,
        metodo: MetodoInstalacao.b1,
        material: Material.cobre,
        temperatura: 30,
        distancia: 15.0,
        origemAlimentacao: OrigemAlimentacao.pontoEntrega,
          paramsAgrupamento: const ParamsAgrupamento(numCircuitos: 1),
      );
      expect(
        () => _servico().processar(entrada),
        throwsA(isA<EntradaInvalidaException>()),
      );
    });

    test('Violações acumuladas no exception', () {
      final entrada = EntradaDimensionamento(
        idCircuito: 'C-005',
        tagCircuito: TagCircuito.tug,
        potenciaVA: 600,
        fatorPotencia: 1.0,
        tensao: Tensao.v127,
        numeroFases: NumeroFases.trifasico, // COMB_006
        isolacao: Isolacao.xlpe,
        arquitetura: Arquitetura.isolado,   // COMB_001
        metodo: MetodoInstalacao.b1,
        material: Material.cobre,
        temperatura: 30,
        distancia: 15.0,
        origemAlimentacao: OrigemAlimentacao.pontoEntrega,
          paramsAgrupamento: const ParamsAgrupamento(numCircuitos: 1),
      );
      try {
        _servico().processar(entrada);
        fail('Deveria lançar EntradaInvalidaException');
      } on EntradaInvalidaException catch (e) {
        expect(e.violacoes.length, greaterThanOrEqualTo(2));
      }
    });
  });

  // ── Reprovações ───────────────────────────────────────────────────────────

  group('Reprovações —', () {
    test('Ib > maior disjuntor do catálogo → REPROVADO_DISJUNTOR', () {
      // Potência altíssima garante Ib > 63A (maior do catálogo de teste)
      final r = _servico().processar(_entradaTug(potenciaVA: 50000));
      expect(r.status, equals(StatusDimensionamento.reprovadoDisjuntor));
      expect(r.inDisjuntor, equals(0));
    });

    test('REPROVADO_DISJUNTOR — Ib no relatório mesmo sem disjuntor', () {
      final r = _servico().processar(_entradaTug(potenciaVA: 50000));
      expect(r.ib, greaterThan(0));
    });
  });

  // ── Auditoria normativa ───────────────────────────────────────────────────

  group('Auditoria —', () {
    test('Relatório aprovado passa na auditoria sem violações', () {
      final servico = _servico();
      final entrada = _entradaTug();
      final r = servico.processar(entrada);

      if (r.status == StatusDimensionamento.aprovado) {
        final normative = _normative();
        final violacoes = normative.auditar(
          entrada.toEntradaNormativa(),
          r.toResultadoNormativo(),
        );
        expect(violacoes, isEmpty);
      }
    });
  });

  // ── secaoNeutro no relatório ──────────────────────────────────────────────

  group('secaoNeutro —', () {
    test('Monofásico TUG — secaoNeutro = secaoFase', () {
      final r = _servico().processar(_entradaTug());
      expect(r.secaoNeutro, equals(r.secaoFinal));
    });

    test('Trifásico TUG — secaoNeutro >= 2,5mm²', () {
      final entrada = EntradaDimensionamento(
        idCircuito: 'C-TRI-001',
        tagCircuito: TagCircuito.tug,
        potenciaVA: 3000,
        fatorPotencia: 0.92,
        tensao: Tensao.v220,
        numeroFases: NumeroFases.trifasico,
        isolacao: Isolacao.pvc,
        arquitetura: Arquitetura.multipolar,
        metodo: MetodoInstalacao.b1,
        material: Material.cobre,
        temperatura: 30,
        distancia: 20.0,
        origemAlimentacao: OrigemAlimentacao.pontoEntrega,
          paramsAgrupamento: const ParamsAgrupamento(numCircuitos: 1),
      );
      final r = _servico().processar(entrada);
      if (r.status == StatusDimensionamento.aprovado) {
        expect(r.secaoNeutro, greaterThanOrEqualTo(2.5));
      }
    });

    test('toResultadoNormativo usa secaoNeutro calculado', () {
      final r = _servico().processar(_entradaTug());
      final resultado = r.toResultadoNormativo();
      expect(resultado.secaoNeutro, equals(r.secaoNeutro));
    });
  });

  // ── dispositivoMultipolar ─────────────────────────────────────────────────

  group('dispositivoMultipolar —', () {
    test('Trifásico + dispositivoMultipolar=false → EntradaInvalidaException', () {
      final entrada = EntradaDimensionamento(
        idCircuito: 'C-DISP-001',
        tagCircuito: TagCircuito.tug,
        potenciaVA: 3000,
        fatorPotencia: 0.92,
        tensao: Tensao.v220,
        numeroFases: NumeroFases.trifasico,
        isolacao: Isolacao.pvc,
        arquitetura: Arquitetura.multipolar,
        metodo: MetodoInstalacao.b1,
        material: Material.cobre,
        temperatura: 30,
        distancia: 20.0,
        origemAlimentacao: OrigemAlimentacao.pontoEntrega,
          paramsAgrupamento: const ParamsAgrupamento(numCircuitos: 1),
        dispositivoMultipolar: false,
      );
      expect(
        () => _servico().processar(entrada),
        throwsA(isA<EntradaInvalidaException>()),
      );
    });
  });
}
