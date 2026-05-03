// REV: 1.0.0
// CHANGELOG:
// [1.0.0] - 02 05 2026
// - REN: tool.dart → drawing_tools_contract.dart
// - ADD: interface DrawingTool (ex-Tool) com onTap, onMove, reset, drawPreview
// - CHG: nome da interface de Tool para DrawingTool para evitar ambiguidade

import 'package:canvas_engine/domain/value_objects/vector3.dart';
import 'package:canvas_engine/engine/scene.dart';
import 'package:canvas_engine/render/render_adapter.dart';

abstract class DrawingTool {
  void onTap(Vector3 point, Scene scene);
  void onMove(Vector3 point);
  void finish();
  void reset();
  void drawPreview(RenderAdapter adapter);
}