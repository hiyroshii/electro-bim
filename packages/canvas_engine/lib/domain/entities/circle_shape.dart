// REV: 1.0.2
// CHANGELOG:
// - FIX: ghostGripPoints vazio (evita ghost grips internos em formas curvas)
// - CHORE: removidos imports não utilizados (dart:math, dart:ui)

import 'package:canvas_engine/canvas_engine.dart';

class CircleShape extends Shape {
  Vector3 center;
  double radius;

  CircleShape(this.center, this.radius) : assert(radius > 0);

  @override
  bool get isClosed => true;

  /// Não há segmentos retos → ghost grips não se aplicam.
  @override
  List<Vector3> get ghostGripPoints => const [];

  @override
  void draw(RenderAdapter adapter) {
    adapter.drawCircle(center, radius);
  }

  @override
  bool hitTest(Vector3 point, {double tolerance = Tolerance.geometric}) {
    final dist = (point - center).length;
    return (dist - radius).abs() < tolerance;
  }

  @override
  List<Vector3> get gripPoints => [
        center,
        Vector3(center.x + radius, center.y, 0),
        Vector3(center.x, center.y + radius, 0),
        Vector3(center.x - radius, center.y, 0),
        Vector3(center.x, center.y - radius, 0),
      ];

  @override
  void moveGrip(int index, Vector3 newPosition) {
    if (index == 0) {
      center = newPosition;
    } else {
      radius = (newPosition - center).length;
    }
  }

  @override
  Vector3 get centerGrip => center;

  @override
  void insertVertex(int segmentIndex, Vector3 position) {}
}