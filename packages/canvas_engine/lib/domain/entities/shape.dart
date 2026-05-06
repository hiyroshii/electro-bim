// REV: 1.5.1
// CHANGELOG:
// - ADD: isClosed e ghostGripPoints para suporte a ghost grips em formas fechadas

import 'dart:ui' show Color;
import 'package:canvas_engine/canvas_engine.dart';

abstract class Shape {
  Color? get color => null;

  void draw(RenderAdapter adapter);
  bool hitTest(Vector3 point, {double tolerance = Tolerance.geometric});

  List<Vector3> get gripPoints;
  void moveGrip(int index, Vector3 newPosition);
  void insertVertex(int segmentIndex, Vector3 position);
  Vector3 get centerGrip;

  /// Indica se a forma é fechada (círculo, retângulo, polilinha fechada).
  bool get isClosed => false;

  /// Pontos usados para gerar ghost grips (padrão: mesmos de gripPoints).
  List<Vector3> get ghostGripPoints => gripPoints;
}