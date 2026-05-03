// REV: 1.0.2
// CHANGELOG:
// [1.0.2] - 2026-05
// - FIX: construtor de ResultadoAmpacidade movido antes dos campos.
// [1.0.1] - 2026-04
// - ADD: implementação completa de calcular().
// [1.0.0] - 2026-04
// - ADD: scaffold de CalcAmpacidadeCabo.

import 'package:normative_engine/normative_engine.dart';

/// Resultado do cálculo de ampacidade para uma seção.
final class ResultadoAmpacidade {
  const ResultadoAmpacidade({
    required this.secao,
    required this.ampacidadeBase,
    required this.izCabo,
  });

  final double secao;

  /// Corrente base da tabela normativa (A) — sem fatores.
  final double ampacidadeBase;

  /// Corrente corrigida: base × FCT × FCA × fatorHarmonico (A).
  final double izCabo;
}

/// Calcula a ampacidade corrigida do cabo (Iz).
///
/// Iz = Iz_base × FCT × FCA × fatorHarmonico
///
/// Matemática pura — sem conhecimento de norma.
/// Rastreabilidade: NBR 5410:2004 — 6.2.5.2.1, 6.2.5.6.1.
abstract final class CalcAmpacidadeCabo {
  /// Calcula Iz corrigida para uma linha da tabela.
  ///
  /// [linha]          — seção e Iz base da tabela normativa.
  /// [fatores]        — FCT × FCA do [NormativeEngine].
  /// [fatorHarmonico] — 0,86 se 4 condutores carregados, 1,0 caso contrário.
  static ResultadoAmpacidade calcular({
    required LinhaAmpacidade linha,
    required FatoresCorrecao fatores,
    required double fatorHarmonico,
  }) {
    final izCabo = linha.izBase * fatores.fct * fatores.fca * fatorHarmonico;
    return ResultadoAmpacidade(
      secao: linha.secao,
      ampacidadeBase: linha.izBase,
      izCabo: izCabo,
    );
  }
}
