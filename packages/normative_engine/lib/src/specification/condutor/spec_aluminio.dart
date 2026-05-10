// REV: 2.0.0
// CHANGELOG:
// [2.0.0] - 2026-05
// - CHG: migrado de ContextoInstalacao para PerfilInstalacao (Fase 2).
// [1.0.1] - 2026-04
// - CHG: ContextoInstalacao movido para src/enums/contexto_instalacao.dart.
// [1.0.0] - 2026-04
// - ADD: verificação de restrições de uso do alumínio (6.2.3.8).

import '../../contracts/i_specification.dart';
import '../../domain/condutor/material.dart';
import '../../domain/instalacao/escopo_projeto.dart';
import '../../models/violacao.dart';
import '../../models/entrada_normativa.dart';

/// Verifica restrições de uso do condutor de alumínio.
///
/// Rastreabilidade: NBR 5410:2004 — 6.2.3.8.
final class SpecAluminio implements ISpecification<EntradaNormativa> {

  const SpecAluminio({
    required this.perfil,
    this.secaoCalculada,
  });
  final PerfilInstalacao perfil;
  final double? secaoCalculada;

  @override
  bool aplicavelA(final PerfilInstalacao p) => true;

  @override
  List<Violacao> verificar(final EntradaNormativa entrada) {
    final violacoes = <Violacao>[];

    if (entrada.material != Material.aluminio) return violacoes;

    // BD4 — proibido absolutamente.
    // Rastreabilidade: NBR 5410:2004 — 6.2.3.8.
    if (perfil.possuiInfluencia(CodigoInfluencia.bd4)) {
      violacoes.add(Violacao.aluminioProibidoBd4());
      return violacoes;
    }

    // Seção mínima por escopo/contexto.
    // Rastreabilidade: NBR 5410:2004 — 6.2.3.8.1 (industrial), 6.2.3.8.2 (comercial).
    final secaoMinima = _resolverSecaoMinima();
    if (secaoMinima == null) return violacoes;

    if (secaoCalculada != null && secaoCalculada! < secaoMinima) {
      violacoes.add(Violacao.aluminioSecaoInsuficiente(
        secaoMinima: secaoMinima,
        contexto: perfil.escopo.name,
      ),);
    }

    return violacoes;
  }

  double? _resolverSecaoMinima() => switch (perfil.escopo) {
        EscopoProjeto.residencial => null,
        // Rastreabilidade: NBR 5410:2004 — 6.2.3.8.1.
        EscopoProjeto.industrial => 16.0,
        // Rastreabilidade: NBR 5410:2004 — 6.2.3.8.2.
        EscopoProjeto.comercial =>
          perfil.possuiInfluencia(CodigoInfluencia.bd1) ? 50.0 : null,
      };
}
