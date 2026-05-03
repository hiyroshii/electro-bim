// REV: 1.7.0
// CHANGELOG:
// [1.7.0] - 02 05 2026
// - ADD: desenho de grips (quadrados 8x8) na entidade selecionada
// - ADD: desenho de ghost grips (quadrados 6x6 tracejados) para Add Vertex
// - ADD: highlight diferenciado para grip em hover (laranja)
// - ADD: highlight para grip em drag (verde)
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

class CanvasPainter extends CustomPainter {
  final engine.Scene scene;
  final engine.Viewport viewport;
  final engine.CursorState cursor;
  final engine.DrawingTool tool;
  final engine.Shape? selectedShape;
  final engine.CanvasMode mode;
  final int? hoveredGripIndex;
  final bool isDraggingGrip;

  CanvasPainter({
    required this.scene,
    required this.viewport,
    required this.cursor,
    required this.tool,
    this.selectedShape,
    required this.mode,
    this.hoveredGripIndex,
    this.isDraggingGrip = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final flutterAdapter = FlutterRenderAdapter(canvas);
    final adapter = engine.ViewportRenderAdapter(flutterAdapter, viewport);

    _drawGrid(canvas, size);
    engine.CanvasEngine(adapter).render(scene);
    tool.drawPreview(adapter);

    if (selectedShape != null) {
      _drawSelectionHighlight(canvas, selectedShape!);
      _drawGrips(canvas, selectedShape!);
      if (!isDraggingGrip) {
        _drawGhostGrips(canvas, selectedShape!);
      }
    }

    _drawCursor(canvas);
  }

  // -------------------------------------------------------------------------
  // GRID
  // -------------------------------------------------------------------------
  void _drawGrid(Canvas canvas, Size size) {
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

  // -------------------------------------------------------------------------
  // CURSOR
  // -------------------------------------------------------------------------
  void _drawCursor(Canvas canvas) {
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

  // -------------------------------------------------------------------------
  // DESTAQUE DA SELEÇÃO
  // -------------------------------------------------------------------------
  void _drawSelectionHighlight(Canvas canvas, engine.Shape shape) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final highlightAdapter = _HighlightAdapter(canvas, viewport, paint);
    shape.draw(highlightAdapter);
  }

  // -------------------------------------------------------------------------
  // GRIPS
  // -------------------------------------------------------------------------
  void _drawGrips(Canvas canvas, engine.Shape shape) {
    final grips = shape.gripPoints;
    for (int i = 0; i < grips.length; i++) {
      final screen = viewport.worldToScreen(grips[i]);
      final isHovered = hoveredGripIndex == i;
      final isDragged = isDraggingGrip && isHovered;

      final color = switch ((isDragged, isHovered)) {
        (true, _) => Colors.green,
        (false, true) => Colors.orange,
        _ => Colors.blue,
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

  // -------------------------------------------------------------------------
  // GHOST GRIPS (Add Vertex)
  // -------------------------------------------------------------------------
  void _drawGhostGrips(Canvas canvas, engine.Shape shape) {
    final grips = shape.gripPoints;
    if (grips.length < 2) return;

    // Ghost grip: indicador visual de "Add Vertex" no midpoint.
    // FUTURO: ação equivalente disponível via menu de contexto.
    final paint = Paint()
      ..color = const Color(0xFF9E9E9E).withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    const size = 6.0;

    for (int i = 0; i < grips.length - 1; i++) {
      final mid = (grips[i] + grips[i + 1]) * 0.5;
      final screen = viewport.worldToScreen(mid);

      final rect = Rect.fromCenter(
        center: Offset(screen.x, screen.y),
        width: size,
        height: size,
      );

      canvas.drawRect(rect, paint);

      // Sinal de "+" no meio
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