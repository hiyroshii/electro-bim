// REV: 3.5.1
// CHANGELOG:
// [3.5.1] - 02 05 2026
// - FIX: onPointerDown agora passa extraPoints para snap (igual a onHover/onPointerMove)
//        Pline em construção agora snapa corretamente no clique
//
// [3.5.0] - 02 05 2026
// - ADD: extraPoints no snap durante draw (vértices parciais da ferramenta)
// - FIX: Pline em construção agora snapa nos vértices já colocados

import 'package:canvas_engine/canvas_engine.dart';

class InputController {
  final Viewport viewport;
  final Scene scene;
  final SnapService snapService;

  DrawingTool tool;
  CanvasMode mode = CanvasMode.draw;

  CursorState cursor = CursorState();

  late final UndoManager undoManager;
  late final SelectToolController selectController;
  late final PanToolController panController;

  InputController({
    required this.viewport,
    required this.tool,
    required this.snapService,
    required this.scene,
  }) {
    undoManager = UndoManager();
    selectController = SelectToolController(
      scene: scene,
      viewport: viewport,
      snapService: snapService,
      undoManager: undoManager,
    );
    panController = PanToolController(viewport: viewport);
  }

  Shape? get selectedShape => selectController.selectedShape;

  Vector3 _toWorld(Vector3 screenPoint) => viewport.screenToWorld(screenPoint);

  SnapResult _snap(Vector3 worldPoint, {List<Vector3>? extraPoints}) => snapService.snap(
        mousePoint: worldPoint,
        zoom: viewport.scale,
        sceneShapes: scene.elements,
        extraPoints: extraPoints,
      );

  void clearSelection() => selectController.clearSelection();

  void onHover(Vector3 screenPoint) {
    if (mode != CanvasMode.draw) return;

    final world = _toWorld(screenPoint);

    final extraPoints = (tool is DrawPlineController)
        ? (tool as DrawPlineController).vertices.toList()
        : null;

    final snap = _snap(world, extraPoints: extraPoints);

    cursor.update(world, snap.position, snap.type);
    tool.onMove(snap.position);
  }

  void onPointerDown(Vector3 screenPoint) {
    final world = _toWorld(screenPoint);

    switch (mode) {
      case CanvasMode.select:
        selectController.onPointerDown(world);
        break;

      case CanvasMode.navigate:
        panController.onPointerDown(screenPoint);
        break;

      case CanvasMode.draw:
        // FIX [3.5.1]: extraPoints agora também no clique (antes só em hover/move)
        final extraPoints = (tool is DrawPlineController)
            ? (tool as DrawPlineController).vertices.toList()
            : null;

        final snap = _snap(world, extraPoints: extraPoints);

        cursor.update(world, snap.position, snap.type);
        tool.onTap(snap.position, scene);
        break;
    }
  }

  void onPointerMove(Vector3 screenPoint, Vector3 delta) {
    switch (mode) {
      case CanvasMode.navigate:
        panController.onPointerMove(delta);
        break;

      case CanvasMode.select:
        selectController.onPointerMove(_toWorld(screenPoint));
        break;

      case CanvasMode.draw:
        final world = _toWorld(screenPoint);

        final extraPoints = (tool is DrawPlineController)
            ? (tool as DrawPlineController).vertices.toList()
            : null;

        final snap = _snap(world, extraPoints: extraPoints);

        cursor.update(world, snap.position, snap.type);
        tool.onMove(snap.position);
        break;
    }
  }

  void onPointerUp(Vector3 screenPoint) {
    final world = _toWorld(screenPoint);

    switch (mode) {
      case CanvasMode.navigate:
        panController.onPointerUp(screenPoint);
        break;

      case CanvasMode.select:
        selectController.onPointerUp(world);
        break;

      case CanvasMode.draw:
        break;
    }
  }

  void onZoom(double factor, Vector3 screenPoint) {
    viewport.zoom(factor, screenPoint);
  }

  void finishTool() => tool.finish();

  void setTool(DrawingTool newTool) {
    tool.reset();
    tool = newTool;
  }

  void setMode(CanvasMode newMode) {
    if (mode == CanvasMode.draw) {
      tool.finish();
    }

    if (mode == CanvasMode.navigate) {
      panController.reset();
    }

    if (mode == CanvasMode.select && newMode != CanvasMode.select) {
      selectController.clearSelection();
    }

    mode = newMode;
    tool.reset();
  }
}