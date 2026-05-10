// REV: 2.2.0
// CHANGELOG:
// [2.2.0] - 01 05 2026
// - ADD: lassoPoints — renderiza polígono do lasso em verde semi-transparente
//        fill verde claro + stroke verde escuro + linha de fechamento tracejada
//
// [2.1.0] - 01 05 2026
// - CHG: grips em todas as shapes selecionadas (padrão CAD)
// - ADD: hoveredGripShape, draggedGripShape
//
// [2.0.1] - anterior
// - FIX: sintaxe, withValues(alpha:), _HighlightAdapter

import 'package:flutter/material.dart';
import 'package:canvas_engine/canvas_engine.dart' as engine;
import '../../../adapters/flutter_render_adapter.dart';
import 'grid_painter.dart';
import 'cursor_painter.dart';
import 'grip_painter.dart';

class CanvasPainter extends CustomPainter {
  final engine.CadDocument document;
  final engine.Viewport viewport;
  final engine.CursorState cursor;
  final engine.DrawingTool tool;
  final engine.Shape? selectedShape;
  final List<engine.Shape> selectedShapes;
  final engine.CanvasMode mode;
  final engine.Shape? hoveredGripShape;
  final int? hoveredGripIndex;
  final engine.Shape? draggedGripShape;
  final bool isDraggingGrip;
  final bool isMovingEntity;
  final Rect? windowRect;
  final List<engine.Vector3>? lassoPoints; // ← novo

  CanvasPainter({
    required this.document,
    required this.viewport,
    required this.cursor,
    required this.tool,
    this.selectedShape,
    this.selectedShapes = const [],
    required this.mode,
    this.hoveredGripShape,
    this.hoveredGripIndex,
    this.draggedGripShape,
    this.isDraggingGrip = false,
    this.isMovingEntity = false,
    this.windowRect,
    this.lassoPoints,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final flutterAdapter = FlutterRenderAdapter(canvas);
    final adapter = engine.ViewportRenderAdapter(flutterAdapter, viewport);

    GridPainter.paint(canvas, size, viewport);

    // Entidades por layer
    final layers = document.layers.toList()
      ..sort((a, b) => a.order.compareTo(b.order));
    for (final layer in layers) {
      if (!layer.visible) continue;
      adapter.drawColor = layer.color;
      for (final shape in layer.shapes) {
        if (shape.color != null) adapter.drawColor = shape.color!;
        shape.draw(adapter);
      }
    }

    tool.drawPreview(adapter);

    // Highlight de todas as shapes selecionadas
    if (selectedShapes.isNotEmpty) {
      final secondaryPaint = Paint()
        ..color = Colors.grey.shade400
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;

      final primaryPaint = Paint()
        ..color = Colors.blue
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;

      for (final shape in selectedShapes) {
        final isPrimary = shape == selectedShape;
        final highlightAdapter = _HighlightAdapter(
          canvas,
          viewport,
          isPrimary ? primaryPaint : secondaryPaint,
        );
        shape.draw(highlightAdapter);
      }
    }

    // Grips em todas as shapes selecionadas
    for (final shape in selectedShapes) {
      GripPainter.paint(
        canvas: canvas,
        viewport: viewport,
        shape: shape,
        hoveredGripIndex:
            shape == hoveredGripShape ? hoveredGripIndex : null,
        isDraggingGrip: shape == draggedGripShape && isDraggingGrip,
        isMovingEntity: isMovingEntity,
        gripColor:
            shape == selectedShape ? Colors.blue : Colors.cyan.shade700,
      );
    }

    // Rect de seleção
    if (windowRect != null) {
      final rectPaint = Paint()
        ..color = Colors.blue.withValues(alpha: 0.6)
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round;
      canvas.drawRect(windowRect!, rectPaint);
    }

    // Lasso
    _drawLasso(canvas);

    CursorPainter.paint(canvas, viewport, cursor, mode);
  }

  void _drawLasso(Canvas canvas) {
    final points = lassoPoints;
    if (points == null || points.length < 2) return;

    // Converte para screen
    final screenPoints = points
        .map((p) => viewport.worldToScreen(p))
        .map((p) => Offset(p.x, p.y))
        .toList();

    final path = Path()..moveTo(screenPoints.first.dx, screenPoints.first.dy);
    for (int i = 1; i < screenPoints.length; i++) {
      path.lineTo(screenPoints[i].dx, screenPoints[i].dy);
    }
    path.close();

    // Fill semi-transparente
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.green.withValues(alpha: 0.08)
        ..style = PaintingStyle.fill,
    );

    // Stroke do contorno desenhado
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.green.withValues(alpha: 0.85)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );

    // Linha de fechamento tracejada (último ponto → primeiro)
    _drawDashedLine(
      canvas,
      screenPoints.last,
      screenPoints.first,
      Paint()
        ..color = Colors.green.withValues(alpha: 0.5)
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke,
    );
  }

  void _drawDashedLine(Canvas canvas, Offset a, Offset b, Paint paint) {
    const dashLen = 6.0;
    const gapLen = 4.0;
    final dx = b.dx - a.dx;
    final dy = b.dy - a.dy;
    final length = _sqrt(dx * dx + dy * dy);
    if (length < 1) return;
    final ux = dx / length;
    final uy = dy / length;
    double walked = 0;
    bool drawing = true;
    while (walked < length) {
      final segLen = drawing ? dashLen : gapLen;
      final end = (walked + segLen).clamp(0, length);
      if (drawing) {
        canvas.drawLine(
          Offset(a.dx + ux * walked, a.dy + uy * walked),
          Offset(a.dx + ux * end, a.dy + uy * end),
          paint,
        );
      }
      walked += segLen;
      drawing = !drawing;
    }
  }

  double _sqrt(double v) {
    if (v <= 0) return 0;
    double x = v;
    for (int i = 0; i < 20; i++) { x = (x + v / x) / 2; }
    return x;
  }

  @override
  bool shouldRepaint(covariant CanvasPainter oldDelegate) => true;
}

// ---------------------------------------------------------------------------

class _HighlightAdapter implements engine.RenderAdapter {
  final Canvas _canvas;
  final engine.Viewport _viewport;
  final Paint _paint;

  _HighlightAdapter(this._canvas, this._viewport, this._paint);

  @override
  Color drawColor = const Color(0xFF000000);

  engine.Vector3 _toScreen(engine.Vector3 world) =>
      _viewport.worldToScreen(world);

  @override
  void drawLine(engine.Vector3 start, engine.Vector3 end) {
    final s = _toScreen(start);
    final e = _toScreen(end);
    _canvas.drawLine(Offset(s.x, s.y), Offset(e.x, e.y), _paint);
  }

  @override
  void drawRect(engine.Vector3 origin, double width, double height) {
    final s = _toScreen(origin);
    _canvas.drawRect(
      Rect.fromLTWH(
          s.x, s.y, width * _viewport.scale, height * _viewport.scale),
      _paint,
    );
  }

  @override
  void drawCircle(engine.Vector3 center, double radius) {
    final c = _toScreen(center);
    _canvas.drawCircle(
        Offset(c.x, c.y), radius * _viewport.scale, _paint);
  }
}