// REV: 1.2.0
// CHANGELOG:
// [1.2.0] - 02 05 2026
// - CHG: Vector2 → Vector3 — preparação para terreno 3D (Ciclo 0)
//
// [1.1.0] - 01 05 2026
// - ADD: finish() — encerra por ação do usuário (Escape)
//
// [1.0.0] - 29 04 2026
// - ADD: interface Tool com onTap, onMove, reset, drawPreview

import 'package:canvas_engine/domain/value_objects/vector3.dart';
import 'package:canvas_engine/domain/documents/cad_document.dart';
import 'package:canvas_engine/render/render_adapter.dart';

abstract class Tool {
  void onTap(Vector3 point, CadDocument document);
  void onMove(Vector3 point);
  void finish();
  void reset();
  void drawPreview(RenderAdapter adapter);
}