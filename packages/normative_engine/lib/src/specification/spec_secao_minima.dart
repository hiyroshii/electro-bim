// REV: 1.0.0
// CHANGELOG:
// [1.0.0] - 2026-04
// - ADD: verificação de seção mínima normativa (Tabela 47).

import '../contracts/i_specification.dart';
import '../models/violacao.dart';
import '../models/entrada_normativa.dart';
import '../tables/tabela_47_48_secao_minima_neutro.dart';

/// Verifica se a seção calculada respeita o piso normativo da Tabela 47.
///
/// Rastreabilidade: NBR 5410:2004 — Tabela 47, Seção 6.2.6.1.1.
final class SpecSecaoMinima implements ISpecification<EntradaNormativa> {

  const SpecSecaoMinima({required this.secaoCalculada});
  /// Seção calculada pelo algoritmo de dimensionamento (mm²).
  /// Recebida do [dimensionamento_engine] após seleção inicial.
  final double secaoCalculada;

  @override
  List<Violacao> verificar(final EntradaNormativa entrada) {
    final violacoes = <Violacao>[];

    final secaoMinima =
        tabelaSecaoMinima[(entrada.tagCircuito, entrada.material)];

    if (secaoMinima == null || secaoMinima == 0.0) return violacoes;

    if (secaoCalculada < secaoMinima) {
      violacoes.add(Violacao.secaoAbaixoMinimo(
        secaoCalculada: secaoCalculada,
        secaoMinima: secaoMinima,
        tag: entrada.tagCircuito.name.toUpperCase(),
      ),);
    }

    return violacoes;
  }
}
