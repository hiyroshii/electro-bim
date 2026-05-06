// REV: 1.0.0
// CHANGELOG:
// - ADD: DrawCircleController — ferramenta de desenho de círculos

import 'package:canvas_engine/canvas_engine.dart';

class DrawCircleController implements DrawingTool {
  Vector3? center;
  Vector3? current;

  @override
  bool get isActive => center != null;

  @override
  void onTap(Vector3 point, CadDocument document) {
    if (center == null) {
      center = point;
    } else {
      final radius = (point - center!).length;
      document.add(CircleShape(center!, radius));
      center = null;
      current = null;
    }
  }

  @override
  void onMove(Vector3 point) {
    if (center != null) current = point;
  }

  @override
  void finish() {
    center = null;
    current = null;
  }

  @override
  void reset() {
    center = null;
    current = null;
  }

  void cancel() {
    center = null;
    current = null;
  }

  @override
  void drawPreview(RenderAdapter adapter) {
    final c = center;
    final cur = current;
    if (c != null && cur != null) {
      final radius = (cur - c).length;
      adapter.drawCircle(c, radius);
    }
  }
}