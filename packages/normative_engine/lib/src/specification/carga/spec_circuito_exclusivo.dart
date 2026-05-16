// REV: 1.0.0
// CHANGELOG:
// [1.0.0] - 2026-05
// - ADD: S-10 — circuito exclusivo para TUGs em áreas molhadas (9.5.3.2).

import '../../contracts/i_specification.dart';
import '../../domain/instalacao/escopo_projeto.dart';
import '../../domain/instalacao/tag_circuito.dart';
import '../../domain/locais/tipo_comodo.dart';
import '../../models/violacao.dart';

/// Parâmetros de entrada para [SpecCircuitoExclusivo].
typedef EntradaCircuitoExclusivo = ({
  TipoComodo comodo,
  TagCircuito tag,
  bool circuitoExclusivo,
});

const _areasComCircuitoExclusivo = {
  TipoComodo.cozinha,
  TipoComodo.areaServico,
};

/// S-10 — Circuito exclusivo para TUGs em cozinhas e áreas de serviço.
///
/// As tomadas de cozinhas, copas, áreas de serviço e lavanderias devem ter
/// circuito exclusivo, não compartilhado com outros ambientes ou com IL.
/// Viola CIRC_002 quando a condição não é atendida.
///
/// Rastreabilidade: NBR 5410:2004 — 9.5.3.2.
final class SpecCircuitoExclusivo
    implements ISpecification<EntradaCircuitoExclusivo> {
  const SpecCircuitoExclusivo();

  @override
  bool aplicavelA(final PerfilInstalacao perfil) =>
      perfil.escopo == EscopoProjeto.residencial;

  @override
  List<Violacao> verificar(final EntradaCircuitoExclusivo entrada) {
    if (entrada.tag != TagCircuito.tug) return const [];
    if (!_areasComCircuitoExclusivo.contains(entrada.comodo)) return const [];
    if (entrada.circuitoExclusivo) return const [];
    return [
      Violacao.tugAreaMolhadaNaoExclusiva(comodo: entrada.comodo.name),
    ];
  }
}
