// REV: 1.1.0
// CHANGELOG:
// [1.1.0] - 02 05 2026
// - CHG: Vector2 → Vector3 — preparação para terreno 3D (Ciclo 0)
// - CHG: cross permanece 2D (x,y) — interseção no plano XY
//
// [1.0.0] - 29 04 2026
// - ADD: intersectSegments com fórmula de Gavin
// - ADD: IntersectionResult tipado, IntersectionType enum
// - ADD: trata paralelo, colinear, none, intersect via Tolerance.parallel

import 'package:canvas_engine/domain/value_objects/vector3.dart';
import 'package:canvas_engine/domain/geometry/primitives/segment.dart';
import 'package:canvas_engine/domain/geometry/tolerance.dart';

enum IntersectionType { intersect, parallel, collinear, none }

/// Resultado tipado de intersecção entre dois segmentos.
final class IntersectionResult {
  final IntersectionType type;
  final Vector3? point;

  const IntersectionResult._(this.type, this.point);

  static const IntersectionResult parallel =
      IntersectionResult._(IntersectionType.parallel, null);
  static const IntersectionResult collinear =
      IntersectionResult._(IntersectionType.collinear, null);
  static const IntersectionResult none =
      IntersectionResult._(IntersectionType.none, null);

  factory IntersectionResult.intersect(Vector3 point) =>
      IntersectionResult._(IntersectionType.intersect, point);

  bool get hasPoint => point != null;
}

/// Calcula interseção entre [s1] e [s2] pelo método paramétrico de Gavin.
/// Opera no plano XY (ignora Z).
IntersectionResult intersectSegments(Segment s1, Segment s2) {
  final p = s1.a;
  final r = s1.direction;
  final q = s2.a;
  final s = s2.direction;

  final rCrossS = r.cross(s);
  final qMinusP = q - p;

  if (rCrossS.abs() < Tolerance.parallel) {
    return qMinusP.cross(r).abs() < Tolerance.parallel
        ? IntersectionResult.collinear
        : IntersectionResult.parallel;
  }

  final t = qMinusP.cross(s) / rCrossS;
  final u = qMinusP.cross(r) / rCrossS;

  if (t >= 0 && t <= 1 && u >= 0 && u <= 1) {
    final intersection = p + r * t;
    return IntersectionResult.intersect(intersection);
  }

  return IntersectionResult.none;
}