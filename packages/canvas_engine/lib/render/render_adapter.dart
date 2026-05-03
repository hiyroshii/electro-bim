// REV: 1.1.0
// CHANGELOG:
// [1.1.0] - 02 05 2026
// - CHG: Vector2 → Vector3 — preparação para terreno 3D (Ciclo 0)
//
// [1.0.0] - 29 04 2026
// - ADD: interface RenderAdapter com drawLine, drawRect, drawCircle
// - FIX: import absoluto (era relativo)

import 'package:canvas_engine/domain/value_objects/vector3.dart';

/// Contrato de renderização. Implementado por FlutterRenderAdapter no app.
/// canvas_engine nunca importa Flutter — apenas define a porta.
abstract class RenderAdapter {
  void drawLine(Vector3 start, Vector3 end);
  void drawRect(Vector3 origin, double width, double height);
  void drawCircle(Vector3 center, double radius);
}