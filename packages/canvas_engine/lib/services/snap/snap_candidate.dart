// REV: 1.0.0
// CHANGELOG:
// [1.0.0] - 02 05 2026
// - ADD: SnapCandidate — estrutura imutável com point, type e distance
//        usada internamente pelos provedores de snap no Ciclo 1

import 'package:canvas_engine/domain/value_objects/vector3.dart';
import 'package:canvas_engine/services/snap/snap_type.dart';

final class SnapCandidate {
  final Vector3 point;
  final SnapType type;
  final double distance;

  const SnapCandidate(this.point, this.type, this.distance);
}