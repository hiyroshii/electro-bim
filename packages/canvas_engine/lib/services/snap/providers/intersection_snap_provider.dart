// REV: 1.0.1
// CHANGELOG:
// [1.0.1] - 04 05 2026
// - FIX: ativada coleta de segmentos de PlineShape
// - interseções entre polilinhas (e entre polilinhas e linhas) voltam a funcionar
//
// [1.0.0] - 02 05 2026
// - ADD: IntersectionSnapProvider — snap em interseções de segmentos

import 'package:canvas_engine/domain/value_objects/vector3.dart';
import 'package:canvas_engine/domain/entities/shape.dart';
import 'package:canvas_engine/domain/entities/line_shape.dart';
import 'package:canvas_engine/domain/entities/pline_shape.dart'; // ← adicionado
import 'package:canvas_engine/services/snap/providers/global_snap_provider.dart';
import 'package:canvas_engine/services/snap/snap_candidate.dart';
import 'package:canvas_engine/services/snap/snap_type.dart';
import 'package:canvas_engine/domain/geometry/primitives/segment.dart';
import 'package:canvas_engine/domain/geometry/operations/intersection.dart';

class IntersectionSnapProvider implements GlobalSnapProvider {
  @override
  List<SnapCandidate> computeCandidates({
    required Vector3 point,
    required List<Shape> sceneShapes,
    required double zoom,
  }) {
    final candidates = <SnapCandidate>[];

    // coleta todos os segmentos das shapes que podem fornecer geometria
    final segments = <Segment>[];
    for (final shape in sceneShapes) {
      if (shape is LineShape) {
        segments.add(shape.segment);
      }
      if (shape is PlineShape) {
        segments.addAll(shape.segments); // ← ATIVADO
      }
    }

    // calcula interseção entre todos os pares únicos (evita duplicatas)
    for (int i = 0; i < segments.length; i++) {
      for (int j = i + 1; j < segments.length; j++) {
        final result = intersectSegments(segments[i], segments[j]);
        if (result.type == IntersectionType.intersect && result.point != null) {
          final intersection = result.point!;
          final distance = point.distanceTo(intersection);
          candidates.add(SnapCandidate(intersection, SnapType.intersection, distance));
        }
      }
    }

    return candidates;
  }
}