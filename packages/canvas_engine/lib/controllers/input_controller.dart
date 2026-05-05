// REV: 3.3.0
// CHANGELOG:
// [3.3.0] - 04 05 2026
// - ADD: suporte a CadDocument; usa document.allShapes para snap e document.add/remove
// - CHG: comandos agora registram layer de origem/índice
// - CHG: parâmetro scene renomeado para document (mas aceita Scene via CadDocument)
//
// ... (histórico anterior mantido)

import 'package:canvas_engine/commands/add_shape_command.dart';
import 'package:canvas_engine/commands/remove_shape_command.dart';
import 'package:canvas_engine/controllers/undo_manager.dart';
import 'package:canvas_engine/controllers/tools/tools.dart';
import 'package:canvas_engine/domain/entities/shape.dart';
import 'package:canvas_engine/domain/value_objects/vector3.dart';
import 'package:canvas_engine/domain/documents/cad_document.dart';
import 'package:canvas_engine/services/snap/snap_service.dart';
import 'package:canvas_engine/viewport/viewport.dart';
import 'package:canvas_engine/models/cursor_state.dart';
import 'package:canvas_engine/models/canvas_mode.dart';

class InputController {
  final Viewport viewport;
  final CadDocument document;
  final SnapService snapService;
  final UndoManager undoManager;

  late DrawingTool tool;
  CanvasMode _mode = CanvasMode.draw;
  CanvasMode get mode => _mode;

  final CursorState cursor = CursorState();

  final SelectToolController _selectController;
  SelectToolController get selectController => _selectController;

  final PanToolController _panController;

  Shape? get selectedShape => _selectController.selectedShape;

  Shape? _lastRecordedShape;

  InputController._({
    required this.viewport,
    required this.document,
    required this.snapService,
    required this.undoManager,
    required DrawingTool tool,
    required SelectToolController selectController,
    required PanToolController panController,
  })  : _selectController = selectController,
        _panController = panController {
    this.tool = tool;
  }

  factory InputController({
    required Viewport viewport,
    required CadDocument document,
    required SnapService snapService,
    required DrawingTool tool,
    UndoManager? undoManager,
  }) {
    final effectiveUndo = undoManager ?? UndoManager();

     final selectCtrl = SelectToolController(
      document: document,   // antes era scene: document
      viewport: viewport,
      snapService: snapService,
       undoManager: effectiveUndo,
    );

    final panCtrl = PanToolController(viewport: viewport);

    return InputController._(
      viewport: viewport,
      document: document,
      snapService: snapService,
      undoManager: effectiveUndo,
      tool: tool,
      selectController: selectCtrl,
      panController: panCtrl,
    );
  }

  void setTool(DrawingTool newTool) {
    tool = newTool;
    _clearDrawingState();
  }

  void setMode(CanvasMode newMode) {
    if (newMode == _mode) return;
    if (_mode == CanvasMode.draw) {
      tool.finish();
    }
    if (_mode == CanvasMode.navigate) {
      _panController.reset();
    }
    _mode = newMode;
    if (newMode != CanvasMode.select) {
      _selectController.clearSelection();
    }
  }

  // ---------------------------------------------------------------
  // Eventos de ponteiro
  // ---------------------------------------------------------------

  List<Vector3>? _getExtraPoints() {
    if (tool is DrawPlineController) {
      return (tool as DrawPlineController).vertices;
    }
    return null;
  }

  void onPointerDown(Vector3 screenPoint) {
    final world = viewport.screenToWorld(screenPoint);

    switch (_mode) {
      case CanvasMode.draw:
        final snap = snapService.snap(
          mousePoint: world,
          zoom: viewport.scale,
          sceneShapes: document.allShapes, // usa allShapes
          extraPoints: _getExtraPoints(),
        );
        cursor.update(screenPoint, snap.position, snap.type);
        final bool wasActive = tool.isActive;
        tool.onTap(snap.position, document); // ferramenta adiciona via document.add
        if (wasActive && !tool.isActive) {
          _recordShapeCreation();
        }
        break;

      case CanvasMode.select:
        _selectController.onPointerDown(world);
        break;

      case CanvasMode.navigate:
        _panController.onPointerDown(screenPoint);
        break;
    }
  }

  void onPointerMove(Vector3 screenPoint, Vector3 screenDelta) {
    final world = viewport.screenToWorld(screenPoint);

    switch (_mode) {
      case CanvasMode.draw:
        final snap = snapService.snap(
          mousePoint: world,
          zoom: viewport.scale,
          sceneShapes: document.allShapes,
          extraPoints: _getExtraPoints(),
        );
        cursor.update(screenPoint, snap.position, snap.type);
        tool.onMove(snap.position);
        break;

      case CanvasMode.select:
        _selectController.onPointerMove(world);
        break;

      case CanvasMode.navigate:
        _panController.onPointerMove(screenDelta);
        break;
    }
  }

  void onPointerUp(Vector3 screenPoint) {
    final world = viewport.screenToWorld(screenPoint);

    switch (_mode) {
      case CanvasMode.draw:
        break;
      case CanvasMode.select:
        _selectController.onPointerUp(world);
        break;
      case CanvasMode.navigate:
        _panController.onPointerUp(screenPoint);
        break;
    }
  }

  void onHover(Vector3 screenPoint) {
    if (_mode == CanvasMode.draw) {
      final world = viewport.screenToWorld(screenPoint);
      final snap = snapService.snap(
        mousePoint: world,
        zoom: viewport.scale,
        sceneShapes: document.allShapes,
        extraPoints: _getExtraPoints(),
      );
      cursor.update(screenPoint, snap.position, snap.type);
      tool.onMove(snap.position);
    }
  }

  void onZoom(double factor, Vector3 screenFocal) {
    viewport.zoom(factor, screenFocal);
  }

  // ---------------------------------------------------------------
  // Ferramentas e comandos
  // ---------------------------------------------------------------

  void finishTool() {
    if (_mode == CanvasMode.draw && tool.isActive) {
      tool.finish();
      _recordShapeCreation();
      cursor.clear();
    }
  }

  void undoDrawing() {
    if (_mode != CanvasMode.draw || !tool.isActive) return;

    if (tool is DrawPlineController) {
      (tool as DrawPlineController).undoLastPoint();
      if ((tool as DrawPlineController).pointCount == 0) {
        cursor.clear();
      }
    } else if (tool is DrawLineController) {
      (tool as DrawLineController).cancel();
      cursor.clear();
    }
  }

  void deleteSelected() {
    final shape = _selectController.selectedShape;
    if (shape == null) return;

    final layer = document.layerOf(shape);
    if (layer == null) return;
    final layerIndex = document.layers.toList().indexOf(layer);
    final shapeIndex = layer.indexOf(shape);

    final command = RemoveShapeCommand(
      document: document,
      shape: shape,
      layerIndex: layerIndex,
      shapeIndex: shapeIndex,
    );
    undoManager.execute(command);
    _selectController.clearSelection();
  }

  void clearSelection() {
    _selectController.clearSelection();
  }

  // ---------------------------------------------------------------
  // Registro de criação no histórico
  // ---------------------------------------------------------------
  void _recordShapeCreation() {
    // A última shape adicionada está na layer ativa
    if (document.activeLayer.shapes.isEmpty) return;
    final newShape = document.activeLayer.shapes.last;
    if (newShape == _lastRecordedShape) return;

    final layerIndex = document.layers.toList().indexOf(document.activeLayer);
    undoManager.execute(AddShapeCommand(
      document: document,
      shape: newShape,
      layerIndex: layerIndex,
    ));
    _lastRecordedShape = newShape;
  }

  // ---------------------------------------------------------------
  // Auxiliares
  // ---------------------------------------------------------------
  void _clearDrawingState() {
    tool.reset();
    cursor.clear();
  }
}