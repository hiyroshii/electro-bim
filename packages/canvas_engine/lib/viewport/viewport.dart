// REV: 1.2.0
// CHANGELOG:
// [1.2.0] - 02 05 2026
// - CHG: Vector2 → Vector3 — preparação para terreno 3D (Ciclo 0)
// - CHG: offset armazenado como Vector3 (z=0 mantido)
//
// [1.1.0] - 02 05 2026
// - FIX: correção matemática do zoom (remoção de drift acumulado)
// - CHG: fórmula padrão de zoom centrado em focal point
// - CHG: código mais determinístico

import 'package:canvas_engine/domain/value_objects/vector3.dart';

class Viewport {
  Vector3 offset;
  double scale;

  Viewport({
    this.offset = Vector3.zero,
    this.scale = 1.0,
  });

  Vector3 worldToScreen(Vector3 world) =>
      Vector3(world.x * scale + offset.x, world.y * scale + offset.y, 0);

  Vector3 screenToWorld(Vector3 screen) =>
      Vector3((screen.x - offset.x) / scale, (screen.y - offset.y) / scale, 0);

  void zoom(double factor, Vector3 focalScreen) {
    final before = screenToWorld(focalScreen);

    scale *= factor;

    offset = focalScreen - (before * scale);
  }

  void pan(Vector3 screenDelta) {
    offset = offset + screenDelta;
  }
}