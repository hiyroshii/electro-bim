// REV: 1.4.0
// CHANGELOG:
// [1.4.0] - 04 05 2026
// - CHG: onTap aceita CadDocument em vez de Scene
//
// ... (histórico mantido)

import 'package:canvas_engine/domain/value_objects/vector3.dart';
import 'package:canvas_engine/domain/documents/cad_document.dart';
import 'package:canvas_engine/domain/entities/line_shape.dart';
import 'package:canvas_engine/render/render_adapter.dart';
import 'package:canvas_engine/controllers/tools/drawing_tools/drawing_tools_contract.dart';

class DrawLineController implements DrawingTool {
  Vector3? start;
  Vector3? current;

  @override
  bool get isActive => start != null;

  @override
  void onTap(Vector3 point, CadDocument document) {
    if (start == null) {
      start = point;
    } else {
      document.add(LineShape(start!, point));
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

  void cancel() {
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