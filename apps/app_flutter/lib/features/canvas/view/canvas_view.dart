// REV: 2.3.0
// CHANGELOG:
// [2.3.0] - 01 05 2026
// - ADD: integração com handleKeyEvent (keyboard_shortcuts.dart)
// - ADD: CanvasToolbar com canUndo/canRedo e callbacks de undo/redo
// - ADD: _onToolSelected — mapeia ToolbarTool → InputController (mode + tool)
// - ADD: shift em onPointerDown → lasso no SelectToolController
// - ADD: lassoPoints e windowRect passados ao CanvasPainter
// - ADD: estado de seleção (hoveredGrip, draggedGrip, isMoving) no painter
// - CHG: _computeWindowRect — converte world → screen para o painter
// - DEL: toolbar e keyboard handling inline (extraídos para arquivos dedicados)
//
// [2.2.0] - 01 05 2026
// - ADD: shift detection, lassoPoints
//
// [2.1.0] - 01 05 2026
// - ADD: MouseRegion hover, Listener, Focus + Escape, toolbar Line/Pline

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:canvas_engine/canvas_engine.dart' as engine;
import '../painter/canvas_painter.dart';
import 'package:app_flutter/controllers/keyboard_shortcuts.dart';
import '/widgets/canvas_toolbar.dart';

class CanvasView extends StatefulWidget {
  const CanvasView({super.key});

  @override
  State<CanvasView> createState() => _CanvasViewState();
}

class _CanvasViewState extends State<CanvasView> {
  late engine.InputController input;
  ToolbarTool _activeTool = ToolbarTool.line;

  @override
  void initState() {
    super.initState();
    input = engine.InputController(
      viewport: engine.Viewport(),
      document: engine.CadDocument(),
      snapService: engine.SnapService.createDefault(),
      tool: engine.DrawLineController(),
    );
  }

  void _repaint() => setState(() {});

  // ---------------------------------------------------------------
  // Troca de ferramenta — sincroniza toolbar e InputController
  // ---------------------------------------------------------------

  void _onToolSelected(ToolbarTool tool) {
    setState(() {
      _activeTool = tool;
      switch (tool) {
        case ToolbarTool.select:
          input.setMode(engine.CanvasMode.select);
        case ToolbarTool.pan:
          input.setMode(engine.CanvasMode.navigate);
        case ToolbarTool.line:
          input.setMode(engine.CanvasMode.draw);
          input.setTool(engine.DrawLineController());
        case ToolbarTool.pline:
          input.setMode(engine.CanvasMode.draw);
          input.setTool(engine.DrawPlineController());
        case ToolbarTool.rectangle:
          input.setMode(engine.CanvasMode.draw);
          input.setTool(engine.DrawRectangleController());
        case ToolbarTool.circle:
          input.setMode(engine.CanvasMode.draw);
          input.setTool(engine.DrawCircleController());
      }
    });
  }

  // ---------------------------------------------------------------
  // WindowRect — world → screen para o painter
  // ---------------------------------------------------------------

  Rect? _computeWindowRect() {
    final s = input.selectController.windowStart;
    final e = input.selectController.windowEnd;
    if (s == null || e == null) return null;
    final ss = input.viewport.worldToScreen(s);
    final se = input.viewport.worldToScreen(e);
    return Rect.fromPoints(Offset(ss.x, ss.y), Offset(se.x, se.y));
  }

  // ---------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final sel = input.selectController;

    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        final handled = handleKeyEvent(
          event,
          input,
          _repaint,
          () => _onToolSelected(ToolbarTool.select),
          () => _onToolSelected(ToolbarTool.pan),
          () => _onToolSelected(ToolbarTool.rectangle),
          () => _onToolSelected(ToolbarTool.circle),
        );
        // Sync toolbar se o shortcut trocou o modo externamente
        if (handled) _syncToolbarFromMode();
        return handled ? KeyEventResult.handled : KeyEventResult.ignored;
      },
      child: Stack(
        children: [
          // --- Canvas ---
          MouseRegion(
            cursor: _cursorForMode(),
            onHover: (event) {
              input.onHover(engine.Vector3(
                event.localPosition.dx,
                event.localPosition.dy,
                0,
              ));
              _repaint();
            },
            child: Listener(
              onPointerDown: (event) {
                input.onPointerDown(
                  engine.Vector3(
                      event.localPosition.dx, event.localPosition.dy, 0),
                  ctrl: HardwareKeyboard.instance.isControlPressed,
                  shift: HardwareKeyboard.instance.isShiftPressed,
                );
                _repaint();
              },
              onPointerMove: (event) {
                input.onPointerMove(
                  engine.Vector3(
                      event.localPosition.dx, event.localPosition.dy, 0),
                  engine.Vector3(event.delta.dx, event.delta.dy, 0),
                );
                _repaint();
              },
              onPointerUp: (event) {
                input.onPointerUp(engine.Vector3(
                  event.localPosition.dx,
                  event.localPosition.dy,
                  0,
                ));
                _repaint();
              },
              onPointerSignal: (event) {
                if (event is PointerScrollEvent) {
                  input.onZoom(
                    event.scrollDelta.dy > 0 ? 0.9 : 1.1,
                    engine.Vector3(
                        event.localPosition.dx, event.localPosition.dy, 0),
                  );
                  _repaint();
                }
              },
              child: Container(
                color: const Color(0xFFF5F5F5),
                child: CustomPaint(
                  size: Size.infinite,
                  painter: CanvasPainter(
                    document: input.document,
                    viewport: input.viewport,
                    cursor: input.cursor,
                    tool: input.tool,
                    mode: input.mode,
                    selectedShape: input.selectedShape,
                    selectedShapes: input.selectedShapes,
                    hoveredGripShape: sel.hoveredGripShape,
                    hoveredGripIndex: sel.hoveredGripIndex,
                    draggedGripShape: sel.draggedGripShape,
                    isDraggingGrip: sel.draggedGripIndex != null,
                    isMovingEntity: sel.isMovingEntity,
                    windowRect: _computeWindowRect(),
                    lassoPoints: sel.isSelectingLasso
                        ? sel.lassoPoints
                        : null,
                  ),
                ),
              ),
            ),
          ),

          // --- Toolbar (esquerda) ---
          Positioned(
            top: 12,
            left: 12,
            child: CanvasToolbar(
              activeTool: _activeTool,
              onToolSelected: _onToolSelected,
              canUndo: input.undoManager.canUndo,
              canRedo: input.undoManager.canRedo,
              onUndo: () {
                input.undoManager.undo();
                _repaint();
              },
              onRedo: () {
                input.undoManager.redo();
                _repaint();
              },
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------

  /// Mantém a toolbar sincronizada quando shortcuts trocam o modo.
  void _syncToolbarFromMode() {
    final next = switch (input.mode) {
      engine.CanvasMode.select => ToolbarTool.select,
      engine.CanvasMode.navigate => ToolbarTool.pan,
      engine.CanvasMode.draw => _activeTool, // mantém a ferramenta de desenho
    };
    if (next != _activeTool) setState(() => _activeTool = next);
  }

  SystemMouseCursor _cursorForMode() => switch (input.mode) {
        engine.CanvasMode.select => SystemMouseCursors.basic,
        engine.CanvasMode.navigate => SystemMouseCursors.grab,
        engine.CanvasMode.draw => SystemMouseCursors.precise,
      };
}