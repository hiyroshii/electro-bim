// REV: 1.0.0
// CHANGELOG:
// [1.0.0] - 02 05 2026
// - ADD: Vector3 com x, y, z — substitui Vector2 para preparar terreno 3D
// - ADD: cross (2D) mantido para compatibilidade com intersection.dart
// - ADD: operadores +, -, *, /, dot, length, lengthSquared, normalize, distanceTo
// - ADD: equalsApprox com tolerância configurável

import 'dart:math';

final class Vector3 {
  final double x;
  final double y;
  final double z;

  const Vector3(this.x, this.y, [this.z = 0.0]);

  static const Vector3 zero = Vector3(0, 0, 0);
  static const double EPS = 1e-6;

  Vector3 operator +(Vector3 o) => Vector3(x + o.x, y + o.y, z + o.z);
  Vector3 operator -(Vector3 o) => Vector3(x - o.x, y - o.y, z - o.z);
  Vector3 operator *(double s) => Vector3(x * s, y * s, z * s);
  Vector3 operator /(double s) => Vector3(x / s, y / s, z / s);

  double dot(Vector3 o) => x * o.x + y * o.y + z * o.z;

  /// Cross product 2D (x, y apenas). Mantido para operações de geometria plana.
  double cross(Vector3 o) => x * o.y - y * o.x;

  double get length => sqrt(x * x + y * y + z * z);

  double get lengthSquared => x * x + y * y + z * z;

  Vector3 normalize({double eps = EPS}) {
    final len = length;
    if (len < eps) return Vector3.zero;
    return Vector3(x / len, y / len, z / len);
  }

  double distanceTo(Vector3 o) => (this - o).length;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Vector3 &&
          (x - other.x).abs() < EPS &&
          (y - other.y).abs() < EPS &&
          (z - other.z).abs() < EPS;

  @override
  int get hashCode => Object.hash(x, y, z);

  bool equalsApprox(Vector3 o, {double eps = EPS}) =>
      (x - o.x).abs() < eps &&
      (y - o.y).abs() < eps &&
      (z - o.z).abs() < eps;

  @override
  String toString() => 'Vector3($x, $y, $z)';
}