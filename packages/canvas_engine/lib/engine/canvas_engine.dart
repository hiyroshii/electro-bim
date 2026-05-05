// REV: 1.1.0
// CHANGELOG:
// [1.1.0] - 04 05 2026
// - FIX: render() agora usa CadDocument.allVisibleShapes (Scene foi substituída por CadDocument)
// - CHG: parâmetro renomeado para document
//
// [1.0.2] - 02 05 2026
// - CHG: Vector2 → Vector3 — preparação para terreno 3D (Ciclo 0)
//
// [1.0.1] - 01 05 2026
// - FIX: imports absolutos (eram relativos)
//
// [1.0.0] - 29 04 2026
// - ADD: CanvasEngine itera Scene e delega draw a cada Shape

import 'package:canvas_engine/domain/documents/cad_document.dart';
import 'package:canvas_engine/render/render_adapter.dart';

class CanvasEngine {
  final RenderAdapter adapter;

  CanvasEngine(this.adapter);

  void render(CadDocument document) {
    for (final shape in document.allVisibleShapes) {
      shape.draw(adapter);
    }
  }
}