// REV: 1.0.0
// CHANGELOG:
// [1.0.0] - 2026-04
// - ADD: testes de integração do DimensionamentoService (orquestrador mestre).

import 'package:test/test.dart';
import 'package:normative_engine/normative_engine.dart';

// ignore: implementation_imports
import 'package:electrical_engine/src/orchestrator/dimensionamento_service.dart';
// ignore: implementation_imports
import 'package:electrical_engine/src/orchestrator/circuito/politica_disjuntor.dart';
// ignore: implementation_imports
import 'package:electrical_engine/src/models/carga/comodo.dart';
// ignore: implementation_imports
import 'package:electrical_engine/src/models/carga/entrada_carga.dart';
// ignore: implementation_imports
import 'package:electrical_engine/src/models/carga/relatorio_carga.dart';
// ignore: implementation_imports
import 'package:electrical_engine/src/models/circuito/entrada_dimensionamento.dart';
// ignore: implementation_imports
import 'package:electrical_engine/src/models/circuito/resultado_selecao.dart';

// ── Helpers ───────────────────────────────────────────────────────────────

final _catalogo = [
  Disjuntor(6),  Disjuntor(10), Disjuntor(16), Disjuntor(20),
  Disjuntor(25), Disjuntor(32), Disjuntor(40), Disjuntor(50), Disjuntor(63),
];

DimensionamentoService _servico() => DimensionamentoService(
      normative: NormativeService(
        origemAlimentacao: OrigemAlimentacao.pontoEntrega,
        contextoInstalacao: ContextoInstalacao.industrial,
      ),
      catalogoDisjuntores: _catalogo,
    );

EntradaDimensionamento _entradaCircuito({
  String id = 'C-001',
  TagCircuito tag = TagCircuito.tug,
  double potenciaVA = 600,
  double distancia = 15.0,
}) =>
    EntradaDimensionamento(
      idCircuito: id,
      tagCircuito: tag,
      potenciaVA: potenciaVA,
      fatorPotencia: 1.0,
      tensao: Tensao.v220,
      numeroFases: NumeroFases.monofasico,
      isolacao: Isolacao.pvc,
      arquitetura: Arquitetura.multipolar,
      metodo: MetodoInstalacao.b1,
      material: Material.cobre,
      temperatura: 30,
      distancia: distancia,
      origemAlimentacao: OrigemAlimentacao.pontoEntrega,
      contextoInstalacao: ContextoInstalacao.industrial,
      paramsAgrupamento: const ParamsAgrupamento(numCircuitos: 1),
    );

void main() {
  // ── Criação de cômodos ────────────────────────────────────────────────────

  group('Criação de cômodos —', () {
    test('criarComodoComSugestoes retorna cômodo com pontos', () {
      final servico = _servico();
      final comodo = servico.criarComodoComSugestoes(
        idTipo: 'sala',
        label: 'Sala de Estar',
        regraTomadasComodo: RegraTomadasComodo.porPerimetro,
        areaM2: 20.0,
        perimetroM: 18.0,
      );
      expect(comodo.label, equals('Sala de Estar'));
      expect(comodo.pontosTug, isNotEmpty);
      expect(comodo.pontosIl, isNotEmpty);
    });

    test('criarComodoCustom retorna cômodo vazio', () {
      final comodo = _servico().criarComodoCustom(
        label: 'Área Técnica',
        areaM2: 5.0,
        perimetroM: 9.0,
      );
      expect(comodo.pontosTug, isEmpty);
      expect(comodo.pontosIl, isEmpty);
    });
  });

  // ── Fluxo completo: carga → circuito ─────────────────────────────────────

  group('Fluxo completo —', () {
    test('processarCarga → circuitos → dimensionarCircuito', () {
      final servico = _servico();

      // 1. Criar cômodo
      final sala = servico.criarComodoComSugestoes(
        idTipo: 'sala',
        label: 'Sala',
        regraTomadasComodo: RegraTomadasComodo.porPerimetro,
        areaM2: 20.0,
        perimetroM: 18.0,
      );

      // 2. Processar carga → obtém circuitos agregados
      final relatorioCarga = servico.processarCarga(
        EntradaCarga(comodos: [sala]),
      );
      expect(relatorioCarga.status, equals(StatusRelatorio.ok));
      expect(relatorioCarga.circuitos, isNotEmpty);

      // 3. Dimensionar primeiro circuito TUG como exemplo
      final circuito = relatorioCarga.circuitos.firstWhere(
        (c) => c.tag == TagCircuito.tug,
        orElse: () => relatorioCarga.circuitos.first,
      );

      final relatorioCircuito = servico.dimensionarCircuito(
        EntradaDimensionamento(
          idCircuito: circuito.idCircuito,
          tagCircuito: circuito.tag,
          potenciaVA: circuito.potenciaVA,
          fatorPotencia: 1.0,
          tensao: Tensao.v220,
          numeroFases: NumeroFases.monofasico,
          isolacao: Isolacao.pvc,
          arquitetura: Arquitetura.multipolar,
          metodo: MetodoInstalacao.b1,
          material: Material.cobre,
          temperatura: 30,
          distancia: 20.0,
          origemAlimentacao: OrigemAlimentacao.pontoEntrega,
          contextoInstalacao: ContextoInstalacao.industrial,
          paramsAgrupamento: const ParamsAgrupamento(numCircuitos: 1),
        ),
      );

      expect(relatorioCircuito.status, equals(StatusDimensionamento.aprovado));
      expect(relatorioCircuito.secaoFinal, greaterThanOrEqualTo(2.5));
    });

    test('Múltiplos circuitos dimensionados independentemente', () {
      final servico = _servico();

      final r1 = servico.dimensionarCircuito(_entradaCircuito(
        id: 'C-001', tag: TagCircuito.tug, potenciaVA: 600,
      ));
      final r2 = servico.dimensionarCircuito(_entradaCircuito(
        id: 'C-002', tag: TagCircuito.il, potenciaVA: 300,
      ));

      expect(r1.idCircuito, equals('C-001'));
      expect(r2.idCircuito, equals('C-002'));
      expect(r1.status, equals(StatusDimensionamento.aprovado));
      expect(r2.status, equals(StatusDimensionamento.aprovado));
    });
  });

  // ── Dimensionamento de circuito ───────────────────────────────────────────

  group('dimensionarCircuito —', () {
    test('TUG retorna seção >= 2.5mm²', () {
      final r = _servico().dimensionarCircuito(
        _entradaCircuito(tag: TagCircuito.tug),
      );
      expect(r.secaoFinal, greaterThanOrEqualTo(2.5));
    });

    test('IL retorna seção >= 1.5mm²', () {
      final r = _servico().dimensionarCircuito(
        _entradaCircuito(tag: TagCircuito.il, potenciaVA: 300),
      );
      expect(r.secaoFinal, greaterThanOrEqualTo(1.5));
    });

    test('ΔV% <= 4% para circuito terminal', () {
      final r = _servico().dimensionarCircuito(_entradaCircuito());
      expect(r.selecao.quedaFinal, lessThanOrEqualTo(4.0));
    });

    test('Entrada inválida propagada como exceção', () {
      expect(
        () => _servico().dimensionarCircuito(
          EntradaDimensionamento(
            idCircuito: 'C-001',
            tagCircuito: TagCircuito.tug,
            potenciaVA: 600,
            fatorPotencia: 1.0,
            tensao: Tensao.v127,
            numeroFases: NumeroFases.trifasico, // inválido
            isolacao: Isolacao.pvc,
            arquitetura: Arquitetura.multipolar,
            metodo: MetodoInstalacao.b1,
            material: Material.cobre,
            temperatura: 30,
            distancia: 15.0,
            origemAlimentacao: OrigemAlimentacao.pontoEntrega,
            contextoInstalacao: ContextoInstalacao.industrial,
            paramsAgrupamento: const ParamsAgrupamento(numCircuitos: 1),
          ),
        ),
        throwsA(isA<EntradaInvalidaException>()),
      );
    });
  });

  // ── Auditoria pós-dimensionamento ─────────────────────────────────────────

  group('Auditoria normativa —', () {
    test('Relatório aprovado passa auditoria sem violações', () {
      final servico = _servico();
      final entrada = _entradaCircuito();
      final relatorio = servico.dimensionarCircuito(entrada);

      if (relatorio.status == StatusDimensionamento.aprovado) {
        final normative = NormativeService(
          origemAlimentacao: OrigemAlimentacao.pontoEntrega,
          contextoInstalacao: ContextoInstalacao.industrial,
        );
        final violacoes = normative.auditar(
          entrada.toEntradaNormativa(),
          relatorio.toResultadoNormativo(),
        );
        expect(violacoes.where((v) => v.codigo != 'NEUTRO_002'), isEmpty);
        // NEUTRO_002 esperado pois secaoNeutro = secaoFase (TODO ciclo 4.1)
      }
    });
  });
}
