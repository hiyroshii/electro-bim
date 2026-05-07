// REV: 3.9.0
// CHANGELOG:
// - ADD: suporte a ferramentas Rectangle e Circle
// - CHG: atalhos de teclado R e C adicionados via keyboard_shortcuts

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:canvas_engine/canvas_engine.dart' as engine;
import '/widgets/canvas_toolbar.dart';
import '../painter/canvas_painter.dart';
import '/widgets/layer_panel.dart';
import 'package:app_flutter/controllers/keyboard_shortcuts.dart';

class CanvasView extends StatefulWidget {
  const CanvasView({super.key});
  @override
  State<CanvasView> createState() => _CanvasViewState();
}

class _CanvasViewState extends State<CanvasView> {
  late engine.CadDocument document;
  late engine.Viewport viewport;
  late engine.InputController input;
  late engine.SnapService snapService;
  late engine.UndoManager _undoManager;

  ToolbarTool _activeTool = ToolbarTool.line;

  bool _isMiddlePanning = false;
  Offset _lastMiddlePosition = Offset.zero;

  Timer? _nudgeTimer;
  double _nudgeSpeed = 1.0;

  @override
  void initState() {
    super.initState();
    document = engine.CadDocument();
    viewport = engine.Viewport();
    snapService = engine.SnapService.createDefault();
    _undoManager = engine.UndoManager();

    input = engine.InputController(
      viewport: viewport,
      document: document,
      snapService: snapService,
      tool: engine.DrawLineController(),
      undoManager: _undoManager,
    );
    _undoManager.addListener(_repaint);
  }

  @override
  void dispose() {
    _stopNudge();
    _undoManager.removeListener(_repaint);
    super.dispose();
  }

  void _repaint() => setState(() {});

  void _setTool(ToolbarTool tool) {
    setState(() {
      _activeTool = tool;
      switch (tool) {
        case ToolbarTool.line:
          input.setTool(engine.DrawLineController());
          input.setMode(engine.CanvasMode.draw);
          break;
        case ToolbarTool.pline:
          input.setTool(engine.DrawPlineController());
          input.setMode(engine.CanvasMode.draw);
          break;
        case ToolbarTool.rectangle:
          input.setTool(engine.DrawRectangleController());
          input.setMode(engine.CanvasMode.draw);
          break;
        case ToolbarTool.circle:
          input.setTool(engine.DrawCircleController());
          input.setMode(engine.CanvasMode.draw);
          break;
        case ToolbarTool.select:
          input.setMode(engine.CanvasMode.select);
          break;
        case ToolbarTool.pan:
          input.setMode(engine.CanvasMode.navigate);
          break;
      }
    });
  }

  void _startNudge(double dxScreen, double dyScreen) {
    _nudgeSpeed = 1.0;
    _nudgeTimer?.cancel();
    input.selectController.nudge(dxScreen, dyScreen);
    _repaint();

    _nudgeTimer = Timer.periodic(const Duration(milliseconds: 80), (timer) {
      input.selectController.nudge(dxScreen * _nudgeSpeed, dyScreen * _nudgeSpeed);
      _repaint();
      _nudgeSpeed = (_nudgeSpeed * 1.2).clamp(1.0, 30.0);
    });
  }

  void _stopNudge() {
    _nudgeTimer?.cancel();
    _nudgeTimer = null;
  }

  SystemMouseCursor get _mouseCursor => switch (_activeTool) {
        ToolbarTool.pan => SystemMouseCursors.move,
        ToolbarTool.select => SystemMouseCursors.basic,
        _ => SystemMouseCursors.precise, // todas as ferramentas de desenho
      };

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (handleKeyEvent(
          event,
          input,
          _repaint,
          () => _setTool(ToolbarTool.select),
          () => _setTool(ToolbarTool.pan),
          () => _setTool(ToolbarTool.rectangle),
          () => _setTool(ToolbarTool.circle),
        )) {
          return KeyEventResult.handled;
        }

        if (event is KeyDownEvent) {
          switch (event.logicalKey) {
            case LogicalKeyboardKey.arrowUp:
              _startNudge(0, -1);
              return KeyEventResult.handled;
            case LogicalKeyboardKey.arrowDown:
              _startNudge(0, 1);
              return KeyEventResult.handled;
            case LogicalKeyboardKey.arrowLeft:
              _startNudge(-1, 0);
              return KeyEventResult.handled;
            case LogicalKeyboardKey.arrowRight:
              _startNudge(1, 0);
              return KeyEventResult.handled;
            default:
              break;
          }
        } else if (event is KeyUpEvent) {
          switch (event.logicalKey) {
            case LogicalKeyboardKey.arrowUp:
            case LogicalKeyboardKey.arrowDown:
            case LogicalKeyboardKey.arrowLeft:
            case LogicalKeyboardKey.arrowRight:
              _stopNudge();
              return KeyEventResult.handled;
            default:
              break;
          }
        }

        return KeyEventResult.ignored;
      },
      child: Row(
        children: [
          // Painel de Layers
          LayerPanel(
            document: document,
            onChanged: _repaint,
          ),

          // Canvas
          Expanded(
            child: Stack(
              children: [
                MouseRegion(
                  cursor: _mouseCursor,
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
                      if (event.buttons == 4) {
                        _isMiddlePanning = true;
                        _lastMiddlePosition = event.localPosition;
                        return;
                      }
                      if (event.buttons == 2) return;
                      if (event.buttons == 1) {
                        input.onPointerDown(engine.Vector3(
                          event.localPosition.dx,
                          event.localPosition.dy,
                          0,
                        ));
                        _repaint();
                      }
                    },
                    onPointerMove: (event) {
                      if (_isMiddlePanning) {
                        final delta =
                            event.localPosition - _lastMiddlePosition;
                        viewport.pan(
                            engine.Vector3(delta.dx, delta.dy, 0));
                        _lastMiddlePosition = event.localPosition;
                        _repaint();
                        return;
                      }
                      input.onPointerMove(
                        engine.Vector3(
                            event.localPosition.dx, event.localPosition.dy, 0),
                        engine.Vector3(event.delta.dx, event.delta.dy, 0),
                      );
                      _repaint();
                    },
                    onPointerUp: (event) {
                      if (_isMiddlePanning) {
                        _isMiddlePanning = false;
                        return;
                      }
                      if (event.buttons == 2) return;
                      input.onPointerUp(engine.Vector3(
                        event.localPosition.dx,
                        event.localPosition.dy,
                        0,
                      ));
                      _repaint();
                    },
                    onPointerCancel: (event) {
                      if (_isMiddlePanning) _isMiddlePanning = false;
                    },
                    onPointerSignal: (event) {
                      try {
                        final delta =
                            (event as dynamic).scrollDelta as Offset;
                        input.onZoom(
                          delta.dy > 0 ? 0.9 : 1.1,
                          engine.Vector3(event.localPosition.dx,
                              event.localPosition.dy, 0),
                        );
                        _repaint();
                      } catch (_) {}
                    },
                    child: Container(
                      color: const Color(0xFFF5F5F5),
                      child: CustomPaint(
                        size: Size.infinite,
                        painter: CanvasPainter(
                          document: document,
                          viewport: viewport,
                          cursor: input.cursor,
                          tool: input.tool,
                          selectedShape: input.selectedShape,
                          mode: input.mode,
                          hoveredGripIndex:
                              input.selectController.hoveredGripIndex,
                          isDraggingGrip: input
                                  .selectController.draggedGripIndex !=
                              null,
                          isMovingEntity:
                              input.selectController.isMovingEntity,
                        ),
                      ),
                    ),
                  ),
                ),
                // Toolbar
                Positioned(
                  top: 12,
                  left: 12,
                  child: CanvasToolbar(
                    activeTool: _activeTool,
                    onToolSelected: _setTool,
                    canUndo: _undoManager.canUndo,
                    canRedo: _undoManager.canRedo,
                    onUndo: () {
                      if (input.mode == engine.CanvasMode.draw &&
                          input.tool.isActive) {
                        input.undoDrawing();
                      } else {
                        _undoManager.undo();
                      }
                      _repaint();
                    },
                    onRedo: () {
                      _undoManager.redo();
                      _repaint();
                    },
                  ),
                ),
                // Indicador de modo
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: switch (_activeTool) {
                        ToolbarTool.select => Colors.blue.shade100,
                        ToolbarTool.pan => Colors.orange.shade100,
                        _ => Colors.green.shade100,
                      },
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _activeTool.modeDisplay,
                      style: const TextStyle(
                          fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}