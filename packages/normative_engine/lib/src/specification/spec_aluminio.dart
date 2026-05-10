// REV: 1.0.1
// CHANGELOG:
// [1.0.1] - 2026-04
// - CHG: ContextoInstalacao movido para src/enums/contexto_instalacao.dart.
// [1.0.0] - 2026-04
// - ADD: verificação de restrições de uso do alumínio (6.2.3.8).

import '../contracts/i_specification.dart';
import '../enums/material.dart';
import '../enums/contexto_instalacao.dart';
import '../models/violacao.dart';
import '../models/entrada_normativa.dart';

export '../enums/contexto_instalacao.dart';

/// Verifica restrições de uso do condutor de alumínio.
///
/// Rastreabilidade: NBR 5410:2004 — 6.2.3.8.
final class SpecAluminio implements ISpecification<EntradaNormativa> {

  const SpecAluminio({
    required this.contexto,
    this.secaoCalculada,
  });
  final ContextoInstalacao contexto;
  final double? secaoCalculada;

  @override
  List<Violacao> verificar(final EntradaNormativa entrada) {
    final violacoes = <Violacao>[];

    if (entrada.material != Material.aluminio) return violacoes;

    // BD4 — proibido absolutamente
    // Rastreabilidade: NBR 5410:2004 — 6.2.3.8.
    if (contexto == ContextoInstalacao.bd4) {
      violacoes.add(Violacao.aluminioProibidoBd4());
      return violacoes;
    }

    // Seção mínima por contexto
    // Rastreabilidade: NBR 5410:2004 — 6.2.3.8.1 (industrial), 6.2.3.8.2 (comercial).
    final secaoMinima = switch (contexto) {
      ContextoInstalacao.industrial   => 16.0,
      ContextoInstalacao.comercialBd1 => 50.0,
      ContextoInstalacao.bd4          => 0.0, // nunca chega aqui
    };

    if (secaoCalculada != null && secaoCalculada! < secaoMinima) {
      violacoes.add(Violacao.aluminioSecaoInsuficiente(
        secaoMinima: secaoMinima,
        contexto: contexto.name,
      ),);
    }

    return violacoes;
  }
}
