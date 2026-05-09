// REV: 1.1.0
// CHANGELOG:
// [1.1.0] - 2026-05
// - ADD: SpecDispositivoMultipolar em verificarConformidade().
// [1.0.0] - 2026-04
// - ADD: sub-orquestrador de conformidade normativa.

import '../models/violacao.dart';
import '../models/entrada_normativa.dart';
import '../models/resultado_normativo.dart';
import '../specification/spec_combinacoes.dart';
import '../specification/spec_aluminio.dart';
import '../specification/spec_dispositivo_multipolar.dart';
import '../specification/spec_secao_minima.dart';
import '../specification/spec_neutro.dart';
import '../specification/spec_queda_tensao.dart';

/// Sub-orquestrador de conformidade normativa.
///
/// Agrupa as specs por momento de execução:
/// - Pré-cálculo: specs que dependem apenas da entrada.
/// - Auditoria: specs que dependem do resultado calculado.
///
/// Acumula todas as violações — nunca para na primeira.
/// Rastreabilidade: ARCHITECTURE.md — Seção 6.2.
final class SpecificationService {
  final OrigemAlimentacao origemAlimentacao;
  final ContextoInstalacao contextoInstalacao;

  const SpecificationService({
    required this.origemAlimentacao,
    required this.contextoInstalacao,
  });

  /// Verifica conformidade da entrada antes do cálculo.
  /// Specs: combinacoes + aluminio.
  List<Violacao> verificarConformidade(EntradaNormativa entrada) {
    final violacoes = <Violacao>[];

    violacoes.addAll(const SpecCombinacoes().verificar(entrada));

    violacoes.addAll(SpecAluminio(
      contexto: contextoInstalacao,
    ).verificar(entrada));

    violacoes.addAll(const SpecDispositivoMultipolar().verificar(entrada));

    return violacoes;
  }

  /// Audita o resultado após o cálculo.
  /// Specs: secao_minima + neutro + queda_tensao.
  List<Violacao> auditar(
    EntradaNormativa entrada,
    ResultadoNormativo resultado,
  ) {
    final violacoes = <Violacao>[];

    violacoes.addAll(SpecSecaoMinima(
      secaoCalculada: resultado.secaoFase,
    ).verificar(entrada));

    violacoes.addAll(SpecNeutro(
      secaoNeutro: resultado.secaoNeutro,
      secaoFase: resultado.secaoFase,
    ).verificar(entrada));

    violacoes.addAll(SpecQuedaTensao(
      quedaCalculadaPercent: resultado.quedaPercent,
      origemAlimentacao: origemAlimentacao,
    ).verificar(entrada));

    return violacoes;
  }
}
