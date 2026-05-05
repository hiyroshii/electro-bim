// REV: 1.4.0
// CHANGELOG:
// [1.4.0] - 04 05 2026
// - CHG: onTap substitui Scene por CadDocument (compatibilidade com Ciclo 3)
//
// [1.3.1] - 02 05 2026
// - ADD: getter isActive para indicar se a ferramenta está em uso

import 'package:canvas_engine/domain/value_objects/vector3.dart';
import 'package:canvas_engine/domain/documents/cad_document.dart';
import 'package:canvas_engine/render/render_adapter.dart';

abstract class DrawingTool {
  bool get isActive;

  void onTap(Vector3 point, CadDocument document);
  void onMove(Vector3 point);
  void finish();
  void reset();
  void drawPreview(RenderAdapter adapter);
}