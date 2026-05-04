// REV: 1.0.1
// CHANGELOG:
// [1.0.1] - 02 05 2026
// - FIX: dupla aplicação do delta ao soltar o move
// - ADD: flag _executed para evitar executar ao registrar comando
// - CHG: _executed inicia como true (ação já aplicada antes do registro)
//
// [1.0.0] - 02 05 2026
// - ADD: MoveEntityCommand para desfazer/refazer translação de entidades
// - Recebe shape e delta (Vector3)

import 'package:canvas_engine/commands/command.dart';
import 'package:canvas_engine/domain/entities/shape.dart';
import 'package:canvas_engine/domain/value_objects/vector3.dart';

class MoveEntityCommand implements Command {
  final Shape shape;
  final Vector3 delta;
  bool _executed = true; // Ação já aplicada antes do registro

  MoveEntityCommand({required this.shape, required this.delta});

  @override
  void execute() {
    // Só aplica se for um redo (após undo)
    if (!_executed) {
      for (int i = 0; i < shape.gripPoints.length; i++) {
        shape.moveGrip(i, shape.gripPoints[i] + delta);
      }
      _executed = true;
    }
  }

  @override
  void undo() {
    for (int i = 0; i < shape.gripPoints.length; i++) {
      shape.moveGrip(i, shape.gripPoints[i] - delta);
    }
    _executed = false;
  }
}