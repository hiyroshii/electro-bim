// REV: 2.0.0
// CHANGELOG:
// [2.0.0] - 2026-05
// - CHG: ContextoInstalacao → PerfilInstalacao (Fase 2); ADD: smoke test de PerfilInstalacao.
// [1.0.0] - 2026-05
// - REF: substitui scaffold gerado (flutter_test + Calculator) por smoke tests.

import 'package:test/test.dart';
import 'package:normative_engine/normative_engine.dart';

// ignore: implementation_imports
import 'package:normative_engine/src/orchestrator/normative_service.dart';

void main() {
  group('Barrel — exports públicos —', () {
    test('NormativeService implementa NormativeEngine', () {
      final NormativeEngine service = NormativeService(
        origemAlimentacao: OrigemAlimentacao.pontoEntrega,
        perfil: PerfilInstalacao.residencial,
      );
      expect(service, isA<NormativeEngine>());
    });

    test('Enums exportados estão acessíveis', () {
      expect(Isolacao.values, isNotEmpty);
      expect(Arquitetura.values, isNotEmpty);
      expect(MetodoInstalacao.values, isNotEmpty);
      expect(Material.values, isNotEmpty);
      expect(TagCircuito.values, isNotEmpty);
      expect(NumeroFases.values, isNotEmpty);
      expect(OrigemAlimentacao.values, isNotEmpty);
      expect(EscopoProjeto.values, isNotEmpty);
    });

    test('PerfilInstalacao exportado e instanciável', () {
      const perfil = PerfilInstalacao(
        escopo: EscopoProjeto.residencial,
        influencias: {CodigoInfluencia.bd4},
      );
      expect(perfil.possuiInfluencia(CodigoInfluencia.bd4), isTrue);
      expect(perfil.possuiInfluencia(CodigoInfluencia.bd1), isFalse);
    });

    test('ResultadoNormativo pode ser instanciado com todos os campos', () {
      const resultado = ResultadoNormativo(
        ib: 10.0,
        inDisjuntor: 16.0,
        izFinal: 24.0,
        secaoFase: 2.5,
        secaoNeutro: 2.5,
        quedaPercent: 3.0,
      );
      expect(resultado.ib, equals(10.0));
      expect(resultado.inDisjuntor, equals(16.0));
      expect(resultado.izFinal, equals(24.0));
    });
  });
}
