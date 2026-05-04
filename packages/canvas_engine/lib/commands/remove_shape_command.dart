// REV: 1.0.1
// CHANGELOG:
// [1.0.1] - 04 05 2026
// - FIX: uso de scene.remove e scene.insert (evita UnmodifiableListView)
//
// [1.0.0] - 02 05 2026
// - ADD: RemoveShapeCommand para undo/redo na exclusão de entidades

import 'package:canvas_engine/commands/command.dart';
import 'package:canvas_engine/domain/entities/shape.dart';
import 'package:canvas_engine/engine/scene.dart';

class RemoveShapeCommand implements Command {
  final Scene scene;
  final Shape shape;
  final int index;

  RemoveShapeCommand({
    required this.scene,
    required this.shape,
    required this.index,
  });

  @override
  void execute() {
    scene.remove(shape);
  }

  @override
  void undo() {
    scene.insert(index, shape);
  }
}