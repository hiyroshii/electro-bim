// REV: 1.1.0
// CHANGELOG:
// [1.1.0] - 02 05 2026
// - ADD: CanvasMode.select — modo de seleção de entidades (Ciclo 1)
//
// [1.0.0] - 29 04 2026
// - ADD: CanvasMode com draw e navigate

enum CanvasMode {
  /// Gestos alimentam a ferramenta ativa.
  draw,

  /// Gestos movem o viewport (pan + zoom).
  navigate,

  /// Seleciona e edita entidades existentes.
  select,
}