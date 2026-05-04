// REV: 1.9.0
// CHANGELOG:
// [1.9.0] - 02 05 2026
// - REF: extraídos GridPainter, CursorPainter e GripPainter como classes estáticas
// - CanvasPainter agora apenas orquestra sub‑painters
//
// [1.8.0] - 02 05 2026
// - ADD: desenho de centerGrip (círculo verde) para MOVE
// - ADD: parâmetro isMovingEntity para highlight durante drag
//
// [1.7.0] - 02 05 2026
// - ADD: desenho de grips (quadrados 8x8) na entidade selecionada
// - ADD: desenho de ghost grips (quadrados 6x6 tracejados) para Add Vertex
// - ADD: highlight diferenciado para grip em hover (laranja) e drag (verde)
// - FIX: cursor de snap só é desenhado no modo draw
// - ADD: parâmetros hoveredGripIndex, isDraggingGrip
//
// [1.6.0] - 02 05 2026
// - FIX: cursor de snap fantasma ao sair do modo draw
// - ADD: parâmetro mode no construtor
//
// [1.5.0] - 02 05 2026
// - ADD: destaque da entidade selecionada (stroke azul, espessura 2.0)
// - CHG: recebe selectedShape via construtor (nullable)

import 'package:flutter/material.dart';
import 'package:canvas_engine/canvas_engine.dart' as engine;
import '../../../adapters/flutter_render_adapter.dart';
import 'grid_painter.dart';
import 'cursor_painter.dart';
import 'grip_painter.dart';

class CanvasPainter extends CustomPainter {
  final engine.Scene scene;
  final engine.Viewport viewport;
  final engine.CursorState cursor;
  final engine.DrawingTool tool;
  final engine.Shape? selectedShape;
  final engine.CanvasMode mode;
  final int? hoveredGripIndex;
  final bool isDraggingGrip;
  final bool isMovingEntity;

  CanvasPainter({
    required this.scene,
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

    engine.CanvasEngine(adapter).render(scene);
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