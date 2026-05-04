// REV: 1.0.0
// CHANGELOG:
// [1.0.0] - 02 05 2026
// - ADD: PlineShape — entidade polilinha unificada
// - ADD: draw() renderiza todos os segmentos
// - ADD: hitTest() testa todos os segmentos
// - ADD: gripPoints retorna todos os vértices
// - ADD: moveGrip() atualiza vértice
// - ADD: insertVertex() insere entre segmentos (ghost grip)

import 'package:canvas_engine/render/render_adapter.dart';
import 'package:canvas_engine/domain/entities/shape.dart';
import 'package:canvas_engine/domain/value_objects/vector3.dart';
import 'package:canvas_engine/domain/geometry/tolerance.dart';
import 'package:canvas_engine/domain/geometry/primitives/segment.dart';
import 'package:canvas_engine/domain/geometry/operations/distance.dart';

class PlineShape extends Shape {
  final List<Vector3> vertices;

  PlineShape(this.vertices) : assert(vertices.length >= 2);

  List<Segment> get segments {
    final segs = <Segment>[];
    for (int i = 0; i < vertices.length - 1; i++) {
      segs.add(Segment(vertices[i], vertices[i + 1]));
    }
    return segs;
  }

  @override
  void draw(RenderAdapter adapter) {
    for (int i = 0; i < vertices.length - 1; i++) {
      adapter.drawLine(vertices[i], vertices[i + 1]);
    }
  }

  @override
  bool hitTest(Vector3 point, {double tolerance = Tolerance.geometric}) {
    for (final seg in segments) {
      if (isPointOnSegment(point, seg, tolerance: tolerance)) return true;
    }
    return false;
  }

  // --- Grips ---

  @override
  List<Vector3> get gripPoints => vertices;

  @override
  void moveGrip(int index, Vector3 newPosition) {
    vertices[index] = newPosition;
  }

  @override
Vector3 get centerGrip {
  if (vertices.isEmpty) return Vector3.zero;
  var sum = Vector3.zero;
  for (final v in vertices) {
    sum = Vector3(sum.x + v.x, sum.y + v.y, 0);
  }
  return Vector3(
    sum.x / vertices.length,
    sum.y / vertices.length,
    0,
  );
  }


  @override
  void insertVertex(int segmentIndex, Vector3 position) {
    final insertIndex = segmentIndex + 1;
    if (insertIndex >= 0 && insertIndex <= vertices.length) {
      vertices.insert(insertIndex, position);
    }
  }
}