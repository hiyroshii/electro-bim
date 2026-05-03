// REV: 1.0.0
// CHANGELOG:
// [1.0.0] - 02 05 2026
// - ADD: PlineSnapProvider — snap para polilinhas unificadas
// - ADD: itera segmentos e gera endpoint/midpoint/nearest por segmento
// - ADD: deduplica endpoints (vértices compartilhados entre segmentos)

import 'package:canvas_engine/domain/value_objects/vector3.dart';
import 'package:canvas_engine/domain/entities/shape.dart';
import 'package:canvas_engine/domain/entities/pline_shape.dart';
import 'package:canvas_engine/services/snap/providers/snap_provider.dart';
import 'package:canvas_engine/services/snap/snap_candidate.dart';
import 'package:canvas_engine/services/snap/snap_type.dart';
import 'package:canvas_engine/domain/geometry/operations/projection.dart';

class PlineSnapProvider implements SnapProvider {
  @override
  List<SnapCandidate> computeCandidates({
    required Vector3 point,
    required Shape shape,
    required double zoom,
  }) {
    if (shape is! PlineShape) return [];

    final candidates = <SnapCandidate>[];
    final vertices = shape.gripPoints;
    final segments = shape.segments;

    // --- Endpoints: todos os vértices (sem duplicatas) ---
    final Set<Vector3> endpoints = {};
    for (final v in vertices) {
      endpoints.add(v);
    }

    for (final ep in endpoints) {
      candidates.add(SnapCandidate(
        ep,
        SnapType.endpoint,
        point.distanceTo(ep),
      ));
    }

    // --- Midpoints e Nearest por segmento ---
    for (final seg in segments) {
      final start = seg.start;
      final end = seg.end;

      // midpoint do segmento
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
    }

    return candidates;
  }
}