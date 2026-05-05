// REV: 1.2.1
// CHANGELOG:
// - FIX: adicionado getter drawColor para satisfazer a interface RenderAdapter
// - CHG: usa campo privado _drawColor para armazenar o valor

import 'dart:ui' show Color;
import 'package:flutter/material.dart';
import 'package:canvas_engine/canvas_engine.dart' as engine;

class FlutterRenderAdapter implements engine.RenderAdapter {
  final Canvas _canvas;

  Color _drawColor = const Color(0xFF000000);

  final Paint _linePaint = Paint()
    ..strokeWidth = 1.5
    ..style = PaintingStyle.stroke;

  final Paint _circlePaint = Paint()
    ..strokeWidth = 1.0
    ..style = PaintingStyle.stroke;

  FlutterRenderAdapter(this._canvas);

  @override
  Color get drawColor => _drawColor;

  @override
  set drawColor(Color value) {
    _drawColor = value;
    _linePaint.color = value;
    _circlePaint.color = value;
  }

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