// REV: 1.0.2
// CHANGELOG:
// [1.0.2] - 2026-04
// - CHG: _resolverLimite restaurado — entrega 1%, próprio 3%. Terminal fixo 4%.
// [1.0.1] - 2026-04
// - CHG: incorretamente simplificado para 1% fixo (revertido).
// [1.0.0] - 2026-04
// - ADD: resolução de parâmetros normativos de queda de tensão (6.2.5.6, 6.2.7).

import '../contracts/i_procedure.dart';
import '../enums/tag_circuito.dart';
import '../enums/numero_fases.dart';
import '../models/entrada_normativa.dart';
import '../models/parametros_queda.dart';
import '../specification/spec_queda_tensao.dart';

/// Resolve parâmetros normativos para o cálculo de queda de tensão.
///
/// Rastreabilidade: NBR 5410:2004 — 6.2.5.6 (condutores carregados),
/// 6.2.7.1 e 6.2.7.2 (limites de queda).
final class ProcQuedaTensao
    implements IProcedure<(EntradaNormativa, OrigemAlimentacao), ParametrosQueda> {
  const ProcQuedaTensao();

  @override
  ParametrosQueda resolver(
      final (EntradaNormativa, OrigemAlimentacao) entrada,) {
    final (e, origem) = entrada;

    final limite = _resolverLimite(e.tagCircuito, origem);
    final condutores = _resolverCondutores(e);
    final fatorHarmonico = _resolverFatorHarmonico(e);

    return ParametrosQueda(
      limitePercent: limite,
      condutoresCarregados: condutores,
      fatorHarmonico: fatorHarmonico,
    );
  }

  // ── Limite de queda de tensão ─────────────────────────────────────────────

  double _resolverLimite(final TagCircuito tag, final OrigemAlimentacao origem) {
    if (tag.isTerminal) return TagCircuito.limiteQuedaTerminal;

    return switch (origem) {
      OrigemAlimentacao.pontoEntrega => TagCircuito.limiteQuedaAlimentadorEntrega,
      OrigemAlimentacao.trafoProprio => TagCircuito.limiteQuedaAlimentadorProprio,
    };
  }

  // ── Número de condutores carregados ──────────────────────────────────────

  int _resolverCondutores(final EntradaNormativa e) =>
      e.numeroFases.condutoresCarregadosComNeutro(
        harmonicasAcima15: e.harmonicasAcima15pct,
      );

  // ── Fator harmônico ───────────────────────────────────────────────────────

  /// Retorna 0,86 quando há 4 condutores carregados (trifásico + harm > 15%).
  /// Retorna 1,0 nos demais casos.
  /// Rastreabilidade: NBR 5410:2004 — 6.2.5.6.1.
  double _resolverFatorHarmonico(final EntradaNormativa e) {
    final quatroCondutores =
        e.numeroFases == NumeroFases.trifasico && e.harmonicasAcima15pct;

    return quatroCondutores
        ? NumeroFases.fatorQuatroCondutores
        : 1.0;
  }
}
