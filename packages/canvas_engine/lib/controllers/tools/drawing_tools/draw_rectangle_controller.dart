// REV: 1.0.0
// CHANGELOG:
// - ADD: DrawRectangleController — ferramenta de desenho de retângulos

import 'package:canvas_engine/canvas_engine.dart';

class DrawRectangleController implements DrawingTool {
  Vector3? corner1;
  Vector3? current;

  @override
  bool get isActive => corner1 != null;

  @override
  void onTap(Vector3 point, CadDocument document) {
    if (corner1 == null) {
      corner1 = point;
    } else {
      document.add(RectangleShape(corner1!, point));
      corner1 = null;
      current = null;
    }
  }

  @override
  void onMove(Vector3 point) {
    if (corner1 != null) current = point;
  }

  @override
  void finish() {
    corner1 = null;
    current = null;
  }

  @override
  void reset() {
    corner1 = null;
    current = null;
  }

  void cancel() {
    corner1 = null;
    current = null;
  }

  @override
  void drawPreview(RenderAdapter adapter) {
    final c1 = corner1;
    final c2 = current;
    if (c1 != null && c2 != null) {
      final origin = Vector3(
        c1.x < c2.x ? c1.x : c2.x,
        c1.y < c2.y ? c1.y : c2.y,
        0,
      );
      final width = (c1.x - c2.x).abs();
      final height = (c1.y - c2.y).abs();
      adapter.drawRect(origin, width, height);
    }
  }
}