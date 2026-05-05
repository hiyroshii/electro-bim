// REV: 1.11.0
// CHANGELOG:
// - FIX: _HighlightAdapter agora implementa drawColor (get/set)
// - ADD: canvasPainter aplica cor do layer (ou da entidade) antes de desenhar

import 'dart:ui' show Color;
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
  final engine.CanvasMode mode;
  final int? hoveredGripIndex;
  final bool isDraggingGrip;
  final bool isMovingEntity;

  CanvasPainter({
    required this.document,
    required this.viewport,
    required this.cursor,
    required this.tool,
    this.selectedShape,
    required this.mode,
    this.hoveredGripIndex,
    this.isDraggingGrip = false,
    this.isMovingEntity = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final flutterAdapter = FlutterRenderAdapter(canvas);
    final adapter = engine.ViewportRenderAdapter(flutterAdapter, viewport);

    GridPainter.paint(canvas, size, viewport);

    // Renderiza entidades com suas respectivas cores
    final layers = document.layers.toList()
      ..sort((a, b) => a.order.compareTo(b.order));
    for (final layer in layers) {
      if (!layer.visible) continue;
      // Define a cor do layer como padrão para as entidades dessa camada
      adapter.drawColor = layer.color;
      for (final shape in layer.shapes) {
        // Se a entidade tiver cor própria, sobrescreve
        if (shape.color != null) {
          adapter.drawColor = shape.color!;
        }
        shape.draw(adapter);
      }
    }

    tool.drawPreview(adapter);

    if (selectedShape != null) {
      _drawSelectionHighlight(canvas, selectedShape!);
      GripPainter.paint(
        canvas: canvas,
        viewport: viewport,
        shape: selectedShape!,
        hoveredGripIndex: hoveredGripIndex,
        isDraggingGrip: isDraggingGrip,
        isMovingEntity: isMovingEntity,
      );
    }

    CursorPainter.paint(canvas, viewport, cursor, mode);
  }

  void _drawSelectionHighlight(Canvas canvas, engine.Shape shape) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final highlightAdapter = _HighlightAdapter(canvas, viewport, paint);
    shape.draw(highlightAdapter);
  }

  @override
  bool shouldRepaint(covariant CanvasPainter oldDelegate) => true;
}

class _HighlightAdapter implements engine.RenderAdapter {
  final Canvas _canvas;
  final engine.Viewport _viewport;
  final Paint _paint;

  _HighlightAdapter(this._canvas, this._viewport, this._paint);

  engine.Vector3 _toScreen(engine.Vector3 world) => _viewport.worldToScreen(world);

  // Implementação de drawColor (não utilizada no highlight, mas exigida pela interface)
  @override
  Color drawColor = const Color(0xFF000000);

  @override
  void drawLine(engine.Vector3 start, engine.Vector3 end) {
    final s = _toScreen(start);
    final e = _toScreen(end);
    _canvas.drawLine(Offset(s.x, s.y), Offset(e.x, e.y), _paint);
  }

  @override
  void drawRect(engine.Vector3 origin, double width, double height) {
    final s = _toScreen(origin);
    final rect = Rect.fromLTWH(s.x, s.y, width * _viewport.scale, height * _viewport.scale);
    _canvas.drawRect(rect, _paint);
  }

  @override
  void drawCircle(engine.Vector3 center, double radius) {
    final c = _toScreen(center);
    _canvas.drawCircle(Offset(c.x, c.y), radius * _viewport.scale, _paint);
  }
}