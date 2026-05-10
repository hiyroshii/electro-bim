// REV: 1.0.3
// CHANGELOG:
// [1.0.3] - 2026-04
// - CHG: _resolverLimite restaurado com distinção de origem — alimentador entrega 1%,
//        alimentador próprio 3%. Terminal fixo em 4%.
// [1.0.2] - 2026-04
// - CHG: incorretamente simplificado para 1% fixo (revertido).
// [1.0.1] - 2026-04
// - CHG: OrigemAlimentacao movido para src/enums/origem_alimentacao.dart.
// [1.0.0] - 2026-04
// - ADD: verificação de limites de queda de tensão (6.2.7).

import '../../contracts/i_specification.dart';
import '../../enums/tag_circuito.dart';
import '../../enums/origem_alimentacao.dart';
import '../../models/violacao.dart';
import '../../models/entrada_normativa.dart';

export '../../enums/origem_alimentacao.dart';

/// Verifica se a queda de tensão calculada respeita o limite normativo.
///
/// Limites (NBR 5410:2004 — 6.2.7):
/// - Circuitos terminais (TUG, TUE, IL): 4% — fixo, independente da origem.
/// - Alimentadores (MED, QDG, QD) via concessionária: 1% (total 5%).
/// - Alimentadores (MED, QDG, QD) via trafo/gerador próprio: 3% (total 7%).
///
/// Rastreabilidade: NBR 5410:2004 — 6.2.7.1 e 6.2.7.2.
final class SpecQuedaTensao implements ISpecification<EntradaNormativa> {

  const SpecQuedaTensao({
    required this.quedaCalculadaPercent,
    required this.origemAlimentacao,
  });
  final double quedaCalculadaPercent;
  final OrigemAlimentacao origemAlimentacao;

  @override
  bool aplicavelA(final PerfilInstalacao perfil) => true;

  @override
  List<Violacao> verificar(final EntradaNormativa entrada) {
    final limite = _resolverLimite(entrada.tagCircuito);

    if (quedaCalculadaPercent > limite) {
      return [
        Violacao.quedaTensaoExcedida(
          quedaCalculada: quedaCalculadaPercent,
          limite: limite,
          tag: entrada.tagCircuito.name.toUpperCase(),
        ),
      ];
    }

    return [];
  }

  double _resolverLimite(final TagCircuito tag) {
    if (tag.isTerminal) return TagCircuito.limiteQuedaTerminal;

    return switch (origemAlimentacao) {
      OrigemAlimentacao.pontoEntrega => TagCircuito.limiteQuedaAlimentadorEntrega,
      OrigemAlimentacao.trafoProprio => TagCircuito.limiteQuedaAlimentadorProprio,
    };
  }
}
