// REV: 1.0.2
// CHANGELOG:
// [1.0.2] - 01 05 2026
// - ADD: gripColor — cor base dos grips de vértice (default Colors.blue)
//        permite diferenciar grips de shapes primárias vs secundárias
//        chamadores existentes sem o parâmetro continuam funcionando
//
// [1.0.1] - anterior
// - FIX: ghost grips usam ghostGripPoints e isClosed

import 'package:flutter/material.dart';
import 'package:canvas_engine/canvas_engine.dart' as engine;

class GripPainter {
  static void paint({
    required Canvas canvas,
    required engine.Viewport viewport,
    required engine.Shape shape,
    int? hoveredGripIndex,
    bool isDraggingGrip = false,
    bool isMovingEntity = false,
    Color gripColor = Colors.blue, // ← novo, default mantém comportamento atual
  }) {
    _drawCenterGrip(canvas, viewport, shape, isMovingEntity);
    _drawVertexGrips(
      canvas,
      viewport,
      shape,
      hoveredGripIndex,
      isDraggingGrip,
      gripColor,
    );
    if (!isDraggingGrip) {
      _drawGhostGrips(canvas, viewport, shape);
    }
  }

  static void _drawCenterGrip(
    Canvas canvas,
    engine.Viewport viewport,
    engine.Shape shape,
    bool isMovingEntity,
  ) {
    final center = shape.centerGrip;
    final centerScreen = viewport.worldToScreen(center);

    final fillColor = isMovingEntity ? Colors.lightGreen : Colors.green;
    final centerPaint = Paint()..color = fillColor;
    final centerBorder = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    const centerSize = 10.0;

    canvas.drawCircle(
      Offset(centerScreen.x, centerScreen.y),
      centerSize / 2,
      centerPaint,
    );
    canvas.drawCircle(
      Offset(centerScreen.x, centerScreen.y),
      centerSize / 2,
      centerBorder,
    );
  }

  static void _drawVertexGrips(
    Canvas canvas,
    engine.Viewport viewport,
    engine.Shape shape,
    int? hoveredGripIndex,
    bool isDraggingGrip,
    Color gripColor, // ← recebido do paint()
  ) {
    final grips = shape.gripPoints;
    for (int i = 0; i < grips.length; i++) {
      final screen = viewport.worldToScreen(grips[i]);
      final isHovered = hoveredGripIndex == i;
      final isDragged = isDraggingGrip && isHovered;

      final color = switch ((isDragged, isHovered)) {
        (true, _) => Colors.green,   // arrastando: verde
        (false, true) => Colors.orange, // hover: laranja
        _ => gripColor,              // padrão: cor do chamador
      };

      final paint = Paint()..color = color;
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;

      const size = 8.0;
      final rect = Rect.fromCenter(
        center: Offset(screen.x, screen.y),
        width: size,
        height: size,
      );

      canvas.drawRect(rect, paint);
      canvas.drawRect(rect, borderPaint);
    }
  }

  static void _drawGhostGrips(
    Canvas canvas,
    engine.Viewport viewport,
    engine.Shape shape,
  ) {
    final grips = shape.ghostGripPoints;
    if (grips.length < 2) return;

    final paint = Paint()
      ..color = const Color(0xFF9E9E9E).withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    const size = 6.0;

    final int count = shape.isClosed ? grips.length : grips.length - 1;

    for (int i = 0; i < count; i++) {
      final j = (i + 1) % grips.length;
      final mid = (grips[i] + grips[j]) * 0.5;
      final screen = viewport.worldToScreen(mid);

      final rect = Rect.fromCenter(
        center: Offset(screen.x, screen.y),
        width: size,
        height: size,
      );

      canvas.drawRect(rect, paint);

      final half = size / 2;
      canvas.drawLine(
        Offset(screen.x - half, screen.y),
        Offset(screen.x + half, screen.y),
        paint,
      );
      canvas.drawLine(
        Offset(screen.x, screen.y - half),
        Offset(screen.x, screen.y + half),
        paint,
      );
    }
  }
}