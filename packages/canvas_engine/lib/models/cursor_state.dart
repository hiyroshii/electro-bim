// REV: 1.2.1
// CHANGELOG:
// [1.2.1] - 02 05 2026
// - ADD: método clear() para resetar o cursor
//
// [1.2.0] - 02 05 2026
// - CHG: Vector2 → Vector3 — preparação para terreno 3D (Ciclo 0)
//
// [1.1.0] - 02 05 2026
// - ADD: campo snapType — tipo de snap ativo para cor do cursor
//
// [1.0.0] - 29 04 2026
// - ADD: CursorState com world e snapped

import 'package:canvas_engine/domain/value_objects/vector3.dart';
import 'package:canvas_engine/services/snap/snap_type.dart';

class CursorState {
  Vector3 world = Vector3.zero;
  Vector3 snapped = Vector3.zero;
  SnapType snapType = SnapType.none;

  void update(Vector3 world, Vector3 snapped, SnapType type) {
    this.world = world;
    this.snapped = snapped;
    this.snapType = type;
  }

  void clear() {
    world = Vector3.zero;
    snapped = Vector3.zero;
    snapType = SnapType.none;
  }
}