// REV: 4.2.0
// CHANGELOG:
// [4.2.0] - 01 05 2026
// - ADD: parâmetro shift em onPointerDown — propagado ao SelectToolController
//        permite ativar lasso (Shift + drag no vazio)
//
// [4.1.0] - anterior
// - ADD: parâmetro ctrl em onPointerDown para seleção múltipla
// - CHG: deleteSelected usa select.deleteSelectedShapes()

import 'package:canvas_engine/canvas_engine.dart';

class InputController {
  final Viewport viewport;
  final CadDocument document;
  final SnapService snapService;
  final UndoManager undoManager;
  final CursorState cursor;

  CanvasMode _mode = CanvasMode.draw;
  CanvasMode get mode => _mode;

  final DrawingController drawing;
  final SelectToolController select;
  final PanToolController pan;

  Shape? get selectedShape => select.selectedShape;
  List<Shape> get selectedShapes => select.selectedShapes;

  SelectToolController get selectController => select;

  InputController._({
    required this.viewport,
    required this.document,
    required this.snapService,
    required this.undoManager,
    required this.cursor,
    required this.drawing,
    required this.select,
    required this.pan,
  });

  factory InputController({
    required Viewport viewport,
    required CadDocument document,
    required SnapService snapService,
    required DrawingTool tool,
    UndoManager? undoManager,
  }) {
    final effectiveUndo = undoManager ?? UndoManager();
    final cursor = CursorState();

    final drawing = DrawingController(
      document: document,
      viewport: viewport,
      snapService: snapService,
      undoManager: effectiveUndo,
      cursor: cursor,
      tool: tool,
    );

    final select = SelectToolController(
      document: document,
      viewport: viewport,
      snapService: snapService,
      undoManager: effectiveUndo,
    );

    final pan = PanToolController(viewport: viewport);

    return InputController._(
      viewport: viewport,
      document: document,
      snapService: snapService,
      undoManager: effectiveUndo,
      cursor: cursor,
      drawing: drawing,
      select: select,
      pan: pan,
    );
  }

  DrawingTool get tool => drawing.tool;

  void setTool(DrawingTool newTool) => drawing.setTool(newTool);

  void setMode(CanvasMode newMode) {
    if (newMode == _mode) return;
    if (_mode == CanvasMode.draw) drawing.finishTool();
    if (_mode == CanvasMode.navigate) pan.reset();
    _mode = newMode;
    if (newMode != CanvasMode.select) select.clearSelection();
  }

  // ---------------------------------------------------------------
  // Roteamento de eventos
  // ---------------------------------------------------------------

  void onPointerDown(
    Vector3 screenPoint, {
    bool ctrl = false,
    bool shift = false,   // ← novo: lasso no select
  }) {
    switch (_mode) {
      case CanvasMode.draw:
        drawing.onPointerDown(screenPoint);
      case CanvasMode.select:
        select.onPointerDown(
          viewport.screenToWorld(screenPoint),
          ctrl: ctrl,
          shift: shift,
        );
      case CanvasMode.navigate:
        pan.onPointerDown(screenPoint);
    }
  }

  void onPointerMove(Vector3 screenPoint, Vector3 screenDelta) {
    switch (_mode) {
      case CanvasMode.draw:
        drawing.onPointerMove(screenPoint);
      case CanvasMode.select:
        select.onPointerMove(viewport.screenToWorld(screenPoint));
      case CanvasMode.navigate:
        pan.onPointerMove(screenDelta);
    }
  }

  void onPointerUp(Vector3 screenPoint) {
    switch (_mode) {
      case CanvasMode.draw:
        break;
      case CanvasMode.select:
        select.onPointerUp(viewport.screenToWorld(screenPoint));
      case CanvasMode.navigate:
        pan.onPointerUp(screenPoint);
    }
  }

  void onHover(Vector3 screenPoint) {
    if (_mode == CanvasMode.draw) drawing.onHover(screenPoint);
  }

  void onZoom(double factor, Vector3 screenFocal) =>
      viewport.zoom(factor, screenFocal);

  // ---------------------------------------------------------------
  // Ações globais
  // ---------------------------------------------------------------

  void finishTool() => drawing.finishTool();
  void undoDrawing() => drawing.undoDrawing();
  void deleteSelected() => select.deleteSelectedShapes();
  void clearSelection() => select.clearSelection();
}