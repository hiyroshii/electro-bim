// REV: 1.1.0
// CHANGELOG:
// [1.1.0] - 02 05 2026
// - CHG: Vector2 → Vector3 (Ciclo 0)
//
// [1.0.2] - 02 05 2026
// - ADD: isSnapped flag para fallback seguro

import 'package:canvas_engine/domain/value_objects/vector3.dart';
import 'package:canvas_engine/services/snap/snap_type.dart';

final class SnapResult {
  final Vector3 position;
  final SnapType type;
  final bool isSnapped;

  const SnapResult(
    this.position,
    this.type, {
    this.isSnapped = true,
  });

  const SnapResult.none(Vector3 fallback)
      : position = fallback,
        type = SnapType.none,
        isSnapped = false;
}