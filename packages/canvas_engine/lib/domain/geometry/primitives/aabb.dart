// REV: 1.1.0
// CHANGELOG:
// [1.1.0] - 02 05 2026
// - CHG: Vector2 → Vector3 — preparação para terreno 3D (Ciclo 0)
// - CHG: AABB ignora z (bounding box 2D)
//
// [1.0.0] - 29 04 2026
// - ADD: AABB imutável com fromPoints, fromSegment
// - ADD: contains, intersects, expand, union
// - ADD: width, height, center
// - ADD: final class — previne extensão não-intencional

import 'package:canvas_engine/domain/value_objects/vector3.dart';
import 'package:canvas_engine/domain/geometry/primitives/segment.dart';

/// Axis-Aligned Bounding Box em coordenadas WORLD (2D, ignora Z).
final class AABB {
  final double minX;
  final double minY;
  final double maxX;
  final double maxY;

  const AABB(this.minX, this.minY, this.maxX, this.maxY);

  factory AABB.fromPoints(Iterable<Vector3> points) {
    final iter = points.iterator;
    if (!iter.moveNext()) return const AABB(0, 0, 0, 0);
    double mnX = iter.current.x, mnY = iter.current.y;
    double mxX = iter.current.x, mxY = iter.current.y;
    while (iter.moveNext()) {
      final p = iter.current;
      if (p.x < mnX) mnX = p.x;
      if (p.y < mnY) mnY = p.y;
      if (p.x > mxX) mxX = p.x;
      if (p.y > mxY) mxY = p.y;
    }
    return AABB(mnX, mnY, mxX, mxY);
  }

  factory AABB.fromSegment(Segment s) => AABB.fromPoints([s.a, s.b]);

  double get width => maxX - minX;
  double get height => maxY - minY;
  Vector3 get center => Vector3((minX + maxX) / 2, (minY + maxY) / 2, 0);

  bool contains(Vector3 p) =>
      p.x >= minX && p.x <= maxX && p.y >= minY && p.y <= maxY;

  bool intersects(AABB other) =>
      minX <= other.maxX &&
      maxX >= other.minX &&
      minY <= other.maxY &&
      maxY >= other.minY;

  AABB expand(double margin) =>
      AABB(minX - margin, minY - margin, maxX + margin, maxY + margin);

  AABB union(AABB other) => AABB(
        minX < other.minX ? minX : other.minX,
        minY < other.minY ? minY : other.minY,
        maxX > other.maxX ? maxX : other.maxX,
        maxY > other.maxY ? maxY : other.maxY,
      );

  @override
  String toString() => 'AABB($minX,$minY → $maxX,$maxY)';
}