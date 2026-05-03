// REV: 2.0.0
// CHANGELOG:
// [2.0.0] - 02 05 2026
// - CHG: implementa computeCandidates() retornando endpoint, midpoint, nearest
// - ADD: cálculo de distância individual por candidato
// - DEL: lógica de escolha interna (agora quem escolhe é o SnapService)
//
// [1.2.0] - 02 05 2026
// - CHG: Vector2 → Vector3 (Ciclo 0)
// ...

import 'package:canvas_engine/domain/value_objects/vector3.dart';
import 'package:canvas_engine/domain/entities/shape.dart';
import 'package:canvas_engine/domain/entities/line_shape.dart';
import 'package:canvas_engine/services/snap/providers/snap_provider.dart';
import 'package:canvas_engine/services/snap/snap_candidate.dart';
import 'package:canvas_engine/services/snap/snap_type.dart';
import 'package:canvas_engine/domain/geometry/operations/projection.dart';

class LineSnapProvider implements SnapProvider {
  @override
  List<SnapCandidate> computeCandidates({
    required Vector3 point,
    required Shape shape,
    required double zoom,
  }) {
    if (shape is! LineShape) return [];
    final start = shape.start;
    final end = shape.end;

    final candidates = <SnapCandidate>[];

    // endpoint – start
    candidates.add(SnapCandidate(
      start,
      SnapType.endpoint,
      point.distanceTo(start),
    ));

    // endpoint – end
    candidates.add(SnapCandidate(
      end,
      SnapType.endpoint,
      point.distanceTo(end),
    ));

    // midpoint
    final mid = Vector3(
      (start.x + end.x) / 2,
      (start.y + end.y) / 2,
      0,
    );
    candidates.add(SnapCandidate(
      mid,
      SnapType.midpoint,
      point.distanceTo(mid),
    ));

    // nearest (projeção no segmento)
    final nearest = Projection.pointToSegment(point, start, end);
    candidates.add(SnapCandidate(
      nearest,
      SnapType.nearest,
      point.distanceTo(nearest),
    ));

    return candidates;
  }
}