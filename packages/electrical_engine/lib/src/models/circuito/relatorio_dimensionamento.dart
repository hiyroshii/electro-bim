// REV: 1.1.0
// CHANGELOG:
// [1.1.0] - 2026-05
// - ADD: secaoNeutro:double — substitui proxy secaoFase (ciclo 4.1).
// [1.0.1] - 2026-05
// - FIX: construtor movido para antes dos campos (sort_constructors_first).
// - FIX: import não usado de entrada_dimensionamento.dart removido.
// [1.0.0] - 2026-04
// - ADD: scaffold de RelatorioDimensionamento com campos teórico + final.

import 'package:normative_engine/normative_engine.dart';

import 'resultado_selecao.dart';

/// Resultado completo do dimensionamento de um circuito elétrico.
///
/// Parâmetros de projeto obrigatórios (NBR 5410:2004 — 6.1.8.1/f):
/// Ib, In, Iz, ΔV%, FCT, FCA, temperatura, método de instalação.
///
/// Enviado à UI após o cálculo — e ao [NormativeEngine.auditar]
/// para validação final de conformidade.
final class RelatorioDimensionamento {
  const RelatorioDimensionamento({
    required this.idCircuito,
    required this.tagCircuito,
    required this.material,
    required this.isolacao,
    required this.arquitetura,
    required this.metodoInstalacao,
    required this.ib,
    required this.inDisjuntor,
    required this.fatores,
    required this.selecao,
    required this.secaoNeutro,
    required this.limiteQuedaAplicado,
    required this.status,
  });

  // ── Identificação ────────────────────────────────────────────────────────
  final String idCircuito;
  final TagCircuito tagCircuito;

  // ── Especificação do cabo ────────────────────────────────────────────────
  final Material material;
  final Isolacao isolacao;
  final Arquitetura arquitetura;
  final MetodoInstalacao metodoInstalacao;

  // ── Correntes ────────────────────────────────────────────────────────────
  final double ib;
  final double inDisjuntor;

  // ── Fatores de correção ──────────────────────────────────────────────────
  final FatoresCorrecao fatores;

  // ── Resultado da seleção ─────────────────────────────────────────────────
  final ResultadoSelecao selecao;

  // ── Seção do neutro ──────────────────────────────────────────────────────
  /// Seção mínima do condutor neutro (mm²) conforme 6.2.6.2.
  final double secaoNeutro;

  // ── Limite de queda aplicado ─────────────────────────────────────────────
  final double limiteQuedaAplicado;

  final StatusDimensionamento status;

  /// Converte para [ResultadoNormativo] para auditoria pelo [NormativeEngine].
  ResultadoNormativo toResultadoNormativo() => ResultadoNormativo(
        ib: ib,
        inDisjuntor: inDisjuntor,
        izFinal: selecao.izFinal,
        secaoFase: selecao.secaoFinal,
        secaoNeutro: secaoNeutro,
        quedaPercent: selecao.quedaFinal,
      );

  /// Atalho: seção final selecionada.
  double get secaoFinal => selecao.secaoFinal;

  /// Atalho: Iz corrigida final.
  double get izFinal => selecao.izFinal;
}
