// REV: 1.1.0
// CHANGELOG:
// [1.1.0] - 02 05 2026
// - CHG: Vector2 → Vector3 — preparação para terreno 3D (Ciclo 0)
//
// [1.0.0] - 01 05 2026
// - ADD: Classe Projection com cálculo de projeção ponto-segmento

import 'package:canvas_engine/domain/value_objects/vector3.dart';

class Projection {
  /// Retorna o ponto mais próximo no segmento AB em relação ao ponto P
  static Vector3 pointToSegment(
    Vector3 p,
    Vector3 a,
    Vector3 b,
  ) {
    final ap = p - a;
    final ab = b - a;

    final abLenSq = ab.lengthSquared;

    // Segmento degenerado
    if (abLenSq == 0) return a;

    final t = (ap.dot(ab) / abLenSq).clamp(0.0, 1.0);

    return a + (ab * t);
  }
}