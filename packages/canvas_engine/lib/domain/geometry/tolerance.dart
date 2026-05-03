// REV: 1.0.0
// CHANGELOG:
// [1.0.0] - 29 04 2026
// - ADD: Tolerance com constantes nomeadas por contexto
// - ADD: geometric, parallel, hitTestPixels, hitTestWorld(scale)

/// Tolerâncias numéricas do motor gráfico.
///
/// Nunca usar literal numérico solto — sempre referenciar uma constante nomeada.
abstract final class Tolerance {
  /// Comparação de posições em coordenadas world.
  static const double geometric = 1e-6;

  /// Detecção de paralelismo via cross product.
  static const double parallel = 1e-9;

  /// Raio de hit test em pixels de tela.
  static const double hitTestPixels = 6.0;

  /// Tolerância de hit test convertida para world dado o zoom atual.
  ///
  /// Uso: distancePointToSegment(p, s) < Tolerance.hitTestWorld(viewport.scale)
  static double hitTestWorld(double scale) =>
      scale > 0 ? hitTestPixels / scale : hitTestPixels;
}
