// REV: 1.3.0
// CHANGELOG:
// [1.3.0] - 02 05 2026
// - ADD: getters start e end (aliases de a e b) para compatibilidade com providers
// - CHG: PlineSnapProvider e LineSnapProvider usam start/end em vez de a/b
//
// [1.2.0] - 02 05 2026
// - CHG: Vector2 → Vector3 — preparação para terreno 3D (Ciclo 0)
//
// [1.1.0] - 02 05 2026
// - FIX: compatibilidade com geometry_test (a/b expostos)
// - ADD: base imutável consistente

import 'package:canvas_engine/domain/value_objects/vector3.dart';

class Segment {
  final Vector3 a;
  final Vector3 b;

  const Segment(this.a, this.b);

  // Aliases para compatibilidade com providers de snap
  Vector3 get start => a;
  Vector3 get end => b;

  Vector3 get direction => b - a;

  double get length => direction.length;

  Vector3 get midpoint => a + (b - a) * 0.5;

  bool get isDegenerate => a == b;

  @override
  bool operator ==(Object other) {
    if (other is! Segment) return false;
    return (a == other.a && b == other.b) ||
        (a == other.b && b == other.a);
  }

  @override
  int get hashCode => Object.hash(a, b);
}