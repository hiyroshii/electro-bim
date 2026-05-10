// REV: 1.2.0
// CHANGELOG:
// [1.2.0] - 2026-05
// - ADD: SpecSobrecarga (S-3) em auditar() — SOBRE_001, SOBRE_002.
// [1.1.0] - 2026-05
// - ADD: SpecDispositivoMultipolar em verificarConformidade().
// [1.0.0] - 2026-04
// - ADD: sub-orquestrador de conformidade normativa.

import '../models/violacao.dart';
import '../models/entrada_normativa.dart';
import '../models/resultado_normativo.dart';
import '../specification/spec_aluminio.dart';
import '../specification/spec_combinacoes.dart';
import '../specification/spec_dispositivo_multipolar.dart';
import '../specification/spec_neutro.dart';
import '../specification/spec_queda_tensao.dart';
import '../specification/spec_secao_minima.dart';
import '../specification/spec_sobrecarga.dart';

/// Sub-orquestrador de conformidade normativa.
///
/// Agrupa as specs por momento de execução:
/// - Pré-cálculo: specs que dependem apenas da entrada.
/// - Auditoria: specs que dependem do resultado calculado.
///
/// Acumula todas as violações — nunca para na primeira.
/// Rastreabilidade: ARCHITECTURE.md — Seção 6.2.
final class SpecificationService {
  const SpecificationService({
    required this.origemAlimentacao,
    required this.contextoInstalacao,
  });

  final OrigemAlimentacao origemAlimentacao;
  final ContextoInstalacao contextoInstalacao;

  /// Verifica conformidade da entrada antes do cálculo.
  /// Specs: combinacoes + aluminio + dispositivo_multipolar.
  List<Violacao> verificarConformidade(final EntradaNormativa entrada) => [
        ...const SpecCombinacoes().verificar(entrada),
        ...SpecAluminio(contexto: contextoInstalacao).verificar(entrada),
        ...const SpecDispositivoMultipolar().verificar(entrada),
      ];

  /// Audita o resultado após o cálculo.
  /// Specs: sobrecarga + secao_minima + neutro + queda_tensao.
  List<Violacao> auditar(
    final EntradaNormativa entrada,
    final ResultadoNormativo resultado,
  ) => [
        ...SpecSobrecarga(
          ib: resultado.ib,
          inDisjuntor: resultado.inDisjuntor,
          izFinal: resultado.izFinal,
        ).verificar(entrada),
        ...SpecSecaoMinima(secaoCalculada: resultado.secaoFase).verificar(entrada),
        ...SpecNeutro(
          secaoNeutro: resultado.secaoNeutro,
          secaoFase: resultado.secaoFase,
        ).verificar(entrada),
        ...SpecQuedaTensao(
          quedaCalculadaPercent: resultado.quedaPercent,
          origemAlimentacao: origemAlimentacao,
        ).verificar(entrada),
      ];
}
