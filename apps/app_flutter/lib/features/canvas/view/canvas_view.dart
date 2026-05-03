// REV: 3.4.0
// CHANGELOG:
// [3.4.0] - 02 05 2026
// - ADD: UndoManager integrado (Ctrl+Z / Ctrl+Y)
// - ADD: botões Undo/Redo na toolbar
// - ADD: canUndo / canRedo reativos via UndoManager (ChangeNotifier)
// - CHG: CanvasToolbar recebe callbacks de undo/redo
// - CHG: DrawingTool (ex-Tool) usado no InputController
//
// [3.3.3] - 02 05 2026
// - FIX: cursor de snap fantasma ao sair do modo draw
//        (CanvasPainter agora recebe mode e só desenha cursor em draw)
//
// [3.3.2] - 02 05 2026
// - FIX: botão direito (right-click) não dispara mais desenho/seleção/pan
//        agora é ignorado e reservado para futuro menu de contexto
//
// [3.3.1] - 02 05 2026
// - CHG: cores dos botões da toolbar ajustadas para tema escuro (white70)
// - FIX: seleção limpa automaticamente ao trocar de ferramenta
//
// [3.3.0] - 02 05 2026
// - ADD: CanvasToolbar desacoplado com Pan e Select
// - ADD: middle-click pan global (sempre disponível, independente da ferramenta)
// - ADD: onPointerUp delegado ao InputController
// - ADD: cursor do mouse muda conforme a ferramenta ativa
// - CHG: FAB removido (funcionalidade migrada para a toolbar)
// - CHG: indicador de modo usa ToolbarTool.modeDisplay
// - CHG: tecla 'N' ativa Pan, tecla 'V' ativa Select
//
// [3.2.0] - 02 05 2026
// - ADD: modo select com tecla 'V' para alternar entre draw e select
// - ADD: indicador visual de modo no canto superior direito
// - ADD: FAB alterna entre draw/select (ícone muda)
// - ADD: Escape no modo select limpa seleção
// - ADD: CanvasPainter recebe selectedShape para destaque
// - CHG: utiliza InputController.setMode() e clearSelection()
//
// [3.1.0] - 02 05 2026
// - FIX: SnapService.createDefault() integrado corretamente
// - FIX: _ToolBar restaurado no escopo do arquivo
//
// [3.0.0] - 02 05 2026
// - ADD: InputController integrado
// - ADD: Scene, Viewport e SnapService no initState
// - ADD: CustomPaint com CanvasPainter

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:canvas_engine/canvas_engine.dart' as engine;
import '/widgets/canvas_toolbar.dart';
import '../painter/canvas_painter.dart';

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

  ToolbarTool _activeTool = ToolbarTool.line;

  // --- Middle-click pan global (independente da ferramenta ativa) ---
  bool _isMiddlePanning = false;
  Offset _lastMiddlePosition = Offset.zero;

  @override
  void initState() {
    super.initState();

    scene = engine.Scene();
    viewport = engine.Viewport();
    snapService = engine.SnapService.createDefault();

    input = engine.InputController(
      viewport: viewport,
      scene: scene,
      snapService: snapService,
      tool: engine.DrawLineController(),
    );

    // Repaint quando undo/redo muda de estado (botões habilitados/desabilitados)
    input.undoManager.addListener(_repaint);
  }

  @override
  void dispose() {
    input.undoManager.removeListener(_repaint);
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

  SystemMouseCursor get _mouseCursor {
    return switch (_activeTool) {
      ToolbarTool.pan => SystemMouseCursors.move,
      ToolbarTool.select => SystemMouseCursors.basic,
      ToolbarTool.line || ToolbarTool.pline => SystemMouseCursors.precise,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          // Undo / Redo
          if (event.logicalKey == LogicalKeyboardKey.keyZ &&
              (HardwareKeyboard.instance.isControlPressed ||
               HardwareKeyboard.instance.isMetaPressed)) {
            input.undoManager.undo();
            _repaint();
            return KeyEventResult.handled;
          }
          if (event.logicalKey == LogicalKeyboardKey.keyY &&
              (HardwareKeyboard.instance.isControlPressed ||
               HardwareKeyboard.instance.isMetaPressed)) {
            input.undoManager.redo();
            _repaint();
            return KeyEventResult.handled;
          }

          // Escape
          if (event.logicalKey == LogicalKeyboardKey.escape) {
            if (input.mode == engine.CanvasMode.select ||
                input.mode == engine.CanvasMode.navigate) {
              input.clearSelection();
              _repaint();
              return KeyEventResult.handled;
            } else {
              input.finishTool();
              _repaint();
              return KeyEventResult.handled;
            }
          }

          // Atalhos rápidos
          if (event.logicalKey == LogicalKeyboardKey.keyV) {
            _setTool(ToolbarTool.select);
            return KeyEventResult.handled;
          }
          if (event.logicalKey == LogicalKeyboardKey.keyN) {
            _setTool(ToolbarTool.pan);
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: Stack(
        children: [
          // --- Canvas ---
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
                // Middle-click: pan global imediato
                if (event.buttons == kMiddleMouseButton) {
                  _isMiddlePanning = true;
                  _lastMiddlePosition = event.localPosition;
                  return;
                }

                // Right-click: reservado para futuro menu de contexto
                if (event.buttons == kSecondaryMouseButton) {
                  return;
                }

                // Left-click: delega para a ferramenta ativa
                if (event.buttons == kPrimaryMouseButton) {
                  input.onPointerDown(engine.Vector3(
                    event.localPosition.dx,
                    event.localPosition.dy,
                    0,
                  ));
                  _repaint();
                }
              },
              onPointerMove: (event) {
                // Middle-click drag: pan direto no viewport
                if (_isMiddlePanning) {
                  final delta = event.localPosition - _lastMiddlePosition;
                  viewport.pan(engine.Vector3(delta.dx, delta.dy, 0));
                  _lastMiddlePosition = event.localPosition;
                  _repaint();
                  return;
                }

                // Hover / left-drag: delega normalmente
                input.onPointerMove(
                  engine.Vector3(
                    event.localPosition.dx,
                    event.localPosition.dy,
                    0,
                  ),
                  engine.Vector3(
                    event.delta.dx,
                    event.delta.dy,
                    0,
                  ),
                );
                _repaint();
              },
              onPointerUp: (event) {
                if (_isMiddlePanning) {
                  _isMiddlePanning = false;
                  return;
                }

                // Right-click up: reservado, não faz nada
                if (event.buttons == kSecondaryMouseButton) {
                  return;
                }

                // Left-click up: delega para a ferramenta
                input.onPointerUp(engine.Vector3(
                  event.localPosition.dx,
                  event.localPosition.dy,
                  0,
                ));
                _repaint();
              },
              onPointerCancel: (event) {
                if (_isMiddlePanning) {
                  _isMiddlePanning = false;
                }
              },
              onPointerSignal: (event) {
                if (event is PointerScrollEvent) {
                  input.onZoom(
                    event.scrollDelta.dy > 0 ? 0.9 : 1.1,
                    engine.Vector3(
                      event.localPosition.dx,
                      event.localPosition.dy,
                      0,
                    ),
                  );
                  _repaint();
                }
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
                  ),
                ),
              ),
            ),
          ),

          // --- Toolbar desacoplada ---
          Positioned(
            top: 12,
            left: 12,
            child: CanvasToolbar(
              activeTool: _activeTool,
              onToolSelected: _setTool,
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

          // --- Indicador de modo ---
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
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}