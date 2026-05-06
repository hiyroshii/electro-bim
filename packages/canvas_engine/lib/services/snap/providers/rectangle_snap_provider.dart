// REV: 1.0.0
// CHANGELOG:
// - ADD: RectangleSnapProvider — snap em cantos e midpoints de retângulos

import 'package:canvas_engine/domain/entities/shape.dart';
import 'package:canvas_engine/domain/entities/rectangle_shape.dart';
import 'package:canvas_engine/domain/value_objects/vector3.dart';
import 'package:canvas_engine/services/snap/providers/snap_provider.dart';
import 'package:canvas_engine/services/snap/snap_candidate.dart';
import 'package:canvas_engine/services/snap/snap_type.dart';

class RectangleSnapProvider implements SnapProvider {
  @override
  List<SnapCandidate> computeCandidates({
    required Vector3 point,
    required Shape shape,
    required double zoom,
  }) {
    if (shape is! RectangleShape) return [];
    final rect = shape;
    final candidates = <SnapCandidate>[];

    // Cantos (endpoints)
    final grips = rect.gripPoints; // já são os 4 cantos
    for (final grip in grips) {
      candidates.add(SnapCandidate(grip, SnapType.endpoint, point.distanceTo(grip)));
    }

    // Pontos médios das bordas (midpoints)
    for (int i = 0; i < grips.length; i++) {
      final next = grips[(i + 1) % grips.length];
      final mid = (grips[i] + next) * 0.5;
      candidates.add(SnapCandidate(mid, SnapType.midpoint, point.distanceTo(mid)));
    }

    return candidates;
  }
}