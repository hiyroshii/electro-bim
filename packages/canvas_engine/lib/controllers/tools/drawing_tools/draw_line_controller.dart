// REV: 1.3.0
// CHANGELOG:
// [1.3.0] - 02 05 2026
// - CHG: implements DrawingTool (ex-Tool)
// - CHG: Vector2 → Vector3 — preparação para terreno 3D (Ciclo 0)
//
// [1.2.0] - 01 05 2026
// - ADD: finish() — Escape descarta ponto pendente
//
// [1.1.0] - 29 04 2026
// - ADD: implements Tool, reset(), drawPreview()
//
// [1.0.0] - 29 04 2026
// - ADD: estado start/current, onTap cria linha e encerra, onMove atualiza preview

import 'package:canvas_engine/domain/value_objects/vector3.dart';
import 'package:canvas_engine/engine/scene.dart';
import 'package:canvas_engine/domain/entities/line_shape.dart';
import 'package:canvas_engine/render/render_adapter.dart';
import 'package:canvas_engine/controllers/tools/drawing_tools/drawing_tools_contract.dart';

class DrawLineController implements DrawingTool {
  Vector3? start;
  Vector3? current;

  @override
  void onTap(Vector3 point, Scene scene) {
    if (start == null) {
      start = point;
    } else {
      scene.add(LineShape(start!, point));
      start = null;
      current = null;
    }
  }

  @override
  void onMove(Vector3 point) {
    if (start != null) current = point;
  }

  @override
  void finish() {
    start = null;
    current = null;
  }

  @override
  void reset() {
    start = null;
    current = null;
  }

  @override
  void drawPreview(RenderAdapter adapter) {
    final s = start;
    final c = current;
    if (s != null && c != null) adapter.drawLine(s, c);
  }
}