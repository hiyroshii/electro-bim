// REV: 2.0.0
// CHANGELOG:
// [2.0.0] - 02 05 2026
// - ADD: sistema de grips — hover, drag e release
// - ADD: ghost grips (midpoints de segmentos) para Add Vertex
// - ADD: snap durante drag exclui a própria entidade
// - ADD: hoveredGripIndex, draggedGripIndex expostos
// - ADD: UndoManager integrado para grips
// - ADD: MoveGripCommand no release do drag
// - ADD: InsertVertexCommand no ghost grip click
// - CHG: recebe SnapService e UndoManager no construtor
//
// [1.0.0] - 02 05 2026
// - ADD: SelectToolController — lógica de seleção desacoplada
// - ADD: hitTest com tolerância adaptativa ao zoom
// - ADD: selectedShape exposto via getter
// - ADD: clearSelection()

import 'package:canvas_engine/commands/commands.dart';
import 'package:canvas_engine/controllers/undo_manager.dart';
import 'package:canvas_engine/domain/entities/line_shape.dart';
import 'package:canvas_engine/domain/entities/pline_shape.dart';
import 'package:canvas_engine/domain/entities/shape.dart';
import 'package:canvas_engine/domain/geometry/tolerance.dart';
import 'package:canvas_engine/domain/value_objects/vector3.dart';
import 'package:canvas_engine/engine/scene.dart';
import 'package:canvas_engine/services/snap/snap.dart';
import 'package:canvas_engine/viewport/viewport.dart';

/// Estado de um ghost grip (midpoint de segmento).
class GhostGrip {
  final Vector3 position;
  final int segmentIndex;
  const GhostGrip(this.position, this.segmentIndex);
}

class SelectToolController {
  final Scene scene;
  final Viewport viewport;
  final SnapService snapService;
  final UndoManager undoManager;

  Shape? _selectedShape;
  Shape? get selectedShape => _selectedShape;

  int? hoveredGripIndex;
  int? draggedGripIndex;
  Vector3? _dragStartPosition;
  Vector3? _dragCurrentPosition;

  GhostGrip? hoveredGhost;

  SelectToolController({
    required this.scene,
    required this.viewport,
    required this.snapService,
    required this.undoManager,
  });

  void onPointerDown(Vector3 worldPoint) {
    if (_selectedShape != null) {
      final grip = _hitTestGrip(worldPoint);
      if (grip != null) {
        draggedGripIndex = grip;
        _dragStartPosition = _selectedShape!.gripPoints[grip];
        _dragCurrentPosition = _dragStartPosition;
        return;
      }

      // Ghost grip: clique no midpoint insere vértice.
      // FUTURO: mesma ação disponível em menu de contexto (right-click).
      final ghost = _hitTestGhostGrip(worldPoint);
      if (ghost != null) {
        _insertVertex(ghost);
        return;
      }
    }

    _selectedShape = _hitTestShape(worldPoint);
    hoveredGripIndex = null;
    draggedGripIndex = null;
    hoveredGhost = null;
  }

  void onPointerMove(Vector3 worldPoint) {
    if (draggedGripIndex != null && _selectedShape != null) {
      final others = scene.elements.where((s) => s != _selectedShape).toList();
      final snap = snapService.snap(
        mousePoint: worldPoint,
        zoom: viewport.scale,
        sceneShapes: others,
      );
      _selectedShape!.moveGrip(draggedGripIndex!, snap.position);
      _dragCurrentPosition = snap.position;
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
    }
  }

  void clearSelection() {
    _selectedShape = null;
    hoveredGripIndex = null;
    draggedGripIndex = null;
    hoveredGhost = null;
    _dragStartPosition = null;
    _dragCurrentPosition = null;
  }

  // --- Vertex insertion ---

  void _insertVertex(GhostGrip ghost) {
    // Se for LineShape, converte para PlineShape.
    // FUTURO: ao implementar menu de contexto, manter esta conversão automática.
    if (_selectedShape is LineShape) {
      final line = _selectedShape! as LineShape;
      final newVertices = [line.start, ghost.position, line.end];
      final pline = PlineShape(newVertices);

      final index = scene.elements.indexOf(line);
      if (index >= 0) {
        scene.elements[index] = pline;
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

  // --- Hit tests ---

  Shape? _hitTestShape(Vector3 worldPoint) {
    final double tolerance = Tolerance.hitTestWorld(viewport.scale);
    for (final shape in scene.elements.reversed) {
      if (shape.hitTest(worldPoint, tolerance: tolerance)) {
        return shape;
      }
    }
    return null;
  }

  int? _hitTestGrip(Vector3 worldPoint) {
    if (_selectedShape == null) return null;
    final gripSizeWorld = 8.0 / viewport.scale;
    final grips = _selectedShape!.gripPoints;

    for (int i = 0; i < grips.length; i++) {
      if ((grips[i] - worldPoint).length < gripSizeWorld) {
        return i;
      }
    }
    return null;
  }

  /// Detecta ghost grips nos midpoints de cada segmento.
  /// FUTURO: ao implementar menu de contexto (right-click), manter
  /// esta lógica pois ghost grip continuará como atalho visual.
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
}