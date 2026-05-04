// REV: 1.3.1
// CHANGELOG:
// [1.3.1] - 02 05 2026
// - ADD: getter isActive (retorna start != null)
// - ADD: método cancel() — reseta a ferramenta sem finalizar a linha

import 'package:canvas_engine/domain/value_objects/vector3.dart';
import 'package:canvas_engine/engine/scene.dart';
import 'package:canvas_engine/domain/entities/line_shape.dart';
import 'package:canvas_engine/render/render_adapter.dart';
import 'package:canvas_engine/controllers/tools/drawing_tools/drawing_tools_contract.dart';

class DrawLineController implements DrawingTool {
  Vector3? start;
  Vector3? current;

  @override
  bool get isActive => start != null;

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

  /// Cancela a linha em andamento (ex.: Ctrl+Z durante o desenho).
  void cancel() {
    start = null;
    current = null;
    // A ferramenta continua ativa, mas sem ponto inicial
  }

  @override
  void drawPreview(RenderAdapter adapter) {
    final s = start;
    final c = current;
    if (s != null && c != null) adapter.drawLine(s, c);
  }
}