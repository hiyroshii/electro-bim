// REV: 1.1.0
// CHANGELOG:
// [1.1.0] - 02 05 2026
// - CHG: Vector2 → Vector3 — preparação para terreno 3D (Ciclo 0)
//
// [1.0.0] - 29 04 2026
// - ADD: distancePointToPoint, distancePointToSegment
// - ADD: closestPointOnSegment, isPointOnSegment
// - ADD: guarda para segmento degenerado em distancePointToSegment

import 'package:canvas_engine/domain/value_objects/vector3.dart';
import 'package:canvas_engine/domain/geometry/primitives/segment.dart';
import 'package:canvas_engine/domain/geometry/tolerance.dart';

double distancePointToPoint(Vector3 a, Vector3 b) => a.distanceTo(b);

/// Ponto no segmento [s] mais próximo de [p].
/// Se [s] for degenerado, retorna s.a.
Vector3 closestPointOnSegment(Vector3 p, Segment s) {
  if (s.isDegenerate) return s.a;
  final ab = s.direction;
  final ap = p - s.a;
  final t = (ap.dot(ab) / ab.lengthSquared).clamp(0.0, 1.0);
  return s.a + ab * t;
}

/// Distância mínima entre ponto [p] e segmento [s].
double distancePointToSegment(Vector3 p, Segment s) =>
    p.distanceTo(closestPointOnSegment(p, s));

/// Retorna true se [p] está a menos de [tolerance] do segmento [s].
bool isPointOnSegment(
  Vector3 p,
  Segment s, {
  double tolerance = Tolerance.geometric,
}) =>
    distancePointToSegment(p, s) < tolerance;