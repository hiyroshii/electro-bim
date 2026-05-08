// REV: 3.3.0
// CHANGELOG:
// [3.3.0] - 01 05 2026
// - ADD: seleção por lasso (Shift + drag no vazio)
//        selectByLasso() com ray casting (_pointInPolygon)
//        modo window: todos os gripPoints dentro do polígono
//        _lassoPoints acumula com threshold mínimo (evita array gigante)
//        isSelectingLasso e lassoPoints expostos para o painter
// - FIX: prioridade de grips — grips testados ANTES de shapes em onPointerDown
//        impede que clique em grip selecione shape de baixo
// - FIX: stretch snap exclui apenas draggedGripShape (não todas as selecionadas)
//        permite snapar nos vértices das outras shapes selecionadas
//
// [3.2.0] - 01 05 2026
// - CHG: grips em todas as shapes selecionadas (padrão CAD)
// - ADD: draggedGripShape, hoveredGripShape
// - ADD: _hitTestGripAcrossSelection
//
// [3.1.0] - 01 05 2026
// - FIX: move múltiplas entidades — _moveStartGripsMap
//
// [3.0.1] - 01 05 2026
// - FIX: movimento/arraste com múltiplas entidades selecionadas

import 'package:canvas_engine/canvas_engine.dart';

class GhostGrip {
  final Vector3 position;
  final int segmentIndex;
  const GhostGrip(this.position, this.segmentIndex);
}

class SelectToolController {
  final CadDocument document;
  final Viewport viewport;
  final SnapService snapService;
  final UndoManager undoManager;

  // Seleção múltipla
  final List<Shape> _selectedShapes = [];
  List<Shape> get selectedShapes => List.unmodifiable(_selectedShapes);

  /// Primária: última shape adicionada à seleção.
  Shape? get selectedShape =>
      _selectedShapes.isNotEmpty ? _selectedShapes.last : null;

  // --- Grip interaction state ---
  Shape? hoveredGripShape;
  int? hoveredGripIndex;

  Shape? draggedGripShape;
  int? draggedGripIndex;
  Vector3? _dragStartPosition;
  Vector3? _dragCurrentPosition;

  GhostGrip? hoveredGhost;

  // --- Move entity state ---
  bool isMovingEntity = false;
  Map<Shape, List<Vector3>>? _moveStartGripsMap;
  Vector3? _moveDelta;
  Vector3? _moveClickStart;

  // --- Janela de seleção (rect) ---
  bool isSelectingWindow = false;
  Vector3? windowStart;
  Vector3? windowEnd;

  // --- Lasso ---
  bool isSelectingLasso = false;
  final List<Vector3> _lassoPoints = [];
  List<Vector3> get lassoPoints => List.unmodifiable(_lassoPoints);

  SelectToolController({
    required this.document,
    required this.viewport,
    required this.snapService,
    required this.undoManager,
  });

  // ---------------------------------------------------------------
  // Manipulação de seleção
  // ---------------------------------------------------------------

  void addToSelection(Shape shape) {
    if (!_selectedShapes.contains(shape)) _selectedShapes.add(shape);
    hoveredGripShape = null;
    hoveredGripIndex = null;
    draggedGripShape = null;
    draggedGripIndex = null;
    hoveredGhost = null;
  }

  void removeFromSelection(Shape shape) {
    _selectedShapes.remove(shape);
    if (_selectedShapes.isEmpty) {
      _clearInteractionState();
    } else {
      if (hoveredGripShape == shape) {
        hoveredGripShape = null;
        hoveredGripIndex = null;
      }
      if (draggedGripShape == shape) {
        draggedGripShape = null;
        draggedGripIndex = null;
        _dragStartPosition = null;
        _dragCurrentPosition = null;
      }
    }
  }

  void toggleSelection(Shape shape) {
    if (_selectedShapes.contains(shape)) {
      removeFromSelection(shape);
    } else {
      addToSelection(shape);
    }
  }

  void clearSelection() {
    _selectedShapes.clear();
    _clearInteractionState();
  }

  // ---------------------------------------------------------------
  // Seleção por janela (rect)
  // ---------------------------------------------------------------

  void selectByRect(
    Vector3 start,
    Vector3 end, {
    bool crossing = false,
    bool add = false,
  }) {
    final minX = start.x < end.x ? start.x : end.x;
    final minY = start.y < end.y ? start.y : end.y;
    final maxX = start.x > end.x ? start.x : end.x;
    final maxY = start.y > end.y ? start.y : end.y;

    final List<Shape> newSelection = [];
    for (final shape in document.allShapes) {
      final bounds = _getShapeBounds(shape);
      if (bounds == null) continue;
      if (crossing) {
        if (_rectIntersects(minX, minY, maxX, maxY, bounds)) {
          newSelection.add(shape);
        }
      } else {
        if (_rectContains(minX, minY, maxX, maxY, bounds)) {
          newSelection.add(shape);
        }
      }
    }

    if (add) {
      for (final shape in newSelection) addToSelection(shape);
    } else {
      _selectedShapes.clear();
      _selectedShapes.addAll(newSelection);
      if (_selectedShapes.isEmpty) _clearInteractionState();
    }
  }

  // ---------------------------------------------------------------
  // Seleção por lasso
  // ---------------------------------------------------------------

  /// Seleciona shapes cujos gripPoints estão todos dentro do polígono.
  /// Modo window: shape inteira precisa estar dentro do lasso.
  void selectByLasso(List<Vector3> polygon, {bool add = false}) {
    if (polygon.length < 3) return;

    final List<Shape> newSelection = [];
    for (final shape in document.allShapes) {
      if (shape.gripPoints.isEmpty) continue;
      if (shape.gripPoints.every((p) => _pointInPolygon(p, polygon))) {
        newSelection.add(shape);
      }
    }

    if (add) {
      for (final shape in newSelection) addToSelection(shape);
    } else {
      _selectedShapes.clear();
      _selectedShapes.addAll(newSelection);
      if (_selectedShapes.isEmpty) _clearInteractionState();
    }
  }

  // ---------------------------------------------------------------
  // Eventos de ponteiro
  // ---------------------------------------------------------------

  void onPointerDown(Vector3 worldPoint, {bool ctrl = false, bool shift = false}) {
    if (isSelectingWindow || isSelectingLasso) return;

    // ── PRIORIDADE 1: grips das shapes selecionadas ──────────────
    // Testados ANTES de qualquer shape — impede que o clique num grip
    // selecione acidentalmente a shape de baixo.
    if (_selectedShapes.isNotEmpty && !ctrl) {
      final gripResult = _hitTestGripAcrossSelection(worldPoint);
      if (gripResult != null) {
        final (gripShape, gripIdx) = gripResult;
        draggedGripShape = gripShape;
        draggedGripIndex = gripIdx;
        _dragStartPosition = gripShape.gripPoints[gripIdx];
        _dragCurrentPosition = _dragStartPosition;
        return;
      }

      // Center grip (primária)
      if (_hitTestCenterGrip(worldPoint)) {
        _startMoveEntity(worldPoint);
        return;
      }

      // Ghost grip (primária)
      final ghost = _hitTestGhostGrip(worldPoint);
      if (ghost != null) {
        _insertVertex(ghost);
        return;
      }
    }

    // ── PRIORIDADE 2: shapes ──────────────────────────────────────
    final hit = _hitTestShape(worldPoint);

    if (hit != null) {
      if (ctrl) {
        toggleSelection(hit);
        return;
      }

      if (_selectedShapes.contains(hit)) {
        // Corpo de qualquer shape selecionada → move todas
        final double tolerance = Tolerance.hitTestWorld(viewport.scale);
        if (hit.hitTest(worldPoint, tolerance: tolerance)) {
          _startMoveEntity(worldPoint);
        }
      } else {
        // Shape não selecionada → seleciona só essa
        _selectedShapes.clear();
        addToSelection(hit);

        final double tolerance = Tolerance.hitTestWorld(viewport.scale);
        if (hit.hitTest(worldPoint, tolerance: tolerance)) {
          _startMoveEntity(worldPoint);
        }
      }
    } else {
      // ── PRIORIDADE 3: vazio → janela ou lasso ────────────────────
      if (ctrl) return;
      clearSelection();

      if (shift) {
        // Shift + drag no vazio = lasso
        isSelectingLasso = true;
        _lassoPoints.clear();
        _lassoPoints.add(worldPoint);
      } else {
        // Drag normal no vazio = rect
        isSelectingWindow = true;
        windowStart = worldPoint;
        windowEnd = worldPoint;
      }
    }
  }

  void onPointerMove(Vector3 worldPoint) {
    // Stretch: grip de qualquer shape selecionada
    // Exclui apenas a shape sendo editada — as outras selecionadas
    // ficam disponíveis como candidatas de snap.
    if (draggedGripIndex != null && draggedGripShape != null) {
      final others = document.allShapes
          .where((s) => s != draggedGripShape)
          .toList();
      final snap = snapService.snap(
        mousePoint: worldPoint,
        zoom: viewport.scale,
        sceneShapes: others,
      );
      draggedGripShape!.moveGrip(draggedGripIndex!, snap.position);
      _dragCurrentPosition = snap.position;
      return;
    }

    // Move: todas as shapes selecionadas
    if (isMovingEntity &&
        _moveStartGripsMap != null &&
        _moveClickStart != null) {
      final others = document.allShapes
          .where((s) => !_selectedShapes.contains(s))
          .toList();
      final snap = snapService.snap(
        mousePoint: worldPoint,
        zoom: viewport.scale,
        sceneShapes: others,
      );
      _moveDelta = snap.position - _moveClickStart!;
      for (final shape in _selectedShapes) {
        final startGrips = _moveStartGripsMap![shape];
        if (startGrips == null) continue;
        for (int i = 0; i < startGrips.length; i++) {
          shape.moveGrip(i, Vector3(
            startGrips[i].x + _moveDelta!.x,
            startGrips[i].y + _moveDelta!.y,
            0,
          ));
        }
      }
      return;
    }

    // Lasso: acumula pontos com threshold mínimo
    if (isSelectingLasso) {
      final threshold = 3.0 / viewport.scale;
      if (_lassoPoints.isEmpty ||
          (_lassoPoints.last - worldPoint).length > threshold) {
        _lassoPoints.add(worldPoint);
      }
      return;
    }

    // Rect
    if (isSelectingWindow) {
      windowEnd = worldPoint;
      return;
    }

    // Hover: grip em qualquer shape selecionada
    if (_selectedShapes.isNotEmpty) {
      final gripResult = _hitTestGripAcrossSelection(worldPoint);
      if (gripResult != null) {
        final (shape, idx) = gripResult;
        hoveredGripShape = shape;
        hoveredGripIndex = idx;
        hoveredGhost = null;
      } else {
        hoveredGripShape = null;
        hoveredGripIndex = null;
        hoveredGhost = selectedShape != null
            ? _hitTestGhostGrip(worldPoint)
            : null;
      }
    }
  }

  void onPointerUp(Vector3 worldPoint) {
    // Release stretch
    if (draggedGripIndex != null && draggedGripShape != null) {
      final from = _dragStartPosition!;
      final to = _dragCurrentPosition!;
      if ((from - to).length > 1e-9) {
        undoManager.execute(MoveGripCommand(
          shape: draggedGripShape!,
          gripIndex: draggedGripIndex!,
          from: from,
          to: to,
        ));
      }
      draggedGripShape = null;
      draggedGripIndex = null;
      _dragStartPosition = null;
      _dragCurrentPosition = null;
      return;
    }

    // Release move
    if (isMovingEntity && _moveDelta != null) {
      final delta = _moveDelta!;
      if (delta.length > 1e-9) {
        for (final shape in List<Shape>.from(_selectedShapes)) {
          undoManager.execute(MoveEntityCommand(shape: shape, delta: delta));
        }
      }
      isMovingEntity = false;
      _moveStartGripsMap = null;
      _moveDelta = null;
      _moveClickStart = null;
      return;
    }

    // Finaliza lasso
    if (isSelectingLasso) {
      if (_lassoPoints.length >= 3) {
        selectByLasso(_lassoPoints);
      }
      isSelectingLasso = false;
      _lassoPoints.clear();
      return;
    }

    // Finaliza rect
    if (isSelectingWindow && windowStart != null && windowEnd != null) {
      final crossing = windowStart!.x > windowEnd!.x;
      selectByRect(windowStart!, windowEnd!, crossing: crossing, add: false);
      isSelectingWindow = false;
      windowStart = null;
      windowEnd = null;
    }
  }

  // ---------------------------------------------------------------
  // Nudge (primária)
  // ---------------------------------------------------------------

  void nudge(double dxScreen, double dyScreen) {
    final shape = selectedShape;
    if (shape == null) return;
    undoManager.execute(MoveEntityCommand(
      shape: shape,
      delta: Vector3(dxScreen / viewport.scale, dyScreen / viewport.scale, 0),
    ));
  }

  // ---------------------------------------------------------------
  // Deleção múltipla
  // ---------------------------------------------------------------

  void deleteSelectedShapes() {
    for (final shape in List<Shape>.from(_selectedShapes)) {
      final layer = document.layerOf(shape);
      if (layer == null) continue;
      final layerIndex = document.layers.toList().indexOf(layer);
      final shapeIndex = layer.indexOf(shape);
      undoManager.execute(RemoveShapeCommand(
        document: document,
        shape: shape,
        layerIndex: layerIndex,
        shapeIndex: shapeIndex,
      ));
    }
    clearSelection();
  }

  // ---------------------------------------------------------------
  // Hit tests
  // ---------------------------------------------------------------

  Shape? _hitTestShape(Vector3 worldPoint) {
    final double tolerance = Tolerance.hitTestWorld(viewport.scale);
    final allShapes = document.allShapes;
    for (int i = allShapes.length - 1; i >= 0; i--) {
      if (allShapes[i].hitTest(worldPoint, tolerance: tolerance)) {
        return allShapes[i];
      }
    }
    return null;
  }

  /// Busca grip em TODAS as shapes selecionadas.
  /// Primária tem prioridade (testada primeiro).
  (Shape, int)? _hitTestGripAcrossSelection(Vector3 worldPoint) {
    if (_selectedShapes.isEmpty) return null;
    final gripSizeWorld = 8.0 / viewport.scale;

    // Primária primeiro
    final primary = selectedShape!;
    for (int i = 0; i < primary.gripPoints.length; i++) {
      if ((primary.gripPoints[i] - worldPoint).length < gripSizeWorld) {
        return (primary, i);
      }
    }
    // Demais do topo para base
    for (int s = _selectedShapes.length - 2; s >= 0; s--) {
      final shape = _selectedShapes[s];
      for (int i = 0; i < shape.gripPoints.length; i++) {
        if ((shape.gripPoints[i] - worldPoint).length < gripSizeWorld) {
          return (shape, i);
        }
      }
    }
    return null;
  }

  bool _hitTestCenterGrip(Vector3 worldPoint) {
    if (selectedShape == null) return false;
    return (selectedShape!.centerGrip - worldPoint).length <
        10.0 / viewport.scale;
  }

  GhostGrip? _hitTestGhostGrip(Vector3 worldPoint) {
    if (selectedShape == null) return null;
    final grips = selectedShape!.ghostGripPoints;
    if (grips.length < 2) return null;
    final ghostSizeWorld = 6.0 / viewport.scale;
    final int count =
        selectedShape!.isClosed ? grips.length : grips.length - 1;
    for (int i = 0; i < count; i++) {
      final j = (i + 1) % grips.length;
      final mid = (grips[i] + grips[j]) * 0.5;
      if ((mid - worldPoint).length < ghostSizeWorld) {
        return GhostGrip(mid, i);
      }
    }
    return null;
  }

  // ---------------------------------------------------------------
  // Geometria do lasso
  // ---------------------------------------------------------------

  /// Ray casting — retorna true se [point] está dentro do [polygon].
  bool _pointInPolygon(Vector3 point, List<Vector3> polygon) {
    if (polygon.length < 3) return false;
    bool inside = false;
    int j = polygon.length - 1;
    for (int i = 0; i < polygon.length; i++) {
      final xi = polygon[i].x, yi = polygon[i].y;
      final xj = polygon[j].x, yj = polygon[j].y;
      if (((yi > point.y) != (yj > point.y)) &&
          (point.x < (xj - xi) * (point.y - yi) / (yj - yi) + xi)) {
        inside = !inside;
      }
      j = i;
    }
    return inside;
  }

  // ---------------------------------------------------------------
  // Auxiliares internos
  // ---------------------------------------------------------------

  void _startMoveEntity(Vector3 clickWorld) {
    isMovingEntity = true;
    _moveStartGripsMap = {
      for (final shape in _selectedShapes)
        shape: shape.gripPoints.map((v) => Vector3(v.x, v.y, 0)).toList(),
    };
    _moveClickStart = clickWorld;
    _moveDelta = Vector3.zero;
  }

  void _insertVertex(GhostGrip ghost) {
    if (selectedShape is LineShape) {
      final line = selectedShape! as LineShape;
      final pline = PlineShape([line.start, ghost.position, line.end]);
      final layer = document.layerOf(line);
      if (layer != null) {
        final index = layer.indexOf(line);
        layer.remove(line);
        layer.insert(index, pline);
        _selectedShapes.remove(line);
        _selectedShapes.add(pline);
        undoManager.execute(InsertVertexCommand(
          shape: pline,
          insertIndex: 1,
          position: ghost.position,
        ));
      }
      return;
    }
    if (selectedShape is PlineShape) {
      undoManager.execute(InsertVertexCommand(
        shape: selectedShape! as PlineShape,
        insertIndex: ghost.segmentIndex + 1,
        position: ghost.position,
      ));
    }
  }

  Map<String, double>? _getShapeBounds(Shape shape) {
    if (shape.gripPoints.isEmpty) return null;
    double minX = double.infinity, minY = double.infinity;
    double maxX = double.negativeInfinity, maxY = double.negativeInfinity;
    for (final p in shape.gripPoints) {
      if (p.x < minX) minX = p.x;
      if (p.x > maxX) maxX = p.x;
      if (p.y < minY) minY = p.y;
      if (p.y > maxY) maxY = p.y;
    }
    return {'minX': minX, 'minY': minY, 'maxX': maxX, 'maxY': maxY};
  }

  bool _rectContains(double rx1, double ry1, double rx2, double ry2,
      Map<String, double> bounds) {
    return bounds['minX']! >= rx1 &&
        bounds['maxX']! <= rx2 &&
        bounds['minY']! >= ry1 &&
        bounds['maxY']! <= ry2;
  }

  bool _rectIntersects(double rx1, double ry1, double rx2, double ry2,
      Map<String, double> bounds) {
    return !(bounds['minX']! > rx2 ||
        bounds['maxX']! < rx1 ||
        bounds['minY']! > ry2 ||
        bounds['maxY']! < ry1);
  }

  void _clearInteractionState() {
    hoveredGripShape = null;
    hoveredGripIndex = null;
    draggedGripShape = null;
    draggedGripIndex = null;
    hoveredGhost = null;
    _dragStartPosition = null;
    _dragCurrentPosition = null;
    isMovingEntity = false;
    _moveStartGripsMap = null;
    _moveDelta = null;
    _moveClickStart = null;
    isSelectingWindow = false;
    windowStart = null;
    windowEnd = null;
    isSelectingLasso = false;
    _lassoPoints.clear();
  }
}