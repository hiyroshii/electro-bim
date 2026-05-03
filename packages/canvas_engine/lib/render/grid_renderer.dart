// REV: 1.1.0
// CHANGELOG:
// [1.1.0] - 02 05 2026
// - CHG: Vector2 → Vector3 — preparação para terreno 3D (Ciclo 0)
//
// [1.0.0] - 02 05 2026
// - ADD: GridRenderer — desenha grid em WORLD space via RenderAdapter
// - ADD: cálculo de bounds visíveis via Viewport

import 'package:canvas_engine/render/render_adapter.dart';
import 'package:canvas_engine/domain/value_objects/vector3.dart';
import 'package:canvas_engine/viewport/viewport.dart';

class GridRenderer {
  final double gridSize;
  final Viewport viewport;

  GridRenderer({required this.gridSize, required this.viewport});

  void render(RenderAdapter adapter, Vector3 screenSize) {
    final topLeft = viewport.screenToWorld(Vector3.zero);
    final bottomRight = viewport.screenToWorld(screenSize);

    final startX = (topLeft.x / gridSize).floor() * gridSize;
    final endX = (bottomRight.x / gridSize).ceil() * gridSize;
    final startY = (topLeft.y / gridSize).floor() * gridSize;
    final endY = (bottomRight.y / gridSize).ceil() * gridSize;

    for (double x = startX; x <= endX; x += gridSize) {
      adapter.drawLine(Vector3(x, startY, 0), Vector3(x, endY, 0));
    }

    for (double y = startY; y <= endY; y += gridSize) {
      adapter.drawLine(Vector3(startX, y, 0), Vector3(endX, y, 0));
    }
  }
}