// REV: 1.0.0
// CHANGELOG:
// [1.0.0] - 02 05 2026
// - ADD: InsertVertexCommand — insere vértice em polilinha
// - ADD: undo() remove o vértice inserido
// - CHG: recebe referência mutável de vertices

import 'package:canvas_engine/commands/command.dart';
import 'package:canvas_engine/domain/entities/pline_shape.dart';
import 'package:canvas_engine/domain/value_objects/vector3.dart';

class InsertVertexCommand implements Command {
  final PlineShape shape;
  final int insertIndex;
  final Vector3 position;

  InsertVertexCommand({
    required this.shape,
    required this.insertIndex,
    required this.position,
  });

  @override
  void execute() => shape.vertices.insert(insertIndex, position);

  @override
  void undo() {
    if (insertIndex >= 0 && insertIndex < shape.vertices.length) {
      shape.vertices.removeAt(insertIndex);
    }
  }
}