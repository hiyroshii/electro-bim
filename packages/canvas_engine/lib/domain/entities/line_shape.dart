// REV: 1.4.0
// CHANGELOG:
// [1.4.0] - 02 05 2026
// - ADD: centerGrip — média de start e end
//
// [1.3.0] - 02 05 2026
// - ADD: gripPoints retorna [start, end]
// - ADD: moveGrip() atualiza start ou end
// - ADD: insertVertex() no-op (conversão para PlineShape é responsabilidade do controller)
// - ADD: nota sobre futura conversão automática via controller/menu
//
// [1.2.0] - 02 05 2026
// - CHG: Vector2 → Vector3 — preparação para terreno 3D (Ciclo 0)
//
// [1.1.0] - 29 04 2026
// - ADD: getter segment — Segment interno
// - ADD: getter bounds — AABB da linha
// - CHG: hitTest implementado via distancePointToSegment
// - FIX: imports absolutos
//
// [1.0.0] - 29 04 2026
// - ADD: LineShape com start e end
// - ADD: draw() via RenderAdapter
// - ADD: hitTest() stub

import 'package:canvas_engine/render/render_adapter.dart';
import 'package:canvas_engine/domain/value_objects/vector3.dart';
import 'package:canvas_engine/domain/entities/shape.dart';
import 'package:canvas_engine/domain/geometry/tolerance.dart';
import 'package:canvas_engine/domain/geometry/primitives/segment.dart';
import 'package:canvas_engine/domain/geometry/primitives/aabb.dart';
import 'package:canvas_engine/domain/geometry/operations/distance.dart';

class LineShape extends Shape {
  Vector3 start;
  Vector3 end;

  LineShape(this.start, this.end);

  Segment get segment => Segment(start, end);
  AABB get bounds => AABB.fromSegment(segment);

  @override
  void draw(RenderAdapter adapter) => adapter.drawLine(start, end);

  @override
  bool hitTest(Vector3 point, {double tolerance = Tolerance.geometric}) =>
      isPointOnSegment(point, segment, tolerance: tolerance);

  // --- Grips (Ciclo 2) ---

  @override
  List<Vector3> get gripPoints => [start, end];

  @override
  void moveGrip(int index, Vector3 newPosition) {
    if (index == 0) start = newPosition;
    if (index == 1) end = newPosition;
  }

  @override
  Vector3 get centerGrip => Vector3(
  (start.x + end.x) / 2,
  (start.y + end.y) / 2,
  0,
  );

  @override
  void insertVertex(int segmentIndex, Vector3 position) {
    // No-op intencional. LineShape não suporta vértices extras.
    // A conversão para PlineShape é feita pelo SelectToolController
    // ao detectar ghost grip ou futuro menu de contexto.
    // FUTURO: implementar conversão automática aqui se preferir.
  }
}