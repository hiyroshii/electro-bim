// REV: 2.0.0
// CHANGELOG:
// [2.0.0] - 02 05 2026
// - CHG: compute() removido — substituído por computeCandidates()
// - ADD: recebe List<Shape> sceneShapes (acesso a todas as geometrias)
// - CHG: retorna List<SnapCandidate>
//
// [1.0.0] - 02 05 2026
// - ADD: GlobalSnapProvider original (snap independente de Shape)

import 'package:canvas_engine/domain/value_objects/vector3.dart';
import 'package:canvas_engine/domain/entities/shape.dart';
import 'package:canvas_engine/services/snap/snap_candidate.dart';

abstract class GlobalSnapProvider {
  /// Retorna candidatos de snap que dependem de múltiplas shapes
  /// (ex: interseções, grid). Pode usar toda a cena.
  List<SnapCandidate> computeCandidates({
    required Vector3 point,
    required List<Shape> sceneShapes,
    required double zoom,
  });
}