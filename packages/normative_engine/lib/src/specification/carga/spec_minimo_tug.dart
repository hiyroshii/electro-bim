// REV: 1.0.0
// CHANGELOG:
// [1.0.0] - 2026-05
// - ADD: S-13 — piso mínimo de TUGs por cômodo residencial (9.5.4.1.2).

import 'dart:math';

import '../../contracts/i_specification.dart';
import '../../domain/instalacao/escopo_projeto.dart';
import '../../domain/locais/tipo_comodo.dart';
import '../../models/violacao.dart';

/// Parâmetros de entrada para [SpecMinimoTUG].
typedef EntradaMinimoTUG = ({
  TipoComodo comodo,
  double areaM2,
  int numTomadas,
});

/// S-13 — Piso mínimo de tomadas de uso geral (TUG) por cômodo residencial.
///
/// Retorna `null` para corredores com área < 1,5 m² — sem mínimo normativo.
/// Viola TUG_001 quando o número instalado é inferior ao mínimo.
///
/// Rastreabilidade: NBR 5410:2004 — 9.5.4.1.2.
final class SpecMinimoTUG implements ISpecification<EntradaMinimoTUG> {
  const SpecMinimoTUG();

  @override
  bool aplicavelA(final PerfilInstalacao perfil) =>
      perfil.escopo == EscopoProjeto.residencial;

  @override
  List<Violacao> verificar(final EntradaMinimoTUG entrada) {
    final minimo = _minimo(entrada.comodo, entrada.areaM2);
    if (minimo == null || entrada.numTomadas >= minimo) return const [];
    return [
      Violacao.tomadasInsuficientes(
        comodo: entrada.comodo.name,
        instaladas: entrada.numTomadas,
        minimo: minimo,
        areaM2: entrada.areaM2,
      ),
    ];
  }

  int? _minimo(final TipoComodo comodo, final double area) =>
      switch (comodo) {
        TipoComodo.sala =>
            area >= 6.0 ? max(3, (area / 5.0).ceil()) : 1,
        TipoComodo.quarto => max(2, (area / 5.0).ceil()),
        TipoComodo.cozinha => max(2, (area / 3.5).ceil()),
        TipoComodo.banheiro => 1,
        TipoComodo.areaServico => max(2, (area / 3.5).ceil()),
        TipoComodo.corredor => area >= 1.5 ? 1 : null,
        TipoComodo.garagem => 1,
        TipoComodo.varanda => 1,
      };
}
