// REV: 1.0.0
// CHANGELOG:
// [1.0.0] - 2026-05
// - ADD: verificação de sobrecarga IB ≤ In ≤ Iz (SOBRE_001, SOBRE_002).

import '../../contracts/i_specification.dart';
import '../../models/entrada_normativa.dart';
import '../../models/violacao.dart';

/// **NBR 5410:2004 — 5.3.4.1**
///
/// Manual: S-3
/// Sobrecarga: verifica IB ≤ In ≤ Iz.
final class SpecSobrecarga implements ISpecification<EntradaNormativa> {
  const SpecSobrecarga({
    required this.ib,
    required this.inDisjuntor,
    required this.izFinal,
  });

  final double ib;
  final double inDisjuntor;
  final double izFinal;

  @override
  bool aplicavelA(final PerfilInstalacao perfil) => true;

  @override
  List<Violacao> verificar(final EntradaNormativa entrada) {
    final violacoes = <Violacao>[];

    // V1: IB ≤ In — disjuntor deve suportar a corrente de projeto.
    if (ib > inDisjuntor) {
      violacoes.add(
        Violacao.disjuntorSubdimensionado(ib: ib, inDisjuntor: inDisjuntor),
      );
    }

    // V2: In ≤ Iz — condutor deve suportar a corrente nominal do disjuntor.
    // V3 (I2 ≤ 1,45 × Iz) é automaticamente satisfeita quando V2 vale
    // para dispositivos convencionais (Nota de 5.3.4.1).
    if (inDisjuntor > izFinal) {
      violacoes.add(
        Violacao.disjuntorSuperdimensionado(
          inDisjuntor: inDisjuntor,
          izFinal: izFinal,
        ),
      );
    }

    return violacoes;
  }
}
