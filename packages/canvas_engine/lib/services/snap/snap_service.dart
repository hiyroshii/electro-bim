// REV: 2.9.0
// CHANGELOG:
// [2.9.0] - 02 05 2026
// - ADD: parâmetro extraPoints para snap em vértices parciais (ferramenta em construção)
// - FIX: Pline em desenho agora snapa nos vértices já colocados
//
// [2.8.0] - 02 05 2026
// - ADD: PlineSnapProvider registrado em createDefault()
//
// [2.7.0] - 02 05 2026
// - ADD: createDefault() factory para uso direto no engine/UI

import 'package:canvas_engine/domain/value_objects/vector3.dart';
import 'package:canvas_engine/domain/entities/shape.dart';

import 'package:canvas_engine/services/snap/snap_result.dart';
import 'package:canvas_engine/services/snap/snap_type.dart';
import 'package:canvas_engine/services/snap/snap_candidate.dart';

import 'package:canvas_engine/services/snap/providers/snap_provider.dart';
import 'package:canvas_engine/services/snap/providers/global_snap_provider.dart';

import 'package:canvas_engine/services/snap/providers/line_snap_provider.dart';
import 'package:canvas_engine/services/snap/providers/pline_snap_provider.dart';
import 'package:canvas_engine/services/snap/providers/intersection_snap_provider.dart';

class SnapService {
  final List<SnapProvider> _shapeProviders;
  final List<GlobalSnapProvider> _globalProviders;

  SnapService({
    List<SnapProvider>? shapeProviders,
    List<GlobalSnapProvider>? globalProviders,
  })  : _shapeProviders = shapeProviders ?? [],
        _globalProviders = globalProviders ?? [];

  factory SnapService.createDefault() {
    return SnapService(
      shapeProviders: [
        LineSnapProvider(),
        PlineSnapProvider(),
      ],
      globalProviders: [
        IntersectionSnapProvider(),
      ],
    );
  }

  static const double _tolerancePx = 10.0;

  int _priority(SnapType type) {
    switch (type) {
      case SnapType.endpoint:
        return 0;
      case SnapType.midpoint:
        return 1;
      case SnapType.intersection:
        return 2;
      case SnapType.nearest:
        return 3;
      default:
        return 99;
    }
  }

  SnapResult snap({
    required Vector3 mousePoint,
    required double zoom,
    required List<Shape> sceneShapes,
    List<Vector3>? extraPoints,
  }) {
    final toleranceWorld = _tolerancePx / zoom;

    SnapCandidate? best;
    int bestPriority = 999;
    double bestDistance = double.infinity;

    void evaluate(SnapCandidate c) {
      if (c.distance > toleranceWorld) return;

      final p = _priority(c.type);

      final isBetter =
          (p < bestPriority) ||
          (p == bestPriority && c.distance < bestDistance);

      if (isBetter) {
        best = c;
        bestPriority = p;
        bestDistance = c.distance;
      }
    }

    // Shapes da cena
    for (final shape in sceneShapes) {
      for (final provider in _shapeProviders) {
        final candidates = provider.computeCandidates(
          point: mousePoint,
          shape: shape,
          zoom: zoom,
        );

        for (final c in candidates) {
          evaluate(c);
        }
      }
    }

    // Global providers
    for (final provider in _globalProviders) {
      final candidates = provider.computeCandidates(
        point: mousePoint,
        sceneShapes: sceneShapes,
        zoom: zoom,
      );

      for (final c in candidates) {
        evaluate(c);
      }
    }

    // Pontos extras (vértices parciais da ferramenta em construção)
    if (extraPoints != null) {
      for (final p in extraPoints) {
        evaluate(SnapCandidate(
          p,
          SnapType.endpoint,
          mousePoint.distanceTo(p),
        ));
      }
    }

    final result = best;

    if (result == null) {
      return SnapResult(mousePoint, SnapType.none);
    }

    return SnapResult(result.point, result.type);
  }
}