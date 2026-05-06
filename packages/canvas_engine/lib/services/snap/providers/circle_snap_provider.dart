// REV: 1.0.0
// CHANGELOG:
// - ADD: CircleSnapProvider — snap em centro e quadrantes do círculo

import 'package:canvas_engine/domain/entities/shape.dart';
import 'package:canvas_engine/domain/entities/circle_shape.dart';
import 'package:canvas_engine/domain/value_objects/vector3.dart';
import 'package:canvas_engine/services/snap/providers/snap_provider.dart';
import 'package:canvas_engine/services/snap/snap_candidate.dart';
import 'package:canvas_engine/services/snap/snap_type.dart';

class CircleSnapProvider implements SnapProvider {
  @override
  List<SnapCandidate> computeCandidates({
    required Vector3 point,
    required Shape shape,
    required double zoom,
  }) {
    if (shape is! CircleShape) return [];
    final circle = shape;
    final candidates = <SnapCandidate>[];

    // Centro (endpoint)
    candidates.add(SnapCandidate(circle.center, SnapType.center, point.distanceTo(circle.center)));

    // Quadrantes (endpoints)
    final r = circle.radius;
    final quadrants = [
      Vector3(circle.center.x + r, circle.center.y, 0),
      Vector3(circle.center.x, circle.center.y + r, 0),
      Vector3(circle.center.x - r, circle.center.y, 0),
      Vector3(circle.center.x, circle.center.y - r, 0),
    ];
    for (final q in quadrants) {
      candidates.add(SnapCandidate(q, SnapType.endpoint, point.distanceTo(q)));
    }

    return candidates;
  }
}