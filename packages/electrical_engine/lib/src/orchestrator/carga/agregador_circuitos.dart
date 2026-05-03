// REV: 1.0.1
// CHANGELOG:
// [1.0.1] - 2026-04
// - ADD: implementação completa de agregar().
// [1.0.0] - 2026-04
// - ADD: scaffold de AgregadorCircuitos.

import 'package:normative_engine/normative_engine.dart';

import '../../models/carga/comodo.dart';
import '../../models/carga/entrada_carga.dart';

/// Limites normativos por tipo de circuito.
/// Rastreabilidade: NBR 5410:2004 — 9.1.2.2.
const double _maxVaTug = 1500.0; // potência máxima por circuito TUG
const double _maxVaIl  = 600.0;  // potência máxima por circuito IL

/// Agrega os pontos de utilização de todos os cômodos em circuitos.
///
/// Pontos com o mesmo [idCircuito] são agrupados e somados.
/// Verifica limites normativos por circuito.
///
/// Rastreabilidade: NBR 5410:2004 — 9.1.2.2.
final class AgregadorCircuitos {
  const AgregadorCircuitos();

  /// Agrega os pontos de todos os cômodos em circuitos.
  List<CircuitoAgregado> agregar(List<Comodo> comodos) {
    // Agrupamento: idCircuito → {tag, potenciaAcumulada}
    final Map<String, ({TagCircuito tag, double va})> mapa = {};

    for (final comodo in comodos) {
      for (final ponto in [...comodo.pontosTug, ...comodo.pontosIl]) {
        final atual = mapa[ponto.idCircuito];
        mapa[ponto.idCircuito] = (
          tag: ponto.tag,
          va: (atual?.va ?? 0.0) + ponto.potenciaVA,
        );
      }
    }

    return mapa.entries.map((e) {
      final tag = e.value.tag;
      final va  = e.value.va;
      final limite = tag == TagCircuito.il ? _maxVaIl : _maxVaTug;

      return CircuitoAgregado(
        idCircuito: e.key,
        tag: tag,
        potenciaVA: va,
        status: va <= limite
            ? StatusCircuito.aprovado
            : StatusCircuito.reprovado,
      );
    }).toList();
  }
}
