// REV: 1.3.0
// CHANGELOG:
// [1.3.0] - 02 05 2026
// - ADD: gripPoints — pontos de edição da entidade
// - ADD: moveGrip() — atualiza posição de um grip
// - ADD: insertVertex() — insere vértice em segmento (para polylines)
// - ADD: nota sobre conversão Line→Pline no insertVertex
//
// [1.2.0] - 02 05 2026
// - CHG: Vector2 → Vector3 — preparação para terreno 3D (Ciclo 0)
//
// [1.1.0] - 29 04 2026
// - CHG: hitTest recebe tolerance opcional (zoom-aware selection)
//
// [1.0.0] - 29 04 2026
// - ADD: interface Shape com draw() e hitTest()

import 'package:canvas_engine/render/render_adapter.dart';
import 'package:canvas_engine/domain/value_objects/vector3.dart';
import 'package:canvas_engine/domain/geometry/tolerance.dart';

abstract class Shape {
  void draw(RenderAdapter adapter);
  bool hitTest(Vector3 point, {double tolerance = Tolerance.geometric});

  /// Pontos de controle editáveis (grips).
  List<Vector3> get gripPoints;

  /// Move um grip para nova posição.
  void moveGrip(int index, Vector3 newPosition);

  /// Insere vértice no meio de um segmento.
  /// LineShape: converte automaticamente para PlineShape (implementação externa).
  /// PlineShape: insere diretamente na lista de vértices.
  void insertVertex(int segmentIndex, Vector3 position);
}