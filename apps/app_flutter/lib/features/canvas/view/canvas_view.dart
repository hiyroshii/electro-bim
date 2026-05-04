// REV: 3.7.1
// CHANGELOG:
// [3.7.1] - 04 05 2026
// - FIX: UndoManager único compartilhado entre InputController e SelectToolController
// - CHG: _undoManager criado no initState e passado ao InputController
// - CHG: listener de repaint agora vinculado ao _undoManager compartilhado
//
// [3.7.0] - 02 05 2026
// - ADD: nudge contínuo com aceleração progressiva (setas mantidas pressionadas)
// - ADD: métodos _startNudge, _stopNudge, timer e fator de velocidade
// - CHG: tratamento de setas movido para o view, removido de keyboard_shortcuts
// - FIX: compatibilidade com nova versão de SelectToolController (2.1.1)
//
// [3.6.0] - 02 05 2026
// - REF: atalhos de teclado extraídos para keyboard_shortcuts.dart
// - ADD: isMovingEntity repassado ao CanvasPainter
// - ADD: nudge com setas (↑↓←→) durante seleção
// - FIX: constantes de botão do mouse substituídas por valores numéricos
// - FIX: scrollDelta acessado via cast dinâmico (compatibilidade)
//
// [3.4.0] - 02 05 2026
// - ADD: UndoManager integrado (Ctrl+Z / Ctrl+Y)
// - ADD: botões Undo/Redo na toolbar
// - ADD: canUndo / canRedo reativos via UndoManager (ChangeNotifier)
// - CHG: CanvasToolbar recebe callbacks de undo/redo
// - CHG: DrawingTool (ex-Tool) usado no InputController
//
// [3.3.3] - 02 05 2026
// - FIX: cursor de snap fantasma ao sair do modo draw
//
// [3.3.2] - 02 05 2026
// - FIX: botão direito não dispara mais desenho/seleção/pan
//
// [3.3.1] - 02 05 2026
// - CHG: cores dos botões da toolbar para tema escuro
// - FIX: seleção limpa ao trocar de ferramenta
//
// [3.3.0] - 02 05 2026
// - ADD: CanvasToolbar desacoplado com Pan e Select
// - ADD: middle-click pan global
// - ADD: onPointerUp delegado ao InputController
// - ADD: cursor do mouse conforme ferramenta ativa
//
// [3.2.0] - 02 05 2026
// - ADD: modo select com tecla 'V'
// - ADD: indicador visual de modo
// - ADD: Escape limpa seleção
//
// [3.0.0] - 02 05 2026
// - ADD: InputController, Scene, Viewport, SnapService integrados

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:canvas_engine/canvas_engine.dart' as engine;
import '/widgets/canvas_toolbar.dart';
import '../painter/canvas_painter.dart';
import 'package:app_flutter/controllers/keyboard_shortcuts.dart';

class CanvasView extends StatefulWidget {
  const CanvasView({super.key});
  @override
  State<CanvasView> createState() => _CanvasViewState();
}

class _CanvasViewState extends State<CanvasView> {
  late engine.Scene scene;
  late engine.Viewport viewport;
  late engine.InputController input;
  late engine.SnapService snapService;
  late engine.UndoManager _undoManager; // Instância única compartilhada

  ToolbarTool _activeTool = ToolbarTool.line;

  bool _isMiddlePanning = false;
  Offset _lastMiddlePosition = Offset.zero;

  // Nudge contínuo com aceleração
  Timer? _nudgeTimer;
  double _nudgeSpeed = 1.0;

  @override
  void initState() {
    super.initState();
    scene = engine.Scene();
    viewport = engine.Viewport();
    snapService = engine.SnapService.createDefault();

    // Cria um único UndoManager e compartilha com todos os controllers
    _undoManager = engine.UndoManager();

    input = engine.InputController(
      viewport: viewport,
      scene: scene,
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
    // Aplica o primeiro nudge imediatamente
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
    ToolbarTool.line || ToolbarTool.pline => SystemMouseCursors.precise,
  };

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        // Primeiro, processa atalhos instantâneos (Ctrl+Z, etc.)
        if (handleKeyEvent(
          event,
          input,
          _repaint,
          () => _setTool(ToolbarTool.select),
          () => _setTool(ToolbarTool.pan),
        )) {
          return KeyEventResult.handled;
        }

        // Nudge contínuo (setas)
        if (event is KeyDownEvent) {
          switch (event.logicalKey) {
            case LogicalKeyboardKey.arrowUp:    _startNudge(0, -1); return KeyEventResult.handled;
            case LogicalKeyboardKey.arrowDown:  _startNudge(0, 1);  return KeyEventResult.handled;
            case LogicalKeyboardKey.arrowLeft:  _startNudge(-1, 0); return KeyEventResult.handled;
            case LogicalKeyboardKey.arrowRight: _startNudge(1, 0);  return KeyEventResult.handled;
            default: break;
          }
        } else if (event is KeyUpEvent) {
          switch (event.logicalKey) {
            case LogicalKeyboardKey.arrowUp:
            case LogicalKeyboardKey.arrowDown:
            case LogicalKeyboardKey.arrowLeft:
            case LogicalKeyboardKey.arrowRight:
              _stopNudge();
              return KeyEventResult.handled;
            default: break;
          }
        }

        return KeyEventResult.ignored;
      },
      child: Stack(
        children: [
          MouseRegion(
            cursor: _mouseCursor,
            onHover: (event) {
              input.onHover(engine.Vector3(
                event.localPosition.dx, event.localPosition.dy, 0,
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
                    event.localPosition.dx, event.localPosition.dy, 0,
                  ));
                  _repaint();
                }
              },
              onPointerMove: (event) {
                if (_isMiddlePanning) {
                  final delta = event.localPosition - _lastMiddlePosition;
                  viewport.pan(engine.Vector3(delta.dx, delta.dy, 0));
                  _lastMiddlePosition = event.localPosition;
                  _repaint();
                  return;
                }
                input.onPointerMove(
                  engine.Vector3(event.localPosition.dx, event.localPosition.dy, 0),
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
                  event.localPosition.dx, event.localPosition.dy, 0,
                ));
                _repaint();
              },
              onPointerCancel: (event) {
                if (_isMiddlePanning) _isMiddlePanning = false;
              },
              onPointerSignal: (event) {
                try {
                  final delta = (event as dynamic).scrollDelta as Offset;
                  input.onZoom(
                    delta.dy > 0 ? 0.9 : 1.1,
                    engine.Vector3(event.localPosition.dx, event.localPosition.dy, 0),
                  );
                  _repaint();
                } catch (_) {}
              },
              child: Container(
                color: const Color(0xFFF5F5F5),
                child: CustomPaint(
                  size: Size.infinite,
                  painter: CanvasPainter(
                    scene: scene,
                    viewport: viewport,
                    cursor: input.cursor,
                    tool: input.tool,
                    selectedShape: input.selectedShape,
                    mode: input.mode,
                    hoveredGripIndex: input.selectController.hoveredGripIndex,
                    isDraggingGrip: input.selectController.draggedGripIndex != null,
                    isMovingEntity: input.selectController.isMovingEntity,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 12,
            left: 12,
            child: CanvasToolbar(
              activeTool: _activeTool,
              onToolSelected: _setTool,
              canUndo: _undoManager.canUndo,
              canRedo: _undoManager.canRedo,
              onUndo: () {
                if (input.mode == engine.CanvasMode.draw && input.tool.isActive) {
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
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: switch (_activeTool) {
                  ToolbarTool.select => Colors.blue.shade100,
                  ToolbarTool.pan => Colors.orange.shade100,
                  ToolbarTool.line || ToolbarTool.pline => Colors.green.shade100,
                },
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _activeTool.modeDisplay,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}