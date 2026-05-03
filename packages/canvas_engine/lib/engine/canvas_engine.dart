// REV: 1.0.2
// CHANGELOG:
// [1.0.2] - 02 05 2026
// - CHG: Vector2 → Vector3 — preparação para terreno 3D (Ciclo 0)
//
// [1.0.1] - 01 05 2026
// - FIX: imports absolutos (eram relativos)
//
// [1.0.0] - 29 04 2026
// - ADD: CanvasEngine itera Scene e delega draw a cada Shape

import 'package:canvas_engine/engine/scene.dart';
import 'package:canvas_engine/render/render_adapter.dart';

class CanvasEngine {
  final RenderAdapter adapter;

  CanvasEngine(this.adapter);

  void render(Scene scene) {
    for (final shape in scene.elements) {
      shape.draw(adapter);
    }
  }
}