// REV: 1.0.0
// CHANGELOG:
// [1.0.0] - 2026-05
// - ADD: S-12 — piso mínimo de pontos de iluminação por cômodo residencial.

import 'dart:math';

import '../../contracts/i_specification.dart';
import '../../domain/instalacao/escopo_projeto.dart';
import '../../domain/locais/tipo_comodo.dart';
import '../../models/violacao.dart';

/// Parâmetros de entrada para [SpecMinimoIL].
typedef EntradaMinimoIL = ({
  TipoComodo comodo,
  double areaM2,
  int numPontos,
});

/// S-12 — Piso mínimo de pontos de iluminação por cômodo residencial.
///
/// Fórmula: max(1, ceil(areaM2 / 4)) para todos os cômodos.
/// Viola IL_001 quando o número de pontos instalados é inferior ao mínimo.
///
/// Rastreabilidade: NBR 5410:2004 — 9.5.4.1.1.
final class SpecMinimoIL implements ISpecification<EntradaMinimoIL> {
  const SpecMinimoIL();

  @override
  bool aplicavelA(final PerfilInstalacao perfil) =>
      perfil.escopo == EscopoProjeto.residencial;

  @override
  List<Violacao> verificar(final EntradaMinimoIL entrada) {
    final minimo = max(1, (entrada.areaM2 / 4.0).ceil());
    if (entrada.numPontos >= minimo) return const [];
    return [
      Violacao.pontosIlInsuficientes(
        comodo: entrada.comodo.name,
        instalados: entrada.numPontos,
        minimo: minimo,
        areaM2: entrada.areaM2,
      ),
    ];
  }
}
