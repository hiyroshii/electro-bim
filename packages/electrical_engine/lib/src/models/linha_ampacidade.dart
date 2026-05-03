// REV: 1.0.0
// CHANGELOG:
// [1.0.0] - 2026-04
// - ADD: criação do model LinhaAmpacidade.

/// Uma linha da tabela de ampacidade resolvida para o contexto da entrada.
///
/// Representa uma seção comercial disponível com sua ampacidade base (Iz)
/// extraída da tabela normativa correspondente.
///
/// O [SelecionadorCondutor] itera sobre uma lista ordenada de [LinhaAmpacidade]
/// para encontrar a menor seção que satisfaz todos os critérios.
///
/// Rastreabilidade: NBR 5410:2004 — Tabelas 36–39.
final class LinhaAmpacidade {
  /// Seção nominal do condutor em mm².
  /// Valores normalizados: 0,5 / 0,75 / 1 / 1,5 / 2,5 / 4 / 6 / 10 /
  /// 16 / 25 / 35 / 50 / 70 / 95 / 120 / 150 / 185 / 240 / 300 / 400 /
  /// 500 / 630 / 800 / 1000.
  final double secao;

  /// Ampacidade base (A) para o contexto de instalação.
  /// Extraída diretamente da tabela normativa — sem fatores de correção.
  /// Rastreabilidade: NBR 5410:2004 — Tabelas 36–39.
  final double izBase;

  const LinhaAmpacidade({
    required this.secao,
    required this.izBase,
  });

  @override
  String toString() =>
      'LinhaAmpacidade(secao: $secao mm², izBase: $izBase A)';
}
