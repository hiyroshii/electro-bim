// REV: 1.0.0
// CHANGELOG:
// [1.0.0] - 2026-05
// - ADD: S-11 — restrições para circuitos mistos IL + TUG (9.5.3.3).

import '../../contracts/i_specification.dart';
import '../../domain/instalacao/escopo_projeto.dart';
import '../../domain/locais/tipo_comodo.dart';
import '../../models/violacao.dart';

/// Parâmetros de entrada para [SpecCircuitoMisto].
typedef EntradaCircuitoMisto = ({
  bool temIl,
  bool temTug,
  double ibCircuito,
  bool unicoCircuitoIl,
  bool unicoCircuitoTug,
  List<TipoComodo> comodos,
});

const _areasNaoPermitidas = {
  TipoComodo.cozinha,
  TipoComodo.areaServico,
};

/// S-11 — Restrições para circuitos mistos (IL + TUG simultâneos).
///
/// Circuitos mistos são permitidos em habitações apenas quando:
/// - Ib ≤ 16 A (CIRC_003)
/// - Não é o único circuito de iluminação da instalação (CIRC_004)
/// - Não é o único circuito de TUG da instalação (CIRC_005)
/// - Não atende cozinhas ou áreas de serviço (CIRC_006)
///
/// Se o circuito não for misto (apenas IL ou apenas TUG),
/// retorna lista vazia — não há o que verificar.
///
/// Rastreabilidade: NBR 5410:2004 — 9.5.3.3.
final class SpecCircuitoMisto implements ISpecification<EntradaCircuitoMisto> {
  const SpecCircuitoMisto();

  @override
  bool aplicavelA(final PerfilInstalacao perfil) =>
      perfil.escopo == EscopoProjeto.residencial;

  @override
  List<Violacao> verificar(final EntradaCircuitoMisto entrada) {
    if (!entrada.temIl || !entrada.temTug) return const [];

    final violacoes = <Violacao>[];

    if (entrada.ibCircuito > 16.0) {
      violacoes.add(
        Violacao.circuitoMistoIbExcedido(ibCircuito: entrada.ibCircuito),
      );
    }
    if (entrada.unicoCircuitoIl) {
      violacoes.add(Violacao.circuitoMistoUnicaIl());
    }
    if (entrada.unicoCircuitoTug) {
      violacoes.add(Violacao.circuitoMistoUnicaTug());
    }

    final areasMolhadas = entrada.comodos
        .where(_areasNaoPermitidas.contains)
        .map((final c) => c.name)
        .toList();
    if (areasMolhadas.isNotEmpty) {
      violacoes.add(
        Violacao.circuitoMistoAreaMolhada(
          comodos: areasMolhadas.join(', '),
        ),
      );
    }

    return violacoes;
  }
}
