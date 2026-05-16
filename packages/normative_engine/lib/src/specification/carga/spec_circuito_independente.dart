// REV: 1.0.0
// CHANGELOG:
// [1.0.0] - 2026-05
// - ADD: S-9 — circuito exclusivo para TUEs com Ib > 10 A (9.5.3.1).

import '../../contracts/i_specification.dart';
import '../../domain/instalacao/escopo_projeto.dart';
import '../../domain/instalacao/tag_circuito.dart';
import '../../models/violacao.dart';

/// Parâmetros de entrada para [SpecCircuitoIndependente].
typedef EntradaCircuitoIndependente = ({
  TagCircuito tag,
  double ibCircuito,
  bool circuitoExclusivo,
});

/// S-9 — Circuito exclusivo para equipamentos com Ib > 10 A.
///
/// Todo TUE com corrente de projeto superior a 10 A deve ter circuito
/// independente, não compartilhado com outros pontos ou circuitos.
/// Viola CIRC_001 quando a condição não é atendida.
///
/// Rastreabilidade: NBR 5410:2004 — 9.5.3.1.
final class SpecCircuitoIndependente
    implements ISpecification<EntradaCircuitoIndependente> {
  const SpecCircuitoIndependente();

  @override
  bool aplicavelA(final PerfilInstalacao perfil) =>
      perfil.escopo == EscopoProjeto.residencial;

  @override
  List<Violacao> verificar(final EntradaCircuitoIndependente entrada) {
    if (entrada.tag != TagCircuito.tue) return const [];
    if (entrada.ibCircuito <= 10.0) return const [];
    if (entrada.circuitoExclusivo) return const [];
    return [
      Violacao.circuitoTueNaoExclusivo(ibCircuito: entrada.ibCircuito),
    ];
  }
}
