// REV: 1.5.0
// CHANGELOG:
// - ADD: propriedade opcional color (int?) para suporte a cores individuais ou herança do layer

import 'dart:ui' show Color;
import 'package:canvas_engine/render/render_adapter.dart';
import 'package:canvas_engine/domain/value_objects/vector3.dart';
import 'package:canvas_engine/domain/geometry/tolerance.dart';

abstract class Shape {
  /// Cor opcional da entidade. Se nulo, a cor do layer será usada.
  Color? get color => null;

  void draw(RenderAdapter adapter);
  bool hitTest(Vector3 point, {double tolerance = Tolerance.geometric});

  List<Vector3> get gripPoints;
  void moveGrip(int index, Vector3 newPosition);
  void insertVertex(int segmentIndex, Vector3 position);
  Vector3 get centerGrip;
}