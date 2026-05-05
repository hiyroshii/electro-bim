// REV: 1.2.0
// CHANGELOG:
// - ADD: propriedade drawColor para configurar a cor de desenho antes de cada chamada

import 'dart:ui' show Color;
import 'package:canvas_engine/domain/value_objects/vector3.dart';

abstract class RenderAdapter {
  Color drawColor = const Color(0xFF000000); // preto padrão

  void drawLine(Vector3 start, Vector3 end);
  void drawRect(Vector3 origin, double width, double height);
  void drawCircle(Vector3 center, double radius);
}