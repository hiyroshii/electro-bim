// REV: 1.0.2
// CHANGELOG:
// [1.0.2] - 2026-04
// - CHG: _resolverLimite restaurado — entrega 1%, próprio 3%. Terminal fixo 4%.
// [1.0.1] - 2026-04
// - CHG: incorretamente simplificado para 1% fixo (revertido).
// [1.0.0] - 2026-04
// - ADD: resolução de parâmetros normativos de queda de tensão (6.2.5.6, 6.2.7).

import '../../contracts/i_procedure.dart';
import '../../domain/instalacao/tag_circuito.dart';
import '../../domain/instalacao/numero_fases.dart';
import '../../models/entrada_normativa.dart';
import '../../models/parametros_queda.dart';
import '../../specification/instalacao/spec_queda_tensao.dart';

/// Resolve parâmetros normativos para o cálculo de queda de tensão.
///
/// Rastreabilidade: NBR 5410:2004 — 6.2.5.6, 6.2.7.1 e 6.2.7.2.
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

  double _resolverLimite(final TagCircuito tag, final OrigemAlimentacao origem) {
    if (tag.isTerminal) return TagCircuito.limiteQuedaTerminal;

    return switch (origem) {
      OrigemAlimentacao.pontoEntrega => TagCircuito.limiteQuedaAlimentadorEntrega,
      OrigemAlimentacao.trafoProprio => TagCircuito.limiteQuedaAlimentadorProprio,
    };
  }

  int _resolverCondutores(final EntradaNormativa e) =>
      e.numeroFases.condutoresCarregadosComNeutro(
        harmonicasAcima15: e.harmonicasAcima15pct,
      );

  double _resolverFatorHarmonico(final EntradaNormativa e) {
    final quatroCondutores =
        e.numeroFases == NumeroFases.trifasico && e.harmonicasAcima15pct;
    return quatroCondutores ? NumeroFases.fatorQuatroCondutores : 1.0;
  }
}
