// REV: 2.0.0
// CHANGELOG:
// [2.0.0] - 2026-05
// - CHG: imports atualizados para nova estrutura de subpastas (Fase 2).
// - ADD: filtrarPorPerfil() — aplica ISpecification.aplicavelA antes de verificar.
// [1.2.0] - 2026-05
// - ADD: SpecSobrecarga (S-3) em auditar() — SOBRE_001, SOBRE_002.
// [1.1.0] - 2026-05
// - ADD: SpecDispositivoMultipolar em verificarConformidade().
// [1.0.0] - 2026-04
// - ADD: sub-orquestrador de conformidade normativa.

import '../models/violacao.dart';
import '../models/entrada_normativa.dart';
import '../models/resultado_normativo.dart';
import '../domain/instalacao/perfil_instalacao.dart';
import '../specification/condutor/spec_aluminio.dart';
import '../specification/condutor/spec_combinacoes.dart';
import '../specification/condutor/spec_neutro.dart';
import '../specification/condutor/spec_secao_minima.dart';
import '../specification/instalacao/spec_queda_tensao.dart';
import '../specification/protecao/spec_dispositivo_multipolar.dart';
import '../specification/protecao/spec_sobrecarga.dart';

/// Sub-orquestrador de conformidade normativa.
///
/// Agrupa as specs por momento de execução:
/// - Pré-cálculo: specs que dependem apenas da entrada.
/// - Auditoria: specs que dependem do resultado calculado.
///
/// Aplica [ISpecification.aplicavelA] para filtrar specs fora do perfil.
/// Acumula todas as violações — nunca para na primeira.
/// Rastreabilidade: ARCHITECTURE.md — Seção 4.
final class SpecificationService {
  const SpecificationService({
    required this.origemAlimentacao,
    required this.perfil,
  });

  final OrigemAlimentacao origemAlimentacao;
  final PerfilInstalacao perfil;

  /// Verifica conformidade da entrada antes do cálculo.
  /// Specs: combinacoes + aluminio + dispositivo_multipolar.
  List<Violacao> verificarConformidade(final EntradaNormativa entrada) => [
        if (const SpecCombinacoes().aplicavelA(perfil))
          ...const SpecCombinacoes().verificar(entrada),
        if (SpecAluminio(perfil: perfil).aplicavelA(perfil))
          ...SpecAluminio(perfil: perfil).verificar(entrada),
        if (const SpecDispositivoMultipolar().aplicavelA(perfil))
          ...const SpecDispositivoMultipolar().verificar(entrada),
      ];

  /// Audita o resultado após o cálculo.
  /// Specs: sobrecarga + secao_minima + neutro + queda_tensao.
  List<Violacao> auditar(
    final EntradaNormativa entrada,
    final ResultadoNormativo resultado,
  ) => [
        if (SpecSobrecarga(
          ib: resultado.ib,
          inDisjuntor: resultado.inDisjuntor,
          izFinal: resultado.izFinal,
        ).aplicavelA(perfil))
          ...SpecSobrecarga(
            ib: resultado.ib,
            inDisjuntor: resultado.inDisjuntor,
            izFinal: resultado.izFinal,
          ).verificar(entrada),
        if (SpecSecaoMinima(secaoCalculada: resultado.secaoFase).aplicavelA(perfil))
          ...SpecSecaoMinima(secaoCalculada: resultado.secaoFase).verificar(entrada),
        if (SpecNeutro(
          secaoNeutro: resultado.secaoNeutro,
          secaoFase: resultado.secaoFase,
        ).aplicavelA(perfil))
          ...SpecNeutro(
            secaoNeutro: resultado.secaoNeutro,
            secaoFase: resultado.secaoFase,
          ).verificar(entrada),
        if (SpecQuedaTensao(
          quedaCalculadaPercent: resultado.quedaPercent,
          origemAlimentacao: origemAlimentacao,
        ).aplicavelA(perfil))
          ...SpecQuedaTensao(
            quedaCalculadaPercent: resultado.quedaPercent,
            origemAlimentacao: origemAlimentacao,
          ).verificar(entrada),
      ];
}
