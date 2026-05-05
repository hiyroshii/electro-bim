// REV: 2.2.0
// CHANGELOG:
// [2.2.0] - 04 05 2026
// - CHG: aceita CadDocument em vez de Scene; usa document.allShapes para snap/hit test
// - FIX: comandos de move/stretch agora registram layer de origem
//
// ... (histórico anterior mantido)

import 'package:canvas_engine/commands/commands.dart';
import 'package:canvas_engine/controllers/undo_manager.dart';
import 'package:canvas_engine/domain/entities/line_shape.dart';
import 'package:canvas_engine/domain/entities/pline_shape.dart';
import 'package:canvas_engine/domain/entities/shape.dart';
import 'package:canvas_engine/domain/geometry/tolerance.dart';
import 'package:canvas_engine/domain/value_objects/vector3.dart';
import 'package:canvas_engine/domain/documents/cad_document.dart'; // NOVO
import 'package:canvas_engine/services/snap/snap.dart';
import 'package:canvas_engine/viewport/viewport.dart';

class GhostGrip {
  final Vector3 position;
  final int segmentIndex;
  const GhostGrip(this.position, this.segmentIndex);
}

class SelectToolController {
  final CadDocument document; // Alterado de Scene para CadDocument
  final Viewport viewport;
  final SnapService snapService;
  final UndoManager undoManager;

  Shape? _selectedShape;
  Shape? get selectedShape => _selectedShape;

  // --- Grip interaction state ---
  int? hoveredGripIndex;
  int? draggedGripIndex;
  Vector3? _dragStartPosition;
  Vector3? _dragCurrentPosition;

  GhostGrip? hoveredGhost;

  // --- Move entity state ---
  bool isMovingEntity = false;
  List<Vector3>? _moveStartGrips;
  Vector3? _moveDelta;
  Vector3? _moveClickStart;

  SelectToolController({
    required this.document,
    required this.viewport,
    required this.snapService,
    required this.undoManager,
  });

  void onPointerDown(Vector3 worldPoint) {
    if (_selectedShape != null) {
      // 1. grip de vértice
      final grip = _hitTestGrip(worldPoint);
      if (grip != null) {
        draggedGripIndex = grip;
        _dragStartPosition = _selectedShape!.gripPoints[grip];
        _dragCurrentPosition = _dragStartPosition;
        return;
      }

      // 2. grip central
      if (_hitTestCenterGrip(worldPoint)) {
        _startMoveEntity(worldPoint);
        return;
      }

      // 3. ghost grip (insere vértice)
      final ghost = _hitTestGhostGrip(worldPoint);
      if (ghost != null) {
        _insertVertex(ghost);
        return;
      }

      // 4. corpo da entidade (move híbrido)
      final double tolerance = Tolerance.hitTestWorld(viewport.scale);
      if (_selectedShape!.hitTest(worldPoint, tolerance: tolerance)) {
        _startMoveEntity(worldPoint);
        return;
      }
    }

    _selectedShape = _hitTestShape(worldPoint);
    _clearInteractionState();
  }

  void onPointerMove(Vector3 worldPoint) {
    if (draggedGripIndex != null && _selectedShape != null) {
      final others = document.allShapes.where((s) => s != _selectedShape).toList();
      final snap = snapService.snap(
        mousePoint: worldPoint,
        zoom: viewport.scale,
        sceneShapes: others,
      );
      _selectedShape!.moveGrip(draggedGripIndex!, snap.position);
      _dragCurrentPosition = snap.position;
      return;
    }

    if (isMovingEntity && _selectedShape != null && _moveStartGrips != null && _moveClickStart != null) {
      final others = document.allShapes.where((s) => s != _selectedShape).toList();
      final snap = snapService.snap(
        mousePoint: worldPoint,
        zoom: viewport.scale,
        sceneShapes: others,
      );

      _moveDelta = snap.position - _moveClickStart!;

      for (int i = 0; i < _moveStartGrips!.length; i++) {
        final original = _moveStartGrips![i];
        _selectedShape!.moveGrip(i, Vector3(
          original.x + _moveDelta!.x,
          original.y + _moveDelta!.y,
          0,
        ));
      }
      return;
    }

    if (_selectedShape != null) {
      hoveredGripIndex = _hitTestGrip(worldPoint);
      if (hoveredGripIndex == null) {
        hoveredGhost = _hitTestGhostGrip(worldPoint);
      } else {
        hoveredGhost = null;
      }
    }
  }

  void onPointerUp(Vector3 worldPoint) {
    if (draggedGripIndex != null && _selectedShape != null) {
      final from = _dragStartPosition!;
      final to = _dragCurrentPosition!;
      if ((from - to).length > 1e-9) {
        undoManager.execute(MoveGripCommand(
          shape: _selectedShape!,
          gripIndex: draggedGripIndex!,
          from: from,
          to: to,
        ));
      }
      draggedGripIndex = null;
      _dragStartPosition = null;
      _dragCurrentPosition = null;
      return;
    }

    if (isMovingEntity && _selectedShape != null && _moveDelta != null) {
      final delta = _moveDelta!;
      if (delta.length > 1e-9) {
        undoManager.execute(MoveEntityCommand(
          shape: _selectedShape!,
          delta: delta,
        ));
      }
      isMovingEntity = false;
      _moveStartGrips = null;
      _moveDelta = null;
      _moveClickStart = null;
      return;
    }
  }

  void nudge(double dxScreen, double dyScreen) {
    if (_selectedShape == null) return;
    final deltaWorld = Vector3(
      dxScreen / viewport.scale,
      dyScreen / viewport.scale,
      0,
    );
    undoManager.execute(MoveEntityCommand(
      shape: _selectedShape!,
      delta: deltaWorld,
    ));
  }

  void clearSelection() {
    _selectedShape = null;
    _clearInteractionState();
  }

  // --- Private methods ---

  void _startMoveEntity(Vector3 clickWorld) {
    isMovingEntity = true;
    _moveStartGrips = _selectedShape!.gripPoints
        .map((v) => Vector3(v.x, v.y, 0))
        .toList();
    _moveClickStart = clickWorld;
    _moveDelta = Vector3.zero;
  }

  void _insertVertex(GhostGrip ghost) {
    if (_selectedShape is LineShape) {
      final line = _selectedShape! as LineShape;
      final newVertices = [line.start, ghost.position, line.end];
      final pline = PlineShape(newVertices);

      // Remove a LineShape e insere PlineShape no mesmo layer
      final layer = document.layerOf(line);
      if (layer != null) {
        final index = layer.indexOf(line);
        layer.remove(line);
        layer.insert(index, pline);
        _selectedShape = pline;
        undoManager.execute(InsertVertexCommand(
          shape: pline,
          insertIndex: 1,
          position: ghost.position,
        ));
      }
      return;
    }
    if (_selectedShape is PlineShape) {
      final pline = _selectedShape! as PlineShape;
      final insertIndex = ghost.segmentIndex + 1;
      undoManager.execute(InsertVertexCommand(
        shape: pline,
        insertIndex: insertIndex,
        position: ghost.position,
      ));
    }
  }

  Shape? _hitTestShape(Vector3 worldPoint) {
    final double tolerance = Tolerance.hitTestWorld(viewport.scale);
    // Itera sobre shapes visíveis e desbloqueadas
    for (final shape in document.allShapes.reversed) {
      if (shape.hitTest(worldPoint, tolerance: tolerance)) return shape;
    }
    return null;
  }

  int? _hitTestGrip(Vector3 worldPoint) {
    if (_selectedShape == null) return null;
    final gripSizeWorld = 8.0 / viewport.scale;
    final grips = _selectedShape!.gripPoints;
    for (int i = 0; i < grips.length; i++) {
      if ((grips[i] - worldPoint).length < gripSizeWorld) return i;
    }
    return null;
  }

  bool _hitTestCenterGrip(Vector3 worldPoint) {
    if (_selectedShape == null) return false;
    final center = _selectedShape!.centerGrip;
    final sizeWorld = 10.0 / viewport.scale;
    return (center - worldPoint).length < sizeWorld;
  }

  GhostGrip? _hitTestGhostGrip(Vector3 worldPoint) {
    if (_selectedShape == null) return null;
    final grips = _selectedShape!.gripPoints;
    if (grips.length < 2) return null;
    final ghostSizeWorld = 6.0 / viewport.scale;
    for (int i = 0; i < grips.length - 1; i++) {
      final mid = (grips[i] + grips[i + 1]) * 0.5;
      if ((mid - worldPoint).length < ghostSizeWorld) {
        return GhostGrip(mid, i);
      }
    }
    return null;
  }

  void _clearInteractionState() {
    hoveredGripIndex = null;
    draggedGripIndex = null;
    hoveredGhost = null;
    _dragStartPosition = null;
    _dragCurrentPosition = null;
    isMovingEntity = false;
    _moveStartGrips = null;
    _moveDelta = null;
    _moveClickStart = null;
  }
}