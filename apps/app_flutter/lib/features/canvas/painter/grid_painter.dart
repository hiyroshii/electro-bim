// REV: 1.0.0
// CHANGELOG:
// [1.0.0] - 02 05 2026
// - ADD: GridPainter.paint() extraído de CanvasPainter (REV 1.8.0)
// - Grid visual com linhas cinza claro, espaçamento fixo de 30px de tela

import 'package:flutter/material.dart';
import 'package:canvas_engine/canvas_engine.dart' as engine;

class GridPainter {
  static void paint(Canvas canvas, Size size, engine.Viewport viewport) {
    const screenGridSize = 30.0;
    final worldGridSize = screenGridSize / viewport.scale;

    final topLeft = viewport.screenToWorld(engine.Vector3.zero);
    final bottomRight = viewport.screenToWorld(
      engine.Vector3(size.width, size.height, 0),
    );

    final startX = (topLeft.x / worldGridSize).floor() * worldGridSize;
    final endX = (bottomRight.x / worldGridSize).ceil() * worldGridSize;
    final startY = (topLeft.y / worldGridSize).floor() * worldGridSize;
    final endY = (bottomRight.y / worldGridSize).ceil() * worldGridSize;

    final paint = Paint()
      ..color = const Color(0xFFE0E0E0)
      ..strokeWidth = 0.5;

    for (double x = startX; x <= endX; x += worldGridSize) {
      final s = viewport.worldToScreen(engine.Vector3(x, startY, 0));
      final e = viewport.worldToScreen(engine.Vector3(x, endY, 0));
      canvas.drawLine(Offset(s.x, s.y), Offset(e.x, e.y), paint);
    }

    for (double y = startY; y <= endY; y += worldGridSize) {
      final s = viewport.worldToScreen(engine.Vector3(startX, y, 0));
      final e = viewport.worldToScreen(engine.Vector3(endX, y, 0));
      canvas.drawLine(Offset(s.x, s.y), Offset(e.x, e.y), paint);
    }
  }
}