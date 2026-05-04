// REV: 1.3.1
// CHANGELOG:
// [1.3.1] - 02 05 2026
// - ADD: getter isActive para indicar se a ferramenta está em uso
//
// [1.3.0] - 02 05 2026
// - CHG: renomeado Tool para DrawingTool
// ... (histórico anterior mantido)

import 'package:canvas_engine/domain/value_objects/vector3.dart';
import 'package:canvas_engine/engine/scene.dart';
import 'package:canvas_engine/render/render_adapter.dart';

abstract class DrawingTool {
  bool get isActive; // ← NOVO

  void onTap(Vector3 point, Scene scene);
  void onMove(Vector3 point);
  void finish();
  void reset();
  void drawPreview(RenderAdapter adapter);
}