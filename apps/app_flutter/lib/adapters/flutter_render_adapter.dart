// REV: 1.1.0
// CHANGELOG:
// [1.1.0] - 02 05 2026
// - CHG: Vector2 → Vector3 — preparação para terreno 3D (Ciclo 0)
//
// [1.0.0] - 29 04 2026
// - ADD: FlutterRenderAdapter — implementa RenderAdapter via Flutter Canvas

import 'package:flutter/material.dart';
import 'package:canvas_engine/canvas_engine.dart' as engine;

class FlutterRenderAdapter implements engine.RenderAdapter {
  final Canvas _canvas;

  final Paint _linePaint = Paint()
    ..color = Colors.black
    ..strokeWidth = 1.5
    ..style = PaintingStyle.stroke;

  final Paint _circlePaint = Paint()
    ..color = Colors.blue
    ..strokeWidth = 1.0
    ..style = PaintingStyle.stroke;

  FlutterRenderAdapter(this._canvas);

  @override
  void drawLine(engine.Vector3 start, engine.Vector3 end) {
    _canvas.drawLine(
      Offset(start.x, start.y),
      Offset(end.x, end.y),
      _linePaint,
    );
  }

  @override
  void drawRect(engine.Vector3 origin, double width, double height) {
    _canvas.drawRect(
      Rect.fromLTWH(origin.x, origin.y, width, height),
      _linePaint,
    );
  }

  @override
  void drawCircle(engine.Vector3 center, double radius) {
    _canvas.drawCircle(
      Offset(center.x, center.y),
      radius,
      _circlePaint,
    );
  }
}