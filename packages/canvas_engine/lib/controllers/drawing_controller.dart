// REV: 1.0.0
// CHANGELOG:
// - ADD: DrawingController extraído de InputController
// - Gerencia snap, extraPoints, preview e criação de entidades durante o desenho

import 'package:canvas_engine/canvas_engine.dart';

class DrawingController {
  final CadDocument document;
  final Viewport viewport;
  final SnapService snapService;
  final UndoManager undoManager;
  final CursorState cursor;

  late DrawingTool tool;
  Shape? _lastRecordedShape;

  DrawingController({
    required this.document,
    required this.viewport,
    required this.snapService,
    required this.undoManager,
    required this.cursor,
    required this.tool,
  });

  List<Vector3>? _getExtraPoints() {
    if (tool is DrawPlineController) {
      return (tool as DrawPlineController).vertices;
    }
    return null;
  }

  void onPointerDown(Vector3 screenPoint) {
    final world = viewport.screenToWorld(screenPoint);
    final snap = snapService.snap(
      mousePoint: world,
      zoom: viewport.scale,
      sceneShapes: document.allShapes,
      extraPoints: _getExtraPoints(),
    );
    cursor.update(screenPoint, snap.position, snap.type);
    final bool wasActive = tool.isActive;
    tool.onTap(snap.position, document);
    if (wasActive && !tool.isActive) {
      _recordShapeCreation();
    }
  }

  void onPointerMove(Vector3 screenPoint) {
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

  void onHover(Vector3 screenPoint) {
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

  void finishTool() {
    if (tool.isActive) {
      tool.finish();
      _recordShapeCreation();
      cursor.clear();
    }
  }

  void undoDrawing() {
    if (!tool.isActive) return;

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

  void setTool(DrawingTool newTool) {
    tool = newTool;
    tool.reset();
    cursor.clear();
  }

  void _recordShapeCreation() {
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
}