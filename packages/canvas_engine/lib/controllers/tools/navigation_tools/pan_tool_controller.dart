// REV: 1.0.0
// CHANGELOG:
// [1.0.0] - 02 05 2026
// - ADD: PanToolController — lógica de navegação (pan) desacoplada
// - ADD: estado interno _isPanning
// - ADD: reset() para segurança ao trocar de modo

import 'package:canvas_engine/domain/value_objects/vector3.dart';
import 'package:canvas_engine/viewport/viewport.dart';

class PanToolController {
  final Viewport viewport;

  bool _isPanning = false;
  bool get isPanning => _isPanning;

  PanToolController({required this.viewport});

  void onPointerDown(Vector3 screenPoint) {
    _isPanning = true;
  }

  void onPointerMove(Vector3 screenDelta) {
    if (_isPanning) {
      viewport.pan(screenDelta);
    }
  }

  void onPointerUp(Vector3 screenPoint) {
    _isPanning = false;
  }

  void reset() {
    _isPanning = false;
  }
}