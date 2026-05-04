// REV: 1.0.0
// CHANGELOG:
// [1.0.0] - 02 05 2026
// - ADD: CursorPainter.paint() extraído de CanvasPainter (REV 1.8.0)
// - Cursor só é desenhado no modo draw, com cor por tipo de snap

import 'package:flutter/material.dart';
import 'package:canvas_engine/canvas_engine.dart' as engine;

class CursorPainter {
  static void paint(
    Canvas canvas,
    engine.Viewport viewport,
    engine.CursorState cursor,
    engine.CanvasMode mode,
  ) {
    if (mode != engine.CanvasMode.draw) return;

    final screenPos = viewport.worldToScreen(cursor.snapped);

    final color = switch (cursor.snapType) {
      engine.SnapType.endpoint => const Color(0xFF2196F3),
      engine.SnapType.midpoint => const Color(0xFFFFC107),
      engine.SnapType.nearest => const Color(0xFF4CAF50),
      engine.SnapType.intersection => const Color(0xFFE91E63),
      _ => const Color(0xFF9E9E9E),
    };

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawCircle(Offset(screenPos.x, screenPos.y), 5, paint);
  }
}